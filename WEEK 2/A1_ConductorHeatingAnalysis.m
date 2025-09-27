% =========================================================================
% MAIN SCRIPT for Conductor Thermal Analysis
% =========================================================================
% Description:
% This script serves as the main entry point for the conductor heating
% analysis. It prompts the user for necessary inputs such as line length,
% conductor material, and insulation type. It then calls a series of
% functions to calculate key thermal performance metrics, including the
% maximum allowable current and the conductor's equilibrium temperature
% across a range of currents. Finally, it visualizes the results.
%
% How to Run:
% 1. Ensure all required function files are in the same directory:
%    - A2_MaximumCurrent.m
%    - correctResistanceForTemp.m
%    - solveThermalEquilibrium.m
%    - plotHeatingCurves.m
% 2. Run this script from the MATLAB command window or editor.
%
% Author: Gemini
% Date: 2025-09-27
% =========================================================================

%% --- Cleanup and Initialization ---
clc;            % Clear the command window
clear;          % Clear all variables from the workspace
close all;      % Close all open figure windows

%% --- Define Physical Constants ---
T_env = 40;     % Environment temperature in Celsius [°C]
T_ref = 20;     % Reference temperature for resistance calculation in Celsius [°C]

%% --- User Input ---
disp('--- Conductor Thermal Analysis Input ---');

% Get Line Length (in meters)
lineLength = input('Enter the line length in meters (e.g., 1000): ');

% Get Conductor Cross-Sectional Area (in mm^2)
crossSection = input('Enter the conductor cross-sectional area in mm^2 (e.g., 95): ');

% Get Conductor Material
conductorChoice = menu('Select Conductor Material:', 'Copper', 'Aluminum', 'ACSR');
switch conductorChoice
    case 1 % Copper
        sigma = 56; % Electrical conductivity [m / (Ohm * mm^2)]
        alpha = 0.00393; % Temperature coefficient of resistance [1/°C]
        materialName = 'Copper';
    case 2 % Aluminum
        sigma = 36; % Electrical conductivity [m / (Ohm * mm^2)]
        alpha = 0.00429; % Temperature coefficient of resistance [1/°C]
        materialName = 'Aluminum';
    case 3 % ACSR
        sigma = 36; % Using Aluminum value as per prompt
        alpha = 0.00429; % Using Aluminum value as per prompt
        materialName = 'ACSR';
end

% Get Insulation Type
insulationChoice = menu('Select Insulation Type:', 'PVC', 'XLPE');
switch insulationChoice
    case 1 % PVC
        T_mat = 70; % Max material temperature [°C]
        k = 0.19; % Thermal conductivity / dissipation factor [W / (m^2 * °C)]
        insulationName = 'PVC';
    case 2 % XLPE
        T_mat = 90; % Max material temperature [°C]
        k = 0.35; % Thermal conductivity / dissipation factor [W / (m^2 * °C)]
        insulationName = 'XLPE';
end

%% --- Core Calculations ---

% Calculate conductor diameter assuming a circular cross-section
% Area = pi * (D/2)^2  => D = sqrt(4 * Area / pi)
% Convert from mm to m for surface area calculations
diameter = sqrt(4 * crossSection / pi) / 1000; % [m]

% Calculate baseline electrical resistance at reference temperature (20°C)
% R = length / (conductivity * area)
R_20 = lineLength / (sigma * crossSection); % [Ohm]

% Calculate the maximum allowable continuous current
I_max = A2_MaximumCurrent(R_20, alpha, T_mat, T_ref, T_env, k, diameter, lineLength);

%% --- Display Results ---
fprintf('\n--- Calculation Results ---\n');
fprintf('Conductor Material: %s\n', materialName);
fprintf('Insulation Type: %s\n', insulationName);
fprintf('Line Length: %.2f m\n', lineLength);
fprintf('Cross-Section: %.2f mm^2\n', crossSection);
fprintf('Resistance at 20°C: %.4f Ohms\n', R_20);
fprintf('--------------------------------------------------\n');
fprintf('Maximum Allowable Current (I_max): %.2f A\n', I_max);
fprintf('This is the current that brings the conductor to its maximum safe temperature of %.1f°C.\n', T_mat);
fprintf('--------------------------------------------------\n');

%% --- Visualization ---
% Generate and display the heating curve
A5_HeatingCurves(I_max, T_mat, T_env, R_20, alpha, T_ref, k, diameter, lineLength, materialName, insulationName)
disp('Analysis complete.');
