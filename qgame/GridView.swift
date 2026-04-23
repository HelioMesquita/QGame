//
//  GridView.swift
//  qgame
//
//  Created by Hélio Mesquita on 23/04/26.
//

import SwiftUI

struct GridView: View {

    @State private var showTooltipLearningRate = false
    @State private var showTooltipDiscountFactor = false
    @State private var showTooltipExplorationRate = false

    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: GridViewModel

    init(gridSize: Int) {
        _viewModel = StateObject(wrappedValue: GridViewModel(gridSize: gridSize))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Text("Episode: \(viewModel.currentEpisode)")
                Spacer()
                    .frame(height: 20)

                VStack(spacing: 0) {
                    ForEach(0..<viewModel.cells.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.cells[row].count, id: \.self) { col in
                                GridCell(box: viewModel.cells[row][col])
                                    .frame(maxWidth: 50)
                            }
                        }
                    }
                }
                .disabled(viewModel.isRunning)
                .border(Color.black, width: 2)

                VStack(spacing: 0) {
                    Text("α Learning Rate : \(String(format: "%.2f", viewModel.alphaValue))")
                        .onTapGesture {
                            showTooltipLearningRate.toggle()
                        }
                        .overlay(alignment: .top) {
                            if showTooltipLearningRate {
                                Text("Definition: The learning rate controls how much new information overrides old information.")
                                    .padding(8)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .offset(y: -120)
                                    .onTapGesture {
                                        showTooltipLearningRate = false
                                    }
                            }
                        }
                    Slider(value: $viewModel.alphaValue, in: 0...1)

                    Text("γ Discount Factor: \(String(format: "%.2f", viewModel.gammaValue))")
                        .onTapGesture {
                            showTooltipDiscountFactor.toggle()
                        }
                        .overlay(alignment: .top) {
                            if showTooltipDiscountFactor {
                                Text("Definition: The discount factor determines the importance of future rewards compared to immediate rewards.")
                                    .padding(8)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .offset(y: -140)
                                    .onTapGesture {
                                        showTooltipDiscountFactor = false
                                    }
                            }
                        }
                    Slider(value: $viewModel.gammaValue, in: 0...1)

                    Text("ε Exploration Rate: \(String(format: "%.2f", viewModel.epsilonValue))")
                        .onTapGesture {
                            showTooltipExplorationRate.toggle()
                        }
                        .overlay(alignment: .top) {
                            if showTooltipExplorationRate {
                                Text("Definition: Part of the epsilon-greedy strategy, this dictates the balance between exploration (trying new things) and exploitation (using known information).")
                                    .padding(8)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .offset(y: -170)
                                    .onTapGesture {
                                        showTooltipExplorationRate = false
                                    }
                            }
                        }
                    Slider(value: $viewModel.epsilonValue, in: 0...1)

                    Text("Episodes: \(String(format: "%.f", viewModel.episodesValue))")
                    Slider(value: $viewModel.episodesValue, in: 100...10000, step: 1)

                    Toggle("Enable Animation", isOn: $viewModel.isAnimated)

                }
                .padding()
                .disabled(viewModel.isRunning)

                Button(viewModel.isRunning ? "Stop" : "Start") {
                    if viewModel.isRunning {
                        viewModel.stop()
                    } else {
                        viewModel.run()
                    }

                }
                .padding()
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(Capsule())

            }
        }
        .navigationTitle("Q-Learning Grid \(viewModel.gridSize)×\(viewModel.gridSize)")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(viewModel.isRunning ? "Stop and Back" : "Back") {
                    viewModel.stop()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    GridView(gridSize: 5)
}
