% =========================================================================
% MAIN SCRIPT for Conductor Thermal Analysis (V5 - Simplified & Functional)
% =========================================================================
% MODIFIED:
% - The logic from A8_GroupingFactor.m has been merged directly into this
%   script to reduce complexity and potential file path errors.
% - This version is streamlined for robust functionality.
% =========================================================================

%% --- Cleanup and Initialization ---
% clc; clear; close all; % Commented out for master script control

%% --- User Input: Scenario Selection ---
if ~exist('installationChoice', 'var')
    installationChoice = centeredMenu('Select Installation Scenario:', 'Underground (Student A)', 'Overhead (Student B)', 'Building/Grouped (Student C)');
end

%% --- Define Physical Constants ---
T_ref = 20;     % Reference temperature for resistance [°C]
rho_den_copper = 8960;      cp_copper = 385;
rho_den_aluminum = 2700;    cp_aluminum = 900;
cp_pvc = 1000;              cp_xlpe = 2300;

%% --- Scenario-Specific User Input ---
envParams = struct();
switch installationChoice
    case 1 % Underground
        envParams.scenario = 'underground';
        disp('--- UNDERGROUND INSTALLATION INPUT ---');
        envParams.T_env = input('Enter ground temperature [°C] (e.g., 15): ');
        envParams.rho_soil = input('Enter soil thermal resistivity [K*m/W] (e.g., 1.2): ');
        envParams.burial_depth = input('Enter burial depth to cable center [m] (e.g., 1): ');
    case 2 % Overhead
        envParams.scenario = 'overhead';
        disp('--- OVERHEAD INSTALLATION INPUT ---');
        envParams.T_env = input('Enter ambient air temperature [°C] (e.g., 40): ');
        envParams.wind_speed = input('Enter wind speed [m/s] (e.g., 0.5): ');
        envParams.solar_irradiance = input('Enter solar irradiance [W/m^2] (e.g., 1000): ');
        envParams.emissivity = 0.9;
        envParams.absorptivity = 1.0;
    case 3 % Building/Grouped
        envParams.scenario = 'building';
        disp('--- BUILDING/GROUPED INSTALLATION INPUT ---');
        envParams.T_env = input('Enter ambient air temperature [°C] (e.g., 30): ');
        num_cables = input('Enter total number of cables in the group (e.g., 6): ');
        
        % SIMPLIFICATION: A8_GroupingFactor logic moved directly here
        if num_cables <= 1, k_g = 1.0;
        elseif num_cables <= 3, k_g = 0.80;
        elseif num_cables <= 6, k_g = 0.70;
        elseif num_cables <= 9, k_g = 0.60;
        elseif num_cables <= 20, k_g = 0.50;
        else, k_g = 0.45;
        end
        envParams.grouping_factor = k_g;
        
        envParams.wind_speed = 0; % No wind inside a building
        envParams.solar_irradiance = 0; % No sun inside a building
        envParams.emissivity = 0.9;
        envParams.absorptivity = 1.0;
        fprintf('Applied grouping derating factor: %.2f\n', envParams.grouping_factor);
    case 0
        disp('No scenario selected. Exiting script.'); return;
    otherwise
        error('Invalid scenario choice. Exiting.');
end

%% --- General User Input ---
disp('--- GENERAL CONDUCTOR INPUT ---');
lineLength = input('Enter line length [m] (e.g., 100): ');
crossSection = input('Enter cross-sectional area [mm^2] (e.g., 50): ');
insulatorThickness = input('Enter insulator thickness [mm] (e.g., 1.2): ');
frequency = input('Enter AC frequency [Hz] (e.g., 50): ');
materialChoice = centeredMenu('Select Conductor Material:', 'Copper', 'Aluminum', 'ACSR');
insulationChoice = centeredMenu('Select Insulation Type:', 'PVC', 'XLPE');

if materialChoice == 0 || insulationChoice == 0
    disp('No material or insulation selected. Exiting script.'); return;
end

%% --- Set Conductor & Insulation Parameters ---
alpha = 0.00393;
switch materialChoice, case 1, sigma = 56; materialName = 'Copper'; density = rho_den_copper; specificHeat = cp_copper; case 2, sigma = 36; materialName = 'Aluminum'; density = rho_den_aluminum; specificHeat = cp_aluminum; case 3, sigma = 36; materialName = 'ACSR'; density = rho_den_aluminum; specificHeat = cp_aluminum; end
switch insulationChoice, case 1, T_mat = 70; k = 0.19; insulationName = 'PVC'; case 2, T_mat = 90; k = 0.35; insulationName = 'XLPE'; end
envParams.k_insulator = k;

%% --- Resistance and Geometry Calculations ---
r_inner_m = sqrt(crossSection / pi) / 1000;
r_outer_m = r_inner_m + (insulatorThickness / 1000);
R_20_DC = lineLength / (sigma * crossSection);
[k_skin, k_proximity] = A3b_AC_Resistance_Factor(frequency, r_inner_m * 2, sigma);
R_20_AC = R_20_DC * (1 + k_skin + k_proximity);

%% --- Analysis & Display ---
fprintf('\n--- ANALYSIS FOR SCENARIO: %s ---\n', upper(envParams.scenario));
I_max_DC = A2_MaximumCurrent(R_20_DC, alpha, T_mat, envParams, lineLength, r_inner_m, r_outer_m);
I_max_AC = A2_MaximumCurrent(R_20_AC, alpha, T_mat, envParams, lineLength, r_inner_m, r_outer_m);
fprintf('Max Current (Ampacity) - DC Resistance: %.2f A\n', I_max_DC);
fprintf('Max Current (Ampacity) - AC Resistance: %.2f A\n', I_max_AC);
if isfield(envParams, 'grouping_factor')
    fprintf('NOTE: Above values INCLUDE the grouping derating factor of %.2f.\n', envParams.grouping_factor);
end
fprintf('--------------------------------------------------\n');

% Plotting Steady-State Curves
A5_HeatingCurves(I_max_AC, T_mat, envParams, R_20_DC, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, materialName, insulationName);

% Transient Analysis
sim_current_prompt = sprintf('Enter a current for transient simulation (e.g., %.0f A): ', I_max_AC * 0.8);
sim_current = input(sim_current_prompt);
if isempty(sim_current), sim_current = I_max_AC * 0.8; end

volume = (crossSection / 1e6) * lineLength;
mass = volume * density;
time_span = [0 7200]; % Simulate for 2 hours

[time_ac, temp_ac] = A6_TransientHeating(sim_current, time_span, envParams, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, mass, specificHeat);

figure;
plot(time_ac/60, temp_ac, 'r-', 'LineWidth', 2);
T_ss_ac = A4_ThermalEquilibrium(sim_current, R_20_AC, alpha, T_ref, envParams, lineLength, r_inner_m, r_outer_m);
line([0, time_ac(end)/60], [T_ss_ac, T_ss_ac], 'Color', 'r', 'LineStyle', '--');
title(sprintf('Transient Heating (%s) for %.1f A', envParams.scenario, sim_current));
xlabel('Time (minutes)'); ylabel('Conductor Temperature (°C)'); grid on;
legend('Transient Temperature', sprintf('Final Equilibrium Temp (%.1f°C)', T_ss_ac));

