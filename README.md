# Tesla 4680 Battery Fast Charging: Enhanced Current Control System

[![arXiv](https://img.shields.io/badge/arXiv-XXXX.XXXXX-b31b1b.svg)](https://arxiv.org/abs/XXXX.XXXXX)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains the simulation code and results for our research on enhanced current control and preheating systems for Tesla 4680 battery fast charging.

**Key Results:**
- 240-2430% improvement in charging performance across temperature ranges
- Safe operation maintained (peak temperatures <57°C) 
- Positive energy return (2.18:1) for preheating in cold conditions
- Commercial-grade performance matching Tesla Supercharger specifications

## Paper

**"Enhanced Current Control and Preheating System for Tesla 4680 Battery Fast Charging: Multi-Temperature Performance Analysis and Energy Efficiency Validation"**

- **Preprint:** arXiv:XXXX.XXXXX (coming soon)
- **Journal:** Submitted to IEEE Transactions on Transportation Electrification
- **Authors:** [Thang Quoc Ly]

## Research Highlights

- **Multi-temperature validation:** -10°C to 40°C operating range
- **Advanced current control:** 250A peak capability vs 4-60A baseline
- **Thermal safety analysis:** Comprehensive temperature management
- **Energy economics:** Quantified preheating return on investment

## Repository Contents

- `src/matlab/` - MATLAB simulation scripts
- `src/simulink/` - Simulink battery pack models  
- `data/` - Simulation parameters and results
- `figures/` - All paper figures and visualizations
- `docs/` - Setup and usage documentation

## Quick Start

### Requirements
- MATLAB R2025a or later
- Simscape Electrical toolbox
- Statistics and Machine Learning Toolbox

### Running the Simulation
```matlab
cd src/matlab
run main_simulation.m
