% =========================================================================
% SCRIPT: PARAMETRIC "WHAT-IF" ANALYSIS
% =========================================================================
% This script investigates how the cable's ampacity (maximum current)
% is affected by changing key design parameters:
% 1. Conductor Radius (and thus, cable diameter)
% 2. Insulation Thickness

clear; clc; close all;

%% SETUP - Define base parameters (should match main script)
T_conductor_max = 90 + 273.15;
T_infinity = 40 + 273.15;
L = 1.0;
k_xlpe = 0.3;
resistivity_cu = 1.68e-8;

%% ANALYSIS 1: EFFECT OF CONDUCTOR RADIUS
fprintf('Running Analysis 1: Varying Conductor Radius...\n');
radius_range = linspace(1.5e-3, 50e-3, 100); % from 1.5mm to 50mm radius
insulation_thickness_const = 1.2e-3; % Keep insulation thickness constant
ampacity_vs_radius = zeros(size(radius_range));

for i = 1:length(radius_range)
    r_i_current = radius_range(i);
    r_o_current = r_i_current + insulation_thickness_const;
    
    % Solve for max heat flow for this geometry
    [Q_max, ~, ~, ~] = A2_solve_thermal_equilibrium(r_i_current, r_o_current, L, k_xlpe, T_conductor_max, T_infinity);
    
    % Calculate corresponding ampacity
    R_ohm = (resistivity_cu * L) / (pi * r_i_current^2);
    ampacity_vs_radius(i) = sqrt(Q_max / R_ohm);
end

% Plotting the results
figure('Name', 'Parametric Analysis: Conductor Radius');
plot(radius_range * 1000, ampacity_vs_radius, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
title('Effect of Conductor Radius on Ampacity');
xlabel('Conductor Radius (mm)');
ylabel('Maximum Current / Ampacity (A)');
grid on;

%% ANALYSIS 2: EFFECT OF INSULATION THICKNESS
fprintf('Running Analysis 2: Varying Insulation Thickness...\n');
thickness_range = linspace(0.8e-3, 50e-3, 100); % from 0.8mm to 50mm thick
radius_const = 2.5e-3; % Keep conductor radius constant
ampacity_vs_thickness = zeros(size(thickness_range));

for i = 1:length(thickness_range)
    r_o_current = radius_const + thickness_range(i);
    
    % Solve for max heat flow for this geometry
    [Q_max, ~, ~, ~] = A2_solve_thermal_equilibrium(radius_const, r_o_current, L, k_xlpe, T_conductor_max, T_infinity);
    
    % Calculate corresponding ampacity (Resistance is constant here)
    R_ohm = (resistivity_cu * L) / (pi * radius_const^2);
    ampacity_vs_thickness(i) = sqrt(Q_max / R_ohm);
end

% Plotting the results
figure('Name', 'Parametric Analysis: Insulation Thickness');
plot(thickness_range * 1000, ampacity_vs_thickness, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
title('Effect of Insulation Thickness on Ampacity');
xlabel('Insulation Thickness (mm)');
ylabel('Maximum Current / Ampacity (A)');
grid on;
fprintf('All analyses complete.\n');
