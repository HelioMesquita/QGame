//
//  GridViewModel+Models.swift
//  qgame
//
//  Created by Hélio Mesquita on 23/04/26.
//

import Foundation
internal import Combine

class GridViewModel: ObservableObject {

    @Published var epsilonValue: Double = 0.4
    @Published var alphaValue: Double = 0.1
    @Published var gammaValue: Double = 0.9
    @Published var episodesValue: Double = 1000
    @Published var cells: [[QBox]] = []
    @Published var isAnimated = true
    @Published var currentEpisode: Int = 0
    @Published var isRunning = false
    private var runningTask: Task<Void, Never>?
    private var qTable: [CoordinateQTable: QBox] = [:]
    let gridSize: Int

    init(gridSize: Int) {
        self.gridSize = gridSize
        createGrid()
    }

    deinit {
        print("Leaving the memory")
    }

    private func createGrid() {
        for row in 0..<gridSize {
            cells.append([])
            for col in 0..<gridSize {
                let x = col
                let y = gridSize - 1 - row
                let coordinate = CoordinateQTable(x: x, y: y)
                let isGoal = row == 0 && col == gridSize-1 // Top Right value
                let condition: BoxCondition = isGoal ? .goal : .floor
                let actions = Action.allCases.compactMap({ QAction(action: $0) })
                let qBox = QBox(condition: condition, actions: actions, x: x, y: y)
                qTable[coordinate] = qBox
                cells[row].append(qBox)
            }
        }
    }

    func run() {
        reset()
        runQlearning()
    }

    func stop() {
        isRunning = false
        runningTask?.cancel()
    }

    private func runQlearning() {
        isRunning = true
        runningTask = Task { @MainActor in
            let episodes = Int(episodesValue)
            let map = Map(qTable: qTable)
            let ql = QLearning(epsilon: epsilonValue, alpha: alphaValue, gamma: gammaValue, qTable: qTable)
            for episode in 0...episodes {
                if Task.isCancelled { break }
                currentEpisode = episode
                var coordinate = map.reset()
                for _ in 0..<gridSize * gridSize {
                    let action = ql.getAction(coordinate: coordinate)
                    let (newCoordinate, reward, isFinal) = map.act(action: action)
                    ql.update(oldCoordinate: coordinate, action: action, newCoordinate: newCoordinate, reward: reward, isFinal: isFinal)
                    coordinate = newCoordinate
                    if isAnimated {
                        try? await Task.sleep(for: .milliseconds(3))
                    }
                    if isFinal {
                        break
                    }
                }
            }
            showBestPath(map: map, ql: ql)
            isRunning = false
        }
    }

    private func showBestPath(map: Map, ql: QLearning) {
        var coordinate = map.reset()
        for _ in 0..<gridSize * gridSize {
            let action = ql.getBestAction(coordinate: coordinate)
            let (newCoordinate, reward, isFinal) = map.act(action: action)
            ql.update(oldCoordinate: coordinate, action: action, newCoordinate: newCoordinate, reward: reward, isFinal: isFinal)
            coordinate = newCoordinate
            if isFinal {
                break
            }
        }
    }

    // Clean all saved values in the actions and clean the last action
    func reset() {
        qTable.forEach { (key: CoordinateQTable, value: QBox) in
            value.lastAction = nil
            value.actions.forEach { action in
                action.value = 0
            }
        }
    }

}

class QLearning {

    let qTable: [CoordinateQTable: QBox]
    let epsilon: Double
    let alpha: Double
    let gamma: Double

    init(epsilon: Double = 0.1, alpha: Double = 0.1, gamma: Double = 0.9, qTable: [CoordinateQTable: QBox]) {
        self.epsilon = epsilon
        self.alpha = alpha
        self.gamma = gamma
        self.qTable = qTable
    }

    func getMaxQ(coordinate: CoordinateQTable) -> Double {
        let qBox = qTable[coordinate]
        return qBox!.actions.compactMap({ $0.value }).sorted().last!
    }

    func getBestAction(coordinate: CoordinateQTable) -> Action {
        let actions = qTable[coordinate]!.actions
        let bestValue = actions.map(\.value).max()!
        return actions.filter { $0.value == bestValue }.randomElement()!.action
    }

    func getRandomAction() -> Action {
        return Action.allCases.randomElement()!
    }

    func getAction(coordinate: CoordinateQTable) -> Action {
        let random = Double.random(in: 0..<1.0)
        if random < self.epsilon {
            return getRandomAction()
        } else {
            return getBestAction(coordinate: coordinate)
        }
    }

    func update(oldCoordinate: CoordinateQTable, action: Action, newCoordinate: CoordinateQTable, reward: Double, isFinal: Bool) {
        let qBox = self.qTable[oldCoordinate]
        let qAction = qBox!.actions.first(where: { $0.action == action })!
        if isFinal {
            qAction.value += self.alpha * (reward - qAction.value)
        } else {
            qAction.value += self.alpha * (reward + self.gamma * self.getMaxQ(coordinate: newCoordinate) - qAction.value)
        }
    }

}

class Map {

    let qTable: [CoordinateQTable: QBox]
    var currentCoordinate: CoordinateQTable!

    init(qTable: [CoordinateQTable: QBox]) {
        self.qTable = qTable
        reset()
    }

    @discardableResult
    func reset() -> CoordinateQTable {
        cleanAllLastAction()
        let firstPosition = qTable.first { (key: CoordinateQTable, value: QBox) in
            return key.x == 0 && key.y == 0
        }!
        currentCoordinate = firstPosition.key
        return currentCoordinate
    }

    private func cleanAllLastAction() {
        qTable.forEach { (key: CoordinateQTable, value: QBox) in
            value.lastAction = nil
        }
    }

    func act(action: Action) -> (newCoordinate: CoordinateQTable, reward: Double, isFinal: Bool) {
        qTable[currentCoordinate]?.lastAction = action // only for debug

        var x: Int!
        var y: Int!

        switch action {
        case .up:
            x = currentCoordinate.x
            y = currentCoordinate.y+1

        case .right:
            x = currentCoordinate.x+1
            y = currentCoordinate.y

        case .down:
            x = currentCoordinate.x
            y = currentCoordinate.y-1

        case .left:
            x = currentCoordinate.x-1
            y = currentCoordinate.y
        }

        let nextCoordinate = CoordinateQTable(x: x, y: y)
        guard let qBox = qTable[nextCoordinate] else {
            // hit the wall
            return (currentCoordinate, -1, false)
        }
        switch qBox.condition {
        case .floor:
            currentCoordinate = nextCoordinate
            return (nextCoordinate, 0, false)
        case .goal:
            currentCoordinate = nextCoordinate
            return (nextCoordinate, 100, true)
        case .rock:
            return (currentCoordinate, -1, false)
        }
    }
}

enum BoxCondition {
    case floor, goal, rock
}

enum Action: CaseIterable {
    case up, right, down, left

    var text: String {
        switch self {
        case .up:
            return "⬆"
        case .right:
            return "➡"
        case .down:
            return "⬇"
        case .left:
            return "⬅"
        }
    }
}

class CoordinateQTable: Hashable {
    let id = UUID()
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    static func == (lhs: CoordinateQTable, rhs: CoordinateQTable) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class QAction {
    let action: Action
    var value: Double

    init(action: Action, value: Double = 0) {
        self.action = action
        self.value = value
    }
}

class QBox: ObservableObject {
    @Published var condition: BoxCondition
    var actions: [QAction]

    // Only for debug, not used in Q-Learn
    let x: Int
    let y: Int
    @Published var lastAction: Action?
    var debug: String {
        return "\(lastAction?.text ?? "")"
    }

    init(condition: BoxCondition, actions: [QAction], x: Int, y: Int) {
        self.condition = condition
        self.actions = actions
        self.x = x
        self.y = y
    }

}
