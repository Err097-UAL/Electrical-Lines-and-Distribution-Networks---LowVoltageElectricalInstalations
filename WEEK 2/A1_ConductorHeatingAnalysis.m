% =========================================================================
% MAIN SCRIPT for Conductor Thermal Analysis (V3 - AC Effects & Log Conduction)
% =========================================================================
% Description:
% This script is the main entry point for a comprehensive conductor thermal
% analysis. It now performs all calculations for both DC resistance and AC
% resistance (including skin and proximity effects) to allow for direct
% comparison. It also uses the precise logarithmic formula for heat
% conduction through the cylindrical insulation.
%
% Author: Gemini
% Date: 2025-10-05
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- Define Physical Constants ---
T_env = 40;     % Environment temperature [°C]
T_ref = 20;     % Reference temperature for resistance [°C]

% Material Properties
rho_den_copper = 8960;      % Density of Copper [kg/m^3]
rho_den_aluminum = 2700;    % Density of Aluminum [kg/m^3]
cp_copper = 385;            % Specific Heat of Copper [J/(kg*°C)]
cp_aluminum = 900;          % Specific Heat of Aluminum [J/(kg*°C)]

% UPDATED: Added specific heat for insulators [J/(kg*°C)]
cp_pvc = 1000;  % 1 kJ/kgK
cp_xlpe = 2300; % 2.3 kJ/kgK
% Note: Insulator cp is stored but not used in the current transient model,
% which only considers the conductor's internal energy storage.

%% --- User Input ---
disp('--- Conductor Thermal Analysis Input ---');
lineLength = input('Enter the total line length [m] (e.g., 100): ');
crossSection = input('Enter conductor cross-sectional area [mm^2] (e.g., 50): ');
insulatorThickness = input('Enter insulator thickness [mm] (e.g., 1.2): ');
frequency = input('Enter the AC frequency in Hz (e.g., 50 or 60): '); % NEW input for AC effects
materialChoice = menu('Select Conductor Material:', 'Copper', 'Aluminum', 'ACSR');
insulationChoice = menu('Select Insulation Type:', 'PVC', 'XLPE');

%% --- Set Parameters based on User Choices ---
alpha = 0.00393; % Temp coefficient for resistance (Cu/Al) [1/°C]

switch materialChoice
    case 1 % Copper
        sigma = 56;
        materialName = 'Copper';
        density = rho_den_copper;
        specificHeat = cp_copper;
    case 2 % Aluminum
        sigma = 36;
        materialName = 'Aluminum';
        density = rho_den_aluminum;
        specificHeat = cp_aluminum;
    case 3 % ACSR
        sigma = 36;
        materialName = 'ACSR';
        density = rho_den_aluminum;
        specificHeat = cp_aluminum;
end

switch insulationChoice
    case 1 % PVC
        T_mat = 70;
        k = 0.19; % Thermal conductivity [W/(m*°C)]
        insulationName = 'PVC';
    case 2 % XLPE
        T_mat = 90;
        k = 0.35;
        insulationName = 'XLPE';
end

%% --- Resistance and Geometry Calculations ---
% UPDATED: Calculate radii for logarithmic conduction model
r_inner_m = sqrt(crossSection / pi) / 1000;      % Conductor radius [m]
r_outer_m = r_inner_m + (insulatorThickness / 1000); % Outer radius [m]

% Calculate DC resistance at reference temperature
R_20_DC = lineLength / (sigma * crossSection);

% UPDATED: Calculate AC resistance at reference temperature
[k_skin, k_proximity] = A3b_AC_Resistance_Factor(frequency, r_inner_m * 2, sigma);
R_20_AC = R_20_DC * (1 + k_skin + k_proximity);

%% --- Steady-State Analysis (DC vs AC) ---
% Calculate Max Current for both DC and AC resistance
I_max_DC = A2_MaximumCurrent(R_20_DC, alpha, T_mat, T_ref, T_env, k, lineLength, r_inner_m, r_outer_m);
I_max_AC = A2_MaximumCurrent(R_20_AC, alpha, T_mat, T_ref, T_env, k, lineLength, r_inner_m, r_outer_m);

%% --- Display Comparative Steady-State Results ---
fprintf('\n--- STEADY-STATE CALCULATION RESULTS ---\n');
fprintf('Conductor: %s, Insulation: %s @ %.1f Hz\n', materialName, insulationName, frequency);
fprintf('DC Resistance at 20°C: %.5f Ohms\n', R_20_DC);
fprintf('AC Resistance at 20°C: %.5f Ohms (Skin+Proximity Factor: %.3f)\n', R_20_AC, (1 + k_skin + k_proximity));
fprintf('--------------------------------------------------\n');
fprintf('Max Current (I_max) based on DC Resistance: %.2f A\n', I_max_DC);
fprintf('Max Current (I_max) based on AC Resistance: %.2f A\n', I_max_AC);
fprintf('AC effects reduce the max current capacity by %.2f%%.\n', (1 - I_max_AC/I_max_DC)*100);
fprintf('--------------------------------------------------\n');

%% --- Steady-State Visualization (DC vs AC) ---
A5_HeatingCurves(I_max_DC, I_max_AC, T_mat, T_env, R_20_DC, R_20_AC, alpha, T_ref, k, lineLength, r_inner_m, r_outer_m, materialName, insulationName);

%% --- Transient Analysis Section (DC vs AC) ---
fprintf('\n--- TRANSIENT ANALYSIS ---\n');
sim_current = input(sprintf('Enter a current to simulate (e.g., %.0f A): ', I_max_AC * 0.8));

% Calculate conductor mass
volume = (crossSection / 1e6) * lineLength;
mass = volume * density;

% Define simulation time span
time_span = [0 3600]; % Simulate for 1 hour

% Run transient simulation for both DC and AC resistances
[time_dc, temp_dc] = A6_TransientHeating(sim_current, time_span, T_env, R_20_DC, alpha, T_ref, k, lineLength, r_inner_m, r_outer_m, mass, specificHeat);
[time_ac, temp_ac] = A6_TransientHeating(sim_current, time_span, T_env, R_20_AC, alpha, T_ref, k, lineLength, r_inner_m, r_outer_m, mass, specificHeat);

% --- Transient Visualization (DC vs AC) ---
figure;
hold on;
plot(time_dc/60, temp_dc, 'b-', 'LineWidth', 2, 'DisplayName', 'Temp Rise (DC Res.)');
plot(time_ac/60, temp_ac, 'r-', 'LineWidth', 2, 'DisplayName', 'Temp Rise (AC Res.)');

% Calculate and plot final steady-state lines for comparison
T_ss_dc = A4_ThermalEquilibrium(sim_current, R_20_DC, alpha, T_ref, T_env, k, lineLength, r_inner_m, r_outer_m);
T_ss_ac = A4_ThermalEquilibrium(sim_current, R_20_AC, alpha, T_ref, T_env, k, lineLength, r_inner_m, r_outer_m);
line([0, time_ac(end)/60], [T_ss_dc, T_ss_dc], 'Color', 'b', 'LineStyle', '--', 'DisplayName', sprintf('SS Temp (DC) %.1f°C', T_ss_dc));
line([0, time_ac(end)/60], [T_ss_ac, T_ss_ac], 'Color', 'r', 'LineStyle', '--', 'DisplayName', sprintf('SS Temp (AC) %.1f°C', T_ss_ac));

title(sprintf('Transient Heating Comparison for %.1f A', sim_current));
xlabel('Time (minutes)');
ylabel('Conductor Temperature (°C)');
grid on;
legend('show', 'Location', 'southeast');
fprintf('Transient analysis complete. See new comparative plot.\n');

