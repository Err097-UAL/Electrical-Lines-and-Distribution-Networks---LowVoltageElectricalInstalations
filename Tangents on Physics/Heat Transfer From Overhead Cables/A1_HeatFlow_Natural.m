% =========================================================================
% MAIN SCRIPT: THERMAL ANALYSIS OF AN XLPE INSULATED CABLE
% =========================================================================
% This script calculates the maximum current (ampacity) a cable can carry
% based on steady-state heat transfer principles.
%
% It models three stages of heat flow:
% 1. Heat Generation: Joule effect in the copper conductor.
% 2. Heat Conduction: Through the XLPE insulation.
% 3. Heat Convection: From the insulation surface to ambient air via
%    natural convection (worst-case scenario).
%
% The script uses an iterative solver to find the equilibrium state where
% heat generated equals heat dissipated.

clear; clc; close all;

%% 1. DEFINE CONSTANTS AND PARAMETERS

% -- Boundary Conditions
T_conductor_max = 90 + 273.15;  % Max conductor temp [K] (90 C)
T_infinity = 40 + 273.15;     % Ambient air temp [K] (40 C)

% -- Cable Geometry
r_i = 2.5e-3;       % Conductor radius [m] (e.g., 2.5 mm for a ~16mm^2 cable)
thickness = 1.0e-3; % Insulation thickness [m] (1.0 mm)
r_o = r_i + thickness; % Outer radius of insulation [m]
L = 1.0;            % Cable length [m] (for calculation per meter)

% -- Material Properties
% Copper Conductor
resistivity_cu = 1.68e-8; % Electrical resistivity of Copper [Ohm·m]
A_cu = pi * r_i^2;       % Cross-sectional area of conductor [m^2]
R_ohm = (resistivity_cu * L) / A_cu; % Electrical resistance [Ohm]

% XLPE Insulation
k_xlpe = 0.3; % Thermal conductivity of XLPE [W/m·K]

%% 2. SOLVE FOR EQUILIBRIUM HEAT FLOW AND SURFACE TEMPERATURE
% We need to find the state where heat flow through conduction (driven by
% T_conductor_max) equals heat flow through convection. This is handled
% by the iterative solver.

fprintf('Starting iterative solver to find equilibrium...\n');
[Q_max, T_surface, hc, Nu] = A2_solve_thermal_equilibrium(r_i, r_o, L, k_xlpe, T_conductor_max, T_infinity);
fprintf('Solver converged.\n\n');

%% 3. CALCULATE MAXIMUM CURRENT (AMPACITY)
% From the maximum permissible heat flow (Q_max), we find the
% corresponding maximum current I_max.
% Q = I^2 * R  =>  I = sqrt(Q / R)
I_max = sqrt(Q_max / R_ohm);

%% 4. DISPLAY RESULTS
fprintf('--- CABLE ANALYSIS RESULTS ---\n');
fprintf('Conductor Radius (r_i):      %.2f mm\n', r_i * 1000);
fprintf('Insulation Thickness:        %.2f mm\n', thickness * 1000);
fprintf('Outer Radius (r_o):          %.2f mm\n\n', r_o * 1000);

fprintf('Max Conductor Temperature:   %.1f C\n', T_conductor_max - 273.15);
fprintf('Ambient Air Temperature:     %.1f C\n\n', T_infinity - 273.15);

fprintf('Equilibrium Surface Temp:    %.1f C\n', T_surface - 273.15);
fprintf('Convection Coeff. (hc):      %.2f W/m^2·K\n', hc);
fprintf('Nusselt Number (Nu):         %.2f\n\n', Nu);

fprintf('Max Heat Dissipation (Q_max):  %.2f W/m\n', Q_max);
fprintf('MAXIMUM ALLOWABLE CURRENT (Ampacity): %.1f A\n', I_max);
fprintf('------------------------------------\n');

%% 5. VISUALIZE THE RESULTS
% Plot the temperature profile from the conductor to the surface.
A3_plot_temperature_profile(r_i, r_o, T_conductor_max, T_surface);
