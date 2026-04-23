//
//  GridCell.swift
//  qgame
//
//  Created by Hélio Mesquita on 23/04/26.
//

import SwiftUI

struct GridCell: View {
    @ObservedObject var box: QBox

    var body: some View {
        ZStack {
            switch box.condition {
            case .floor:
                Rectangle()
                    .fill(Color.white)
                    .border(Color.black, width: 1)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .onTapGesture {
                        box.lastAction = nil
                        box.condition = .rock
                    }
            case .goal:
                Rectangle()
                    .fill(Color.green)
                    .border(Color.black, width: 1)
                    .frame(maxWidth: 50, maxHeight: 50)

            case .rock:
                Rectangle()
                    .fill(Color.brown)
                    .border(Color.black, width: 1)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .onTapGesture {
                        box.lastAction = nil
                        box.condition = .floor
                    }
            }
            Text(box.debug)
        }
    }
}

#Preview {
    let box = QBox(condition: .floor, actions: [], x: 0, y: 0)
    box.lastAction = .up

    let box1 = QBox(condition: .floor, actions: [], x: 0, y: 0)
    box1.lastAction = .right

    let box2 = QBox(condition: .floor, actions: [], x: 0, y: 0)
    box2.lastAction = .down

    let box3 = QBox(condition: .floor, actions: [], x: 0, y: 0)
    box3.lastAction = .left

    return VStack(spacing: 10) {
        GridCell(box: QBox(condition: .goal, actions: [], x: 0, y: 0))
        GridCell(box: QBox(condition: .floor, actions: [], x: 0, y: 0))
        GridCell(box: QBox(condition: .rock, actions: [], x: 0, y: 0))
        GridCell(box: box)
        GridCell(box: box1)
        GridCell(box: box2)
        GridCell(box: box3)
    }

}
