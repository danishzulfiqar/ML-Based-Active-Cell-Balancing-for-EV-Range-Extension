# FYP

Welcome to the FYP Master project! This repository contains the code and resources for our Final Year Project (FYP) in MATLAB.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction
This project aims to optimize the performance of electric vehicle (EV) simulations using MATLAB, focusing on maximizing the vehicle's range. The simulations incorporate different driving cycles and various initial states of charge (SOC), providing a comprehensive analysis of the vehicle's behavior under different conditions. The main goal is to identify optimal parameter settings, particularly the weights associated with different cost functions, to enhance the range efficiency of the vehicle.

The project includes functionalities to automate simulations, generate random SOC values, iterate through drive cycles, and apply scaling factors. Additionally, it enables the customization of simulation settings, such as the weights for different cost functions and power losses, to explore a wide range of configurations. The results are saved in a structured format for further analysis, allowing for the evaluation of key performance metrics and the identification of optimal configurations that maximize the range.

By leveraging MATLAB's capabilities, this project provides a robust framework for evaluating and improving EV performance, making it valuable for researchers and engineers involved in electric vehicle development and optimization.

## Features
- Feature 1: Automated Simulation of Drive Cycles
The project automates the simulation of various drive cycles to evaluate electric vehicle performance under different conditions. It iterates through predefined driving patterns, adjusting simulation parameters such as scaling factors and initial SOC values to simulate real-world driving scenarios effectively.
- Feature 2: Dynamic SOC Initialization
The simulation framework randomly generates SOC values within a specified range (e.g., 0.50 to 0.90) for each simulation run, ensuring a diverse set of initial conditions. This helps in evaluating the impact of different starting SOC levels on the vehicle's range and energy consumption.
- Feature 3: Weight Optimization for Range Maximization
The project allows for the adjustment of cost function weights that influence power losses and other factors affecting the vehicle's range. By optimizing these weights, the framework aims to maximize the range achieved during simulations, helping identify the best configurations for extending electric vehicle efficiency.

## Installation
To get started with this project, clone the repository and set up the environment:

```bash
git clone https://github.com/danishzulfiqar/FYP-Master.git
cd FYP-Master
```

## Usage
To run the project, follow these steps:

1. Step 1: Set Up the Environment
Make sure MATLAB is installed on your system and the required toolboxes are available. Clone the project repository and navigate to the project directory where the MATLAB files are stored.
2. Step 2: Configure Simulation Parameters
Open the main MATLAB script and adjust the simulation parameters, such as the number of simulations (Sim_Num), SOC ranges, and the desired drive cycles. You can also modify the weight ranges to suit the specific requirements of the simulation.
3. Step 3: Run the Simulation
Execute the main MATLAB script to start the simulations. The script will iterate through the drive cycles, generate random SOC values, and optimize the weights for maximizing the range. The results will be saved automatically in the GeneratedData folder for further analysis.

## Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to reach out if you have any questions or suggestions!

