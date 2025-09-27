% --- Basic Line Calculations for Student Scenarios (Problem 3) ---
%
% This script implements the fundamental formulas for electrical line
% analysis as specified in the project document. It calculates the
% electrical resistance, load current, and per-phase voltage drop for the
% unique parameters assigned to Students A, B, and C.
%
% The final output is a single comparison table, which is ideal for
% technical reports and presentations.

% --- Initial Setup ---
clear;          % Clear workspace variables
clc;            % Clear command window
close all;      % Close all figures

% --- 1. Define Calculation Functions ---

% Function to calculate DC Resistance based on Formula (1)
function R = calculateResistance(L, sigma, s)
    % Calculates the resistance of a conductor.
    % Inputs:
    %   L     - Length of the conductor in meters (m)
    %   sigma - Electrical conductivity in m/(Ohm*mm^2)
    %   s     - Cross-sectional area in square millimeters (mm^2)
    % Output:
    %   R     - Resistance in Ohms (Ω)
    R = L / (sigma * s);
end

% Function to calculate Three-Phase Current based on Formula (2)
function I = calculateCurrent3ph(P_kW, V_V, cos_phi)
    % Calculates the current in a balanced three-phase system.
    % Inputs:
    %   P_kW    - Active Power in kilowatts (kW)
    %   V_V     - Line-to-line Voltage in Volts (V)
    %   cos_phi - Power factor (dimensionless)
    % Output:
    %   I       - Current in Amperes (A)
    P_W = P_kW * 1000; % Convert power from kW to W
    I = P_W / (sqrt(3) * V_V * cos_phi);
end

% Function to calculate the Voltage Drop per Phase
function V_drop = calculateVoltageDropPhase(I, R)
    % Calculates the voltage drop across a single phase conductor.
    % Inputs:
    %   I - Current in Amperes (A)
    %   R - Resistance in Ohms (Ω)
    % Output:
    %   V_drop - Phase voltage drop in Volts (V)
    V_drop = I * R;
end

% --- 2. Define Shared Parameters and Assumptions ---

% These parameters are common for all student calculations in this problem.
V_line_V = 400;         % Assumed standard Low Voltage (BT) of 400 V
sigma_copper = 56;      % Conductivity for Copper
s_conductor_mm2 = 95;   % Assumed conductor cross-section of 95 mm^2

fprintf('--- Calculation Assumptions ---\n');
fprintf('Line Voltage: %.0f V (Three-Phase)\n', V_line_V);
fprintf('Conductor Material: Copper (sigma = %.0f)\n', sigma_copper);
fprintf('Conductor Cross-Section: %.0f mm^2\n\n', s_conductor_mm2);

% --- 3. Define Student-Specific Parameters ---

% A table is used to neatly store each student's unique scenario data.
student_data = table(...
    {'A'; 'B'; 'C'}, ... % Student ID
    [500; 1200; 2500], ... % Length (L) in meters
    [50; 150; 300], ...   % Power (P) in kW
    [0.80; 0.90; 0.85], ... % Power Factor (cos_phi)
    'VariableNames', {'Student', 'Length_m', 'Power_kW', 'PowerFactor'} ...
);

% --- 4. Perform Calculations and Generate Comparison Table ---

% Initialize arrays to store the results
calculated_resistance = zeros(height(student_data), 1);
calculated_current = zeros(height(student_data), 1);
calculated_vdrop_phase = zeros(height(student_data), 1);

% Loop through each row of the student data table
for i = 1:height(student_data)
    % Retrieve parameters for the current student
    L = student_data.Length_m(i);
    P = student_data.Power_kW(i);
    pf = student_data.PowerFactor(i);
    
    % Call the functions to perform the calculations
    calculated_resistance(i) = calculateResistance(L, sigma_copper, s_conductor_mm2);
    calculated_current(i) = calculateCurrent3ph(P, V_line_V, pf);
    calculated_vdrop_phase(i) = calculateVoltageDropPhase(calculated_current(i), calculated_resistance(i));
end

% Add the results as new columns to our table
student_data.Resistance_Ohms = calculated_resistance;
student_data.Current_Amps = calculated_current;
student_data.VoltageDrop_Phase_V = calculated_vdrop_phase;

% --- 5. Display the Final Comparison Table ---
fprintf('--- Results: Comparison Table ---\n');
disp(student_data);

