//
//  ContentView.swift
//  qgame
//
//  Created by Hélio Mesquita on 20/04/26.
//

import SwiftUI
internal import Combine

struct MenuView: View {

    @State var gridSize: Double = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 50)
                Text("Q-Learning Demonstration")
                    .font(.title)
                Text("""
                    This is a game that uses the Q-learning algorithm to demonstrate how a computer learns to play and improves its knowledge over time in order to win in the best possible way
                    """)
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
                Text("What is the grid size?")
                Text("\(String(format: "%.f", gridSize))")
                Slider(value: $gridSize, in: 0...15, step: 1)
                Spacer()
                NavigationLink("Start Gaming") {
                    GridView(gridSize: Int(gridSize))
                }
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                Spacer()
                    .frame(height: 50)
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
}

