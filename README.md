# qgame — Q-Learning Visualizer for iOS

An iOS app built with SwiftUI that visualizes the **Q-Learning** reinforcement learning algorithm on an interactive grid. Place obstacles, tune hyperparameters, and watch the agent learn the optimal path in real time.

---

## Screenshots

<img src="screenshot/Simulator%20Screenshot%20-%20iPhone%2017%20Pro.png" height="1311" />

---

## Features

- **Interactive grid** — tap cells to place or remove obstacles
- **Real-time visualization** — watch the agent explore and learn step by step
- **Adjustable hyperparameters** — tune α (alpha), γ (gamma), ε (epsilon) and number of episodes via sliders
- **Epsilon decay** — exploration rate decreases over time for better convergence
- **Best path replay** — after training, the agent replays the optimal path it learned
- **Stop anytime** — cancel training mid-run

---

## How It Works

Q-Learning is a model-free reinforcement learning algorithm. The agent starts at the bottom-left corner of the grid and tries to reach the goal at the top-right corner.

At each step:
1. The agent chooses an action (up, right, down, left) based on an ε-greedy policy
2. The environment returns a reward and the new state
3. The Q-table is updated using the Bellman equation:

```
Q(s, a) ← Q(s, a) + α * [r + γ * max Q(s', a') - Q(s, a)]
```

| Symbol | Name    | Description                              |
|--------|---------|------------------------------------------|
| α      | Alpha   | Learning rate                            |
| γ      | Gamma   | Discount factor for future rewards       |
| ε      | Epsilon | Exploration rate (random vs best action) |

**Rewards:**
- Reached goal: `+100`
- Hit wall or obstacle: `-1`
- Regular move: `0`

---

## Architecture

The project follows an **Object-Oriented** architecture:

```
GridViewModel       — manages grid state, training loop, and UI bindings
QLearning           — Q-table updates, action selection (ε-greedy)
Map                 — environment: state transitions and reward logic
QBox                — represents a single grid cell with its Q-values
CoordinateQTable    — hashable (x, y) coordinate used as Q-table key
QAction             — stores an action and its learned Q-value
```

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Getting Started

```bash
git clone https://github.com/HelioMesquita/QGame
cd qgame
open qgame.xcodeproj
```

Build and run on simulator or device.

---

## Usage

1. **Set up the grid** — tap any white cell to place an obstacle (brown). Tap again to remove it.
2. **Tune hyperparameters** — use the sliders to adjust α, γ, ε and the number of episodes.
3. **Start training** — tap **Start** to begin Q-Learning.
4. **Watch the result** — after training completes, the agent replays the best path it found.
5. **Stop early** — tap **Stop** at any time to cancel training.

---

## License

MIT