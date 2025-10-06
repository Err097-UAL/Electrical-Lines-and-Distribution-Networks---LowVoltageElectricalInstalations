% =========================================================================
% MAIN SCRIPT for Conductor Thermal Analysis (V5.1 - Insulator Transient)
% =========================================================================
% MODIFIED:
% - Added a post-processing step to calculate the transient temperature
%   of the insulator based on the conductor's temperature.
% - Updated the final plot to display both conductor and insulator
%   temperature curves for comparison.
% - Added density constants for insulating materials.
% =========================================================================

%% --- Cleanup and Initialization ---
% clc; clear; close all; % Commented out for master script control

%% --- User Input: Scenario Selection ---
if ~exist('installationChoice', 'var')
    installationChoice = centeredMenu('Select Installation Scenario:', 'Underground (Student A)', 'Overhead (Student B)', 'Building/Grouped (Student C)');
end

%% --- Define Physical Constants ---
T_ref = 20;     % Reference temperature for resistance [°C]
% Material Properties (Density [kg/m^3], Specific Heat [J/(kg*°C)])
rho_den_copper = 8960;      cp_copper = 385;
rho_den_aluminum = 2700;    cp_aluminum = 900;
rho_den_pvc = 1400;         cp_pvc = 1000;
rho_den_xlpe = 920;         cp_xlpe = 3200;

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
        
        if num_cables <= 1, k_g = 1.0;
        elseif num_cables <= 3, k_g = 0.80;
        elseif num_cables <= 6, k_g = 0.70;
        elseif num_cables <= 9, k_g = 0.60;
        elseif num_cables <= 20, k_g = 0.50;
        else, k_g = 0.45;
        end
        envParams.grouping_factor = k_g;
        
        envParams.wind_speed = 0;
        envParams.solar_irradiance = 0;
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
switch materialChoice, case 1, sigma = 56; materialName = 'Copper'; density_cond = rho_den_copper; cp_cond = cp_copper; case 2, sigma = 36; materialName = 'Aluminum'; density_cond = rho_den_aluminum; cp_cond = cp_aluminum; case 3, sigma = 36; materialName = 'ACSR'; density_cond = rho_den_aluminum; cp_cond = cp_aluminum; end
switch insulationChoice, case 1, T_mat = 70; k = 0.19; insulationName = 'PVC'; density_ins = rho_den_pvc; cp_ins = cp_pvc; case 2, T_mat = 90; k = 0.35; insulationName = 'XLPE'; density_ins = rho_den_xlpe; cp_ins = cp_xlpe; end
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

A5_HeatingCurves(I_max_AC, T_mat, envParams, R_20_DC, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, materialName, insulationName);

%% --- Transient Analysis (Conductor and Insulator) ---
sim_current_prompt = sprintf('Enter a current for transient simulation (e.g., %.0f A): ', I_max_AC * 0.8);
sim_current = input(sim_current_prompt);
if isempty(sim_current), sim_current = I_max_AC * 0.8; end

% Conductor mass calculation
volume_cond = (crossSection / 1e6) * lineLength;
mass_cond = volume_cond * density_cond;
time_span = [0 3600]; % Simulate for 1 hours

% Run primary simulation for conductor temperature
[time_ac, temp_cond_ac] = A6_TransientHeating(sim_current, time_span, envParams, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, mass_cond, cp_cond);

% --- NEW: Post-processing to find insulator temperature ---
fprintf('Calculating insulator transient temperature...\n');
temp_ins_avg_ac = zeros(size(time_ac));
options = optimset('Display','off');
% Thermal resistance of the insulation layer
R_thermal_ins = log(r_outer_m / r_inner_m) / (2 * pi * envParams.k_insulator * lineLength);

for i = 1:length(time_ac)
    T_c = temp_cond_ac(i);
    % At any instant, heat flow through insulation equals heat dissipated from surface
    % (Tc - Ts)/R_ins = A7_HeatDissipation(Ts, ...)
    % We need to find the surface temp (Ts) that balances this equation
    balance_eq = @(T_s) (T_c - T_s) / R_thermal_ins - A7_HeatDissipation(T_s, envParams, r_outer_m, lineLength);
    try
        T_s = fzero(balance_eq, T_c, options); % Find the surface temperature
        % Approximate average insulator temp as the mean of conductor and surface temp
        temp_ins_avg_ac(i) = (T_c + T_s) / 2;
    catch
        temp_ins_avg_ac(i) = T_c; % If solver fails, assume same temp
    end
end
fprintf('Calculation complete.\n');

% --- UPDATED: Plotting both conductor and insulator temperatures ---
figure;
hold on;
plot(time_ac/60, temp_cond_ac, 'r-', 'LineWidth', 2, 'DisplayName', 'Conductor Temp');
plot(time_ac/60, temp_ins_avg_ac, 'm-', 'LineWidth', 2, 'DisplayName', 'Insulator Avg Temp');

T_ss_ac = A4_ThermalEquilibrium(sim_current, R_20_AC, alpha, T_ref, envParams, lineLength, r_inner_m, r_outer_m);
line([0, time_ac(end)/60], [T_ss_ac, T_ss_ac], 'Color', 'k', 'LineStyle', '--', 'DisplayName', sprintf('Final Equilibrium (%.1f°C)', T_ss_ac));

title(sprintf('Transient Heating Comparison for %.1f A', sim_current));
xlabel('Time (minutes)');
ylabel('Temperature (°C)');
grid on;
legend('show', 'Location', 'southeast');
hold off;

