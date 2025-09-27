% MATLAB Script for Week 2: Advanced Line Calculations
% Project: Electrical Lines and Distribution Networks
% Student: C (Commercial Center)
%
% This script implements advanced AC line parameter calculations, including:
% 1. AC Resistance, considering the skin effect.
% 2. Inductive Reactance of the line.
% 3. Voltage Drop using the accurate Blondel formula.
% It then applies these calculations to Student C's scenario from Week 1.

% --- Initial Setup ---
clear;
clc;
close all;

% --- 1. Define Advanced Calculation Functions ---

function R_ac = calculateACResistance(R_dc, f, s)
    % Calculates AC resistance considering the skin effect.
    % A simplified model is used where the skin effect factor (ks) is
    % approximated based on the cross-sectional area. This is a common
    % approach for initial design calculations at 50Hz. For larger
    % conductors, ks becomes more significant.
    %
    % Inputs:
    %   R_dc - DC resistance in Ohms
    %   f    - Frequency in Hz
    %   s    - Cross-sectional area in mm^2
    % Output:
    %   R_ac - AC resistance in Ohms

    % Approximate skin effect factor (ks) for 50Hz.
    % For sections < 95mm^2, the effect is minimal (ks approx 1).
    % For larger sections, it increases. This is a simplified table.
    if s <= 95
        k_s = 1.01;
    elseif s <= 150
        k_s = 1.05;
    elseif s <= 240
        k_s = 1.10;
    else
        k_s = 1.15;
    end
    
    R_ac = R_dc * k_s;
end

function X = calculateReactance(L, s, D)
    % Calculates the inductive reactance of one conductor in a 3-phase line.
    % Formula: X = 2*pi*f * L * (2e-7 * log(D/GMR))
    % Where GMR (Geometric Mean Radius) for a solid conductor is approx. 0.7788 * radius.
    %
    % Inputs:
    %   L - Line length in meters
    %   s - Cross-sectional area in mm^2
    %   D - Equivalent distance between conductors in meters
    % Output:
    %   X - Total inductive reactance in Ohms

    f = 50; % Frequency in Hz
    radius_m = sqrt(s / pi) / 1000; % Conductor radius in meters
    gmr = 0.7788 * radius_m;       % Geometric Mean Radius
    
    % Inductance per meter (H/m)
    inductance_per_meter = 2e-7 * log(D / gmr);
    
    % Total Reactance
    X = 2 * pi * f * L * inductance_per_meter;
end

function [deltaV, deltaV_percent] = calculateBlondelVoltageDrop(I, R_ac, X, pf, V_L)
    % Calculates three-phase voltage drop using Blondel's formula.
    % Formula: dV = sqrt(3) * I * (R*cos(phi) + X*sin(phi))
    %
    % Inputs:
    %   I           - Line current in Amps
    %   R_ac        - AC resistance in Ohms
    %   X           - Line reactance in Ohms
    %   pf          - Power factor (cos(phi))
    %   V_L         - Line-to-line voltage in Volts
    % Outputs:
    %   deltaV        - Voltage drop in Volts
    %   deltaV_percent- Voltage drop as a percentage of V_L

    phi = acos(pf); % Get the angle from the power factor
    sin_phi = sin(phi);
    
    deltaV = sqrt(3) * I * (R_ac * pf + X * sin_phi);
    deltaV_percent = (deltaV / V_L) * 100;
end

% --- 2. Define Scenario Parameters for Student C ---

% Load and Line parameters from Week 1
L = 2500;         % meters
P_kW = 300;       % kilowatts
pf = 0.85;        % Power factor (inductive)
V_L = 400;        % Volts (BT network)

% Material Properties for Aluminum
sigma_al = 36;    % Conductivity in m/(Ohm*mm^2)
D_equiv = 0.4;    % Assumed equivalent distance between conductors (m) for BT lines

% Standardized Aluminum conductor cross-sections (mm^2) for simulation
sections_s = [70, 95, 120, 150, 185, 240];

% --- 3. Perform Advanced Calculations ---

% Calculate the load current (constant for this power)
I = (P_kW * 1000) / (V_L * sqrt(3) * pf);

% Pre-allocate arrays to store results
results = zeros(length(sections_s), 5);

for i = 1:length(sections_s)
    s = sections_s(i);
    
    % a) Calculate DC Resistance (from Week 1)
    R_dc = L / (sigma_al * s);
    
    % b) Calculate AC Resistance (New for Week 2)
    R_ac = calculateACResistance(R_dc, 50, s);
    
    % c) Calculate Reactance (New for Week 2)
    X = calculateReactance(L, s, D_equiv);
    
    % d) Calculate Voltage Drop with Blondel's Formula (New for Week 2)
    [deltaV, deltaV_percent] = calculateBlondelVoltageDrop(I, R_ac, X, pf, V_L);
    
    % Store results
    results(i, :) = [s, R_dc, R_ac, X, deltaV_percent];
end

% --- 4. Display Results in a Comparison Table ---

% Create a MATLAB table for professional display
resultsTable = array2table(results, ...
    'VariableNames', {'Section_mm2', 'R_DC_Ohms', 'R_AC_Ohms', 'Reactance_Ohms', 'VoltageDrop_Percent'});

disp('--- Week 2: Advanced Calculation Results for Student C ---');
fprintf('Load: %.0f kW | Distance: %.0f m | Power Factor: %.2f\n\n', P_kW, L, pf);
disp(resultsTable);

% REBT Compliance Check
% Max voltage drop for a private distribution line is 6.5%
rebt_limit = 6.5;
resultsTable.REBT_Compliant = resultsTable.VoltageDrop_Percent <= rebt_limit;

disp('--- REBT Compliance Check (Max Voltage Drop <= 6.5%) ---');
disp(resultsTable(:, {'Section_mm2', 'VoltageDrop_Percent', 'REBT_Compliant'}));

% Find the most economical compliant section
compliant_sections = resultsTable.Section_mm2(resultsTable.REBT_Compliant);
if ~isempty(compliant_sections)
    economical_choice = min(compliant_sections);
    fprintf('\nRecommended economical section size: %d mm^2\n', economical_choice);
else
    fprintf('\nWarning: None of the simulated sections meet the REBT voltage drop limit.\n');
end
