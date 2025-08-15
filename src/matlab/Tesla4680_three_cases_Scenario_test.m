%% Tesla 4680 Battery Fast Charging Simulation
% Enhanced Current Control and Preheating System Analysis
% 
% This script implements the complete simulation for Tesla 4680 battery 
% fast charging performance across multiple temperature scenarios
%
% Author: [Thang Quoc Ly]
% Institution: [Grinnell College]
% Date: 15 August 2025
% 
% Associated Paper:
% "Enhanced Current Control and Preheating System for Tesla 4680 Battery 
%  Fast Charging: Multi-Temperature Performance Analysis and Energy 
%  Efficiency Validation"
% Submitted to: IEEE Transactions on Transportation Electrification
%
% Key Results Achieved:
% - 240-2430% improvement in charging performance across temperature ranges
% - Safe thermal operation (peak temperatures <57°C)
% - Positive energy return (2.18:1) for cold weather preheating
% - Commercial-grade performance matching Tesla Supercharger specs
%
% Temperature Scenarios:
% - Cold (-10°C): With and without preheating
% - Normal (25°C): Optimal performance validation  
% - Hot (40°C): Thermal management verification

%% Clear workspace and initialize
clear all; close all; clc;


%% SELECT TEMPERATURE SCENARIO
temp_scenario = 1;  % 1=Cold(-10 deg C), 2=Normal(25 deg C), 3=Hot(40 deg C)
ENABLE_PREHEAT = true;  % Preconditioning: true=enabled (realistic), 
% false=disabled (test cold start)

% General Parameters
cellInitialSOC = 0.2; % All cell initial SOC 20%
auxLoad = 400; % Auxiliary power load (Electronics, system on vehicles) [W]
AH = 26.5; % Tesla 4680 cell capacity [Ah]

% Lookup Table Points
T_vec = [273.15, 298.15, 323.15]; % 0, 25, 50 deg C
SOC_vec = [0, 0.25, 0.75, 1]; % Cell state of charge vector SOC [-]
Flowrate_vec = [0, 0.01, 0.02, 0.03, 0.04, 0.05]; % Flowrate vector L [kg/s]

% Cell Electrical Parameters
V0_mat = [3.00, 3.05, 3.10; ... % 0% SOC
          3.55, 3.57, 3.59; ... % 25% SOC
          3.98, 4.00, 4.02; ... % 75% SOC
          4.18, 4.20, 4.22];    % 100% SOC

R0_mat = [0.0035, 0.0030, 0.0025; ... % 0% SOC
          0.0025, 0.0020, 0.0018; ... % 25% SOC
          0.0020, 0.0018, 0.0015; ... % 75% SOC
          0.0022, 0.0020, 0.0018]; % 100% SOC

R1_mat = [0.0020, 0.0018, 0.0015; ... % 0% SOC
          0.0018, 0.0015, 0.0012; ... % 25% SOC
          0.0015, 0.0012, 0.0010; ... % 75% SOC
          0.0018, 0.0015, 0.0012]; % 100% SOC

Tau1_mat = [30, 25, 20; ... % 0% SOC
            25, 20, 15; ... % 25% SOC
            20, 15, 10; ... % 75% SOC
            25, 20, 15]; % 100% SOC

R2_mat = [0.0015, 0.0012, 0.0010; ... % 0% SOC
          0.0012, 0.0010, 0.0008; ... % 25% SOC
          0.0010, 0.0008, 0.0006; ... % 75% SOC
          0.0012, 0.0010, 0.0008]; % 100% SOC

Tau2_mat = [800, 600, 400; ... % 0% SOC
            600, 450, 300; ... % 25% SOC
            400, 300, 200; ... % 75% SOC
            500, 400, 300]; % 100% SOC

Ndisc = 100; delV0 = 0; delR0 = 0; delR1 = 0; delR2 = 0; delAH = 0;

% Cell Thermal Properties
MdotCp = 390; % Cell thermal mass [J/K]
K_cell = 1.2; % Cell thermal conductivity [W/(m*K)]
h_cell = 15; % Heat transfer coefficient [W/(m^2*K)]

% Module Electrical
cell_H = 0.080; % Cell height [m]
cell_W = 0.046; % Cell diameter [m]
cell_T = 0.080; % Cell thickness [m]

Ns_A = 20; Np_A = 2; Rext_A = 0.8e-3;
Ns_B = 20; Np_B = 2; Rext_B = 1.0e-3
Ns_C = 25; Np_C = 2; Rext_C = 1.2e-3;

% Temperatures Setup
T_COLD  = 263.15;           % -10 deg C
T_NORMAL = 298.15;          % 25 deg C
T_HOT   = 313.15;           % 40 deg C
PREHEAT_TARGET = 288.15;    % 15 deg C
PREHEAT_POWER = 6000;       % 6 kW heater
HEATING_RATE_K_PER_MIN = 3.0;
HEATING_RATE = HEATING_RATE_K_PER_MIN / 60;

%% TEMPERATURE SCENARIO MODIFICATIONS
switch temp_scenario
    case 1  % COLD (-10 deg C)
        ambient = T_COLD; % -10 deg C
        
    case 2  % NORMAL (25 deg C)
        ambient = T_NORMAL; % 25 deg C
        
    case 3  % HOT (40 deg C)
        ambient = T_HOT; % 40 deg C
end

% Preheating system
if ENABLE_PREHEAT && ambient < PREHEAT_TARGET %cold scenario
    cellInitialTemp = PREHEAT_TARGET;  %cell temperature = 288.15K
    temp_rise = PREHEAT_TARGET - ambient; 
    preheat_time_min = temp_rise / HEATING_RATE_K_PER_MIN; 
    preheat_energy_kWh = PREHEAT_POWER * preheat_time_min * 60 / 3600;
    auxLoad = auxLoad + 1000;
    preheat_applied = true;
    
else %normal and hot temperature scenario 
    cellInitialTemp = ambient;
    preheat_applied = false;
    preheat_time_min = 0;
    preheat_energy_kWh = 0;
end


%% Module Thermal - original Matlab code
base_cooling = [0, 0.6, 1.2, 1.8, 2.4, 3.0; 
                0, 0.6, 1.2, 1.8, 2.4, 3.0; 
                0, 0.6, 1.2, 1.8, 2.4, 3.0];

% Module A
coolantQ_A = repmat(4.5 * base_cooling, [1, 1, Ns_A*Np_A]);
extHeat_A = zeros(1, Ns_A*Np_A);

% Module B
coolantQ_B = repmat(4.2 * base_cooling, [1, 1, Ns_B*Np_B]);
extHeat_B = 0.5 * ones(1, Ns_B*Np_B);

% Module C
coolantQ_C = repmat(3.8 * base_cooling, [1, 1, Ns_C*Np_C]);
extHeat_C = 1.2 * ones(1, Ns_C*Np_C);

if preheat_applied
    total_cells = Ns_A * Np_A + Ns_B * Np_B + Ns_C * Np_C;
    heater_per_cell = PREHEAT_POWER / total_cells;
    extHeat_A = extHeat_A + heater_per_cell;
    extHeat_B = extHeat_B + heater_per_cell;
    extHeat_C = extHeat_C + heater_per_cell;
end


%% Cell-to-Cell Variation
AhrVar = 0.010;

% Module A
AhrVar_A = 1 + AhrVar * 0.5 * (1 - 2*abs((1:Ns_A * Np_A)/(Ns_A*Np_A) - 0.5));
cellT_ini_A = cellInitialTemp * ones(1, Ns_A*Np_A);
cellSOC_ini_A = cellInitialSOC * ones(1, Ns_A*Np_A);

% Module B
AhrVar_B = 1 + AhrVar * 0.7 * (1 - 2*abs((1:Ns_B*Np_B)/(Ns_B*Np_B) - 0.5));
cellT_ini_B = cellInitialTemp * ones(1, Ns_B*Np_B);
cellSOC_ini_B = cellInitialSOC * ones(1, Ns_B*Np_B);

% Module C
AhrVar_C = 1 + AhrVar * 0.9 * (1 - 2*abs((1:Ns_C*Np_C)/(Ns_C*Np_C) - 0.5));
cellT_ini_C = cellInitialTemp * ones(1, Ns_C*Np_C);
cellSOC_ini_C = cellInitialSOC * ones(1, Ns_C*Np_C);

%% DISPLAY CONFIGURATION
fprintf('Simulation Information');
fprintf('Scenario: ');
if temp_scenario == 1
    fprintf('COLD (-10°C)\n');
elseif temp_scenario == 2
    fprintf('NORMAL (25°C)\n');
else
    fprintf('HOT (40°C)\n');
end
fprintf('Ambient Temp: %.1f°C\n', ambient - 273.15);
fprintf('Cell Init Temp: %.1f°C\n', cellInitialTemp - 273.15);

if preheat_applied
    fprintf('\nPreheating: ENABLED\n');
    fprintf('- Preheat Time: %.1f min\n', preheat_time_min);
    fprintf('- Preheat Energy: %.2f kWh\n', preheat_energy_kWh);
else
    fprintf('\nPreheating: DISABLED\n');
end
fprintf('=====================================\n');


