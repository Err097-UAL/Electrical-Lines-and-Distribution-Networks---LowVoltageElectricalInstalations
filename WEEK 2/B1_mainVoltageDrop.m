% =========================================================================
% MAIN SCRIPT for Voltage Drop Analysis
% =========================================================================
% Description:
% This script serves as the main entry point for calculating the voltage
% drop in a low-voltage electrical line. It gathers all necessary
% parameters from the user, including line characteristics, load details,
% and circuit type. It then calls specialized functions to compute the
% exact and simplified voltage drops, check for compliance with REBT
% standards, and generate a voltage profile plot.
%
% How to Run:
% 1. Ensure all function files are in the same directory:
%    - calculateExactVoltageDrop.m
%    - calculateSimplifiedVoltageDrop.m
%    - checkREBTCompliance.m
%    - plotVoltageProfile.m
% 2. Run this script from the MATLAB command window or editor.
%
% Author: Gemini
% Date: 2025-09-28
% =========================================================================

%% --- Cleanup and Initialization ---
clc;            % Clear the command window
clear;          % Clear all variables from the workspace
close all;      % Close all open figure windows

%% --- Define Physical Constants ---
rho_copper = 0.0172;   % Resistivity of Copper [Ohm * mm^2 / m]
rho_aluminum = 0.0282; % Resistivity of Aluminum [Ohm * mm^2 / m]

%% --- User Input ---
disp('--- Voltage Drop Calculation Input ---');

% Get System Parameters
U_source = input('Enter the source voltage (phase-to-neutral for single-phase, phase-to-phase for three-phase) in Volts (e.g., 230): ');
lineTypeChoice = menu('Select Line Type:', 'Single-Phase', 'Three-Phase');
circuitTypeChoice = menu('Select Circuit Type (for REBT check):', 'Lighting', 'Power (Other Uses)');

% Get Line Parameters
lineLength = input('Enter the total line length in meters: ');
crossSection = input('Enter the conductor cross-sectional area in mm^2: ');
materialChoice = menu('Select Conductor Material:', 'Copper', 'Aluminum');
reactance_per_km = input('Enter the line reactance in Ohm/km (e.g., 0.08): ');
reactance = reactance_per_km / 1000; % Convert to Ohm/m

% Get Load Parameters
loadCurrent = input('Enter the load current in Amperes: ');
cos_phi = input('Enter the power factor (cos φ) of the load (e.g., 0.95): ');
if cos_phi > 1 || cos_phi < 0
    error('Invalid power factor. Please enter a value between 0 and 1.');
end

%% --- Pre-Calculations ---

% Determine Line Type String
if lineTypeChoice == 1
    lineType = 'single-phase';
else
    lineType = 'three-phase';
end

% Determine Circuit Type String
if circuitTypeChoice == 1
    circuitType = 'lighting';
else
    circuitType = 'power';
end

% Calculate resistance per unit length (r) in Ohm/m
if materialChoice == 1 % Copper
    resistivity = rho_copper;
    materialName = 'Copper';
else % Aluminum
    resistivity = rho_aluminum;
    materialName = 'Aluminum';
end
resistance_per_meter = resistivity / crossSection; % [Ohm/m]

%% --- Core Calculations ---

% 1. Calculate Exact Voltage Drop using Blondel's formula
deltaU_exact = B2_calculateExactVoltageDrop(lineType, lineLength, loadCurrent, resistance_per_meter, reactance, cos_phi);

% 2. Calculate Simplified Voltage Drop (resistive only)
deltaU_simplified = B3_calculateSimplifiedVoltageDrop(lineType, lineLength, loadCurrent, resistance_per_meter, cos_phi);

% 3. Check for REBT Compliance
[isCompliant, percentDrop, limit] = B4_checkREBTCompliance(deltaU_exact, U_source, circuitType);

%% --- Display Results ---
fprintf('\n--- Calculation Results ---\n');
fprintf('Line Type: %s, Circuit: %s\n', lineType, circuitType);
fprintf('Conductor: %s, %.2f mm^2, Length: %.1f m\n', materialName, crossSection, lineLength);
fprintf('Source Voltage: %.1f V, Load: %.1f A at PF %.2f\n', U_source, loadCurrent, cos_phi);
fprintf('--------------------------------------------------\n');
fprintf('Exact Voltage Drop (Blondel): %.2f V\n', deltaU_exact);
fprintf('Simplified Voltage Drop (Resistive): %.2f V\n', deltaU_simplified);
fprintf('Voltage at Load: %.2f V\n', U_source - deltaU_exact);
fprintf('--------------------------------------------------\n');
fprintf('REBT Compliance Check:\n');
fprintf('Calculated Voltage Drop: %.2f%%\n', percentDrop);
fprintf('Allowable Limit for %s circuits: %.1f%%\n', circuitType, limit);
if isCompliant
    fprintf('Status: COMPLIANT\n');
else
    fprintf('Status: NOT COMPLIANT\n');
end
fprintf('--------------------------------------------------\n');

%% --- Visualization ---
B5_plotVoltageProfile(U_source, deltaU_exact, lineLength, circuitType);
disp('Analysis complete.');
