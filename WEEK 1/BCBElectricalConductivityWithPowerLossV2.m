% --- Electrical Performance Comparison of Conductor Materials ---
%
% This script calculates and visualizes:
% 1. The progressive voltage drop over distance for different conductors.
% 2. The maximum admissible current (intensidad máxima admisible).
% 3. The progressive power loss (I²R) over distance.
% 4. A compliance check against REBT voltage drop limits.
% 5. The progressive installation cost over distance.
%
% Assumptions:
% - System: Three-phase, 400 V
% - Load for Voltage Drop & Power Loss: 1 kVA (1000 VA)
% - Conductor Cross-Section: 2.5 mm^2
% - REBT Voltage Drop Limit: 5% for general use (L.A.I.)

% --- Initial Setup ---
clear;          % Clear workspace variables
clc;            % Clear command window
close all;      % Close all figures

% --- Define Constants and Material Properties ---
% System and Load Parameters
S_va = 1000;         % Apparent Power in VA
V_v = 400;           % Line Voltage in Volts
s_mm2 = 2.5;         % Conductor cross-sectional area in mm^2

% REBT Compliance
rebt_v_drop_percent = 5; % 5% limit for LAI (Líneas generales de alimentación)
rebt_v_limit = (rebt_v_drop_percent / 100) * V_v;

% Material Properties
materials = {'Copper', 'Aluminum (AAC)', 'ACSR'};
conductivity = [56, 36, 34]; % Conductivity (sigma) in m/(Ohm*mm^2)

% Maximum Admissible Current (I_max) in Amperes for 2.5 mm^2
% Values are approximate based on REBT ITC-BT-19 for insulated cables.
i_max_amps = [21, 16, 16]; % [Copper, Aluminum, ACSR]

% Illustrative Cost per kilometer for a 2.5 mm^2 equivalent line
% These values include material and basic installation labor estimates.
cost_per_km = [1200, 700, 850]; % [Copper, Aluminum, ACSR] in Euros

% --- Calculations ---
% Calculate the load current for the voltage drop simulation
I_load_a = S_va / (sqrt(3) * V_v);

% Define a range of distances for the line graph
distances_km = 0:0.1:2; % From 0 to 2 km in 100m steps
distances_m = distances_km * 1000;

% --- Graph 1: Progressive Voltage Drop vs. Distance ---

figure; 
hold on; 
colors = {'#0072BD', '#D95319', '#77AC30'}; 

for i = 1:length(materials)
    R_ohm = distances_m / (conductivity(i) * s_mm2);
    voltage_drop = sqrt(3) * I_load_a * R_ohm;
    plot(distances_km, voltage_drop, 'LineWidth', 2, 'Color', colors{i});
end

% Add REBT limit line
plot(distances_km, ones(size(distances_km)) * rebt_v_limit, 'r--', 'LineWidth', 2);
legend_materials = [materials, ['REBT ' num2str(rebt_v_drop_percent) '% Limit']];

hold off;
title('Progressive Voltage Drop vs. Distance', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Distance (km)', 'FontSize', 12);
ylabel('Voltage Drop (V)', 'FontSize', 12);
legend(legend_materials, 'Location', 'northwest');
grid on;

% --- Graph 2: Maximum Admissible Current (I_max) Comparison ---

[sorted_i_max, sort_order_i] = sort(i_max_amps);
sorted_names_i = materials(sort_order_i);

figure;
bar(sorted_i_max, 'FaceColor', '#7E2F8E');
title('Maximum Admissible Current (I_{max}) for 2.5 mm^2 Conductor', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Current (A)', 'FontSize', 12);
xlabel('Conductor Material', 'FontSize', 12);
set(gca, 'xticklabel', sorted_names_i);
grid on;
text(1:length(sorted_names_i), sorted_i_max, num2str(sorted_i_max', '%.1f A'), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% --- Graph 3: Progressive Power Loss (I²R) vs. Distance ---

figure;
hold on;

for i = 1:length(materials)
    % Calculate resistance for the entire distance vector
    R_ohm = distances_m / (conductivity(i) * s_mm2);
    
    % Calculate Power Loss (P_loss = 3 * I^2 * R for three-phase)
    power_loss_watts = 3 * (I_load_a^2) * R_ohm;
    
    % Plot the results
    plot(distances_km, power_loss_watts, 'LineWidth', 2, 'Color', colors{i});
end

hold off;
title('Progressive Power Loss vs. Distance', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Distance (km)', 'FontSize', 12);
ylabel('Power Loss (Watts)', 'FontSize', 12);
legend(materials, 'Location', 'northwest');
grid on;

% --- Graph 4: Progressive Installation Cost vs. Distance ---
figure;
hold on;

for i = 1:length(materials)
    % Calculate total cost over the distance vector
    total_cost = cost_per_km(i) * distances_km;
    
    % Plot the results
    plot(distances_km, total_cost, 'LineWidth', 2, 'Color', colors{i});
end

hold off;
title('Progressive Installation Cost vs. Distance', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Distance (km)', 'FontSize', 12);
ylabel('Total Cost (€)', 'FontSize', 12);
legend(materials, 'Location', 'northwest');
grid on;


% --- Display Key Information and REBT Check in Command Window ---
fprintf('--- Simulation Parameters ---\n');
fprintf('Load for Voltage Drop & Loss Test: %.2f A\n', I_load_a);
fprintf('Conductor Cross-Section: %.1f mm^2\n\n', s_mm2);

fprintf('--- Maximum Admissible Current (I_max) ---\n');
fprintf('  - %s: %.1f A\n', materials{1}, i_max_amps(1));
fprintf('  - %s: %.1f A\n', materials{2}, i_max_amps(2));
fprintf('  - %s: %.1f A\n\n', materials{3}, i_max_amps(3));

fprintf('--- Illustrative Installation Cost ---\n');
fprintf('  - %s: %.2f €/km\n', materials{1}, cost_per_km(1));
fprintf('  - %s: %.2f €/km\n', materials{2}, cost_per_km(2));
fprintf('  - %s: %.2f €/km\n\n', materials{3}, cost_per_km(3));

fprintf('--- REBT Voltage Drop Compliance Check at 1 km ---\n');
fprintf('Maximum allowed voltage drop: %.2f V (%.1f%% of %d V)\n', rebt_v_limit, rebt_v_drop_percent, V_v);
for i = 1:length(materials)
    R_at_1km = 1000 / (conductivity(i) * s_mm2);
    V_drop_at_1km = sqrt(3) * I_load_a * R_at_1km;
    if V_drop_at_1km <= rebt_v_limit
        status = 'PASS';
    else
        status = 'FAIL';
    end
    fprintf('  - %s: %.2f V drop. Status: %s\n', materials{i}, V_drop_at_1km, status);
end

