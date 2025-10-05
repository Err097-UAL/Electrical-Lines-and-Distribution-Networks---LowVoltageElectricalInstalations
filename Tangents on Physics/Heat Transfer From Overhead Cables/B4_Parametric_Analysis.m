% =========================================================================
% SCRIPT: PARAMETRIC "WHAT-IF" ANALYSIS FOR FORCED CONVECTION
% =========================================================================
% Investigates how ampacity is affected by:
% 1. Conductor Radius
% 2. Insulation Thickness
% 3. Air Velocity (Wind Speed) - The most critical factor in this model

clear; clc; close all;

%% SETUP - Define base parameters
T_conductor_max = 90 + 273.15;
T_infinity = 40 + 273.15;
L = 1.0;
k_xlpe = 0.3;
resistivity_cu = 1.68e-8;


%% ANALYSIS EFFECT OF AIR VELOCITY (at constant geometry)
fprintf('Running Analysis 3: Varying Air Velocity...\n');
velocity_range = linspace(0.1, 5.0, 20); % from 0.1 m/s (still air) to 5 m/s (moderate breeze)
radius_const3 = 2.5e-3;
thickness_const3 = 1.2e-3;
r_o_const3 = radius_const3 + thickness_const3;
ampacity_vs_velocity = zeros(size(velocity_range));

for i = 1:length(velocity_range)
    v_air_current = velocity_range(i);
    [Q_max, ~] = B2_solve_thermal_equilibrium_forced(radius_const3, r_o_const3, L, k_xlpe, T_conductor_max, T_infinity, v_air_current);
    R_ohm = (resistivity_cu * L) / (pi * radius_const3^2);
    ampacity_vs_velocity(i) = sqrt(Q_max / R_ohm);
end

figure('Name', 'Parametric: Air Velocity');
plot(velocity_range, ampacity_vs_velocity, 'g-d', 'LineWidth', 1.5, 'MarkerFaceColor', 'g');
title('Effect of Air Velocity (Wind) on Ampacity');
xlabel('Air Velocity (m/s)');
ylabel('Maximum Current / Ampacity (A)');
grid on;

fprintf('All analyses complete.\n');


%ESTOS EFECTIS YA HAN SIDO ESTUDIADOS EN CONDICIONES SIN VIENTO

% %% ANALYSIS 1: EFFECT OF CONDUCTOR RADIUS (at constant wind speed)
% fprintf('Running Analysis 1: Varying Conductor Radius...\n');
% v_air_const1 = 1.0; % [m/s]
% radius_range = linspace(1.5e-3, 50e-3, 100);
% insulation_thickness_const = 1.2e-3;
% ampacity_vs_radius = zeros(size(radius_range));
% 
% for i = 1:length(radius_range)
%     r_i_current = radius_range(i);
%     r_o_current = r_i_current + insulation_thickness_const;
%     [Q_max, ~] = B2_solve_thermal_equilibrium_forced(r_i_current, r_o_current, L, k_xlpe, T_conductor_max, T_infinity, v_air_const1);
%     R_ohm = (resistivity_cu * L) / (pi * r_i_current^2);
%     ampacity_vs_radius(i) = sqrt(Q_max / R_ohm);
% end
% 
% figure('Name', 'Parametric: Conductor Radius (Forced Conv.)');
% plot(radius_range * 1000, ampacity_vs_radius, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
% title(sprintf('Effect of Conductor Radius on Ampacity (Wind Speed = %.1f m/s)', v_air_const1));
% xlabel('Conductor Radius (mm)');
% ylabel('Maximum Current / Ampacity (A)');
% grid on;
% 
% %% ANALYSIS 2: EFFECT OF INSULATION THICKNESS (at constant wind speed)
% fprintf('Running Analysis 2: Varying Insulation Thickness...\n');
% v_air_const2 = 1.0; % [m/s]
% thickness_range = linspace(0.8e-3, 50e-3, 100);
% radius_const = 2.5e-3;
% ampacity_vs_thickness = zeros(size(thickness_range));
% 
% for i = 1:length(thickness_range)
%     r_o_current = radius_const + thickness_range(i);
%     [Q_max, ~] = B2_solve_thermal_equilibrium_forced(radius_const, r_o_current, L, k_xlpe, T_conductor_max, T_infinity, v_air_const2);
%     R_ohm = (resistivity_cu * L) / (pi * radius_const^2);
%     ampacity_vs_thickness(i) = sqrt(Q_max / R_ohm);
% end
% 
% figure('Name', 'Parametric: Insulation Thickness (Forced Conv.)');
% plot(thickness_range * 1000, ampacity_vs_thickness, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
% title(sprintf('Effect of Insulation Thickness on Ampacity (Wind Speed = %.1f m/s)', v_air_const2));
% xlabel('Insulation Thickness (mm)');
% ylabel('Maximum Current / Ampacity (A)');
% grid on;