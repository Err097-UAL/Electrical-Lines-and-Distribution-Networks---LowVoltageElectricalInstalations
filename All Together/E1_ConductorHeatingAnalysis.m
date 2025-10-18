function results = E1_ConductorHeatingAnalysis()
% =========================================================================
% MAIN FUNCTION for Conductor Thermal Analysis (V6 - Function)
% =========================================================================
% MODIFIED:
% - This script has been converted into a function.
% - It no longer clears the workspace or closes figures.
% - It now returns a single 'results' struct containing all key values.
% - If the user cancels, it returns an empty variable.
% =========================================================================

%% --- Initialize Output ---
results = []; % Default to empty; will be filled if analysis completes

%% --- User Input: Scenario Selection ---
if evalin('base', 'exist(''installationChoice'', ''var'')')
    installationChoice = evalin('base', 'installationChoice');
else
    installationChoice = centeredMenu2('Select Installation Scenario:', 'Underground (Student A)', 'Overhead (Student B)', 'Building/Grouped (Student C)');
end

if installationChoice == 0
    return; % User cancelled, return empty
end

%% --- Define Physical Constants ---
T_ref = 20;
rho_den_copper = 8960;      cp_copper = 385;
rho_den_aluminum = 2700;    cp_aluminum = 900;
rho_den_pvc = 1400;         cp_pvc = 1000;
rho_den_xlpe = 920;         cp_xlpe = 2300;

%% --- Scenario-Specific User Input ---
envParams = struct();
switch installationChoice
    case 1, scenarioName = 'underground';
    case 2, scenarioName = 'overhead';
    case 3, scenarioName = 'building';
end
envParams.scenario = scenarioName;

disp(['--- INPUT FOR: ' upper(scenarioName) ' INSTALLATION ---']);
envParams.T_env = input('Enter ambient temperature [°C] (e.g., 30 for ground, 40 for air): ');
if strcmp(scenarioName, 'underground')
    envParams.rho_soil = input('Enter soil thermal resistivity [K*m/W] (e.g., 1.2): ');
    envParams.burial_depth = input('Enter burial depth to cable center [m] (e.g., 1): ');
elseif strcmp(scenarioName, 'overhead')
    envParams.wind_speed = input('Enter wind speed [m/s] (e.g., 0.5): ');
    envParams.solar_irradiance = input('Enter solar irradiance [W/m^2] (e.g., 1000): ');
    envParams.emissivity = 0.9; envParams.absorptivity = 1.0;
elseif strcmp(scenarioName, 'building')
    num_cables = input('Enter total number of cables in the group (e.g., 6): ');
    if num_cables <= 1, k_g = 1.0; elseif num_cables <= 3, k_g = 0.80; elseif num_cables <= 6, k_g = 0.70; elseif num_cables <= 9, k_g = 0.60; else, k_g = 0.50; end
    envParams.grouping_factor = k_g;
    envParams.num_cables = num_cables;
    envParams.wind_speed = 0; envParams.solar_irradiance = 0; envParams.emissivity = 0.9; envParams.absorptivity = 1.0;
    fprintf('Applied grouping derating factor: %.2f\n', envParams.grouping_factor);
end

%% --- General User Input ---
disp('--- GENERAL CONDUCTOR INPUT ---');
lineLength = input('Enter line length [m] (e.g., 100): ');
crossSection = input('Enter cross-sectional area [mm^2] (e.g., 50): ');
insulatorThickness = input('Enter insulator thickness [mm] (e.g., 1.2): ');
frequency = input('Enter AC frequency [Hz] (e.g., 50): ');
materialChoice = centeredMenu2('Select Conductor Material:', 'Copper', 'Aluminum', 'ACSR');
insulationChoice = centeredMenu2('Select Insulation Type:', 'PVC', 'XLPE');

if materialChoice == 0 || insulationChoice == 0, return; end

%% --- Set Parameters ---
alpha = 0.00393;
switch materialChoice, case 1, sigma = 56; materialName = 'Copper'; density_cond = rho_den_copper; cp_cond = cp_copper; case 2, sigma = 36; materialName = 'Aluminum'; density_cond = rho_den_aluminum; cp_cond = cp_aluminum; case 3, sigma = 36; materialName = 'ACSR'; density_cond = rho_den_aluminum; cp_cond = cp_aluminum; end
switch insulationChoice, case 1, T_mat = 70; k = 0.19; insulationName = 'PVC'; case 2, T_mat = 90; k = 0.35; insulationName = 'XLPE'; end
envParams.k_insulator = k;

%% --- Calculations ---
r_inner_m = sqrt(crossSection / pi) / 1000;
r_outer_m = r_inner_m + (insulatorThickness / 1000);
R_20_DC = lineLength / (sigma * crossSection);
[k_skin, k_proximity] = E3b_AC_Resistance_Factor(frequency, r_inner_m * 2, sigma);
R_20_AC = R_20_DC * (1 + k_skin + k_proximity);

[I_max_AC, R_Tmat_AC, T_surface_at_max, P_dissipated_max] = E2_MaximumCurrent(R_20_AC, alpha, T_mat, T_ref, envParams, lineLength, r_inner_m, r_outer_m);

%% --- Display Key Results ---
fprintf('\n--- ANALYSIS FOR SCENARIO: %s ---\n', upper(envParams.scenario));
fprintf('Max Current (Ampacity) - AC Resistance: %.2f A\n', I_max_AC);
fprintf('--------------------------------------------------\n');

%% --- Plotting ---
E5_HeatingCurves(I_max_AC, T_mat, envParams, R_20_DC, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, materialName, insulationName);

sim_current_prompt = sprintf('Enter a current for transient simulation (e.g., %.0f A): ', I_max_AC * 0.8);
sim_current = input(sim_current_prompt);
if isempty(sim_current), sim_current = I_max_AC * 0.8; end

mass_cond = (crossSection / 1e6) * lineLength * density_cond;
[time_ac, temp_cond_ac] = E6_TransientHeating(sim_current, [0 7200], envParams, R_20_AC, alpha, T_ref, lineLength, r_inner_m, r_outer_m, mass_cond, cp_cond);
T_ss_ac = E4_ThermalEquilibrium(sim_current, R_20_AC, alpha, T_ref, envParams, lineLength, r_inner_m, r_outer_m);

figure;
plot(time_ac/60, temp_cond_ac, 'r-', 'LineWidth', 2);
line([0, time_ac(end)/60], [T_ss_ac, T_ss_ac], 'Color', 'k', 'LineStyle', '--');
title(sprintf('Transient Heating for %.1f A', sim_current));
xlabel('Time (minutes)'); ylabel('Temperature (°C)'); grid on;
legend('Transient Temperature', sprintf('Final Equilibrium (%.1f°C)', T_ss_ac));

%% --- Populate Results Struct for Reporting ---
results.scenario = scenarioName;
results.materialName = materialName;
results.insulationName = insulationName;
results.lineLength = lineLength;
results.crossSection = crossSection;
results.insulatorThickness = insulatorThickness;
results.frequency = frequency;
results.envParams = envParams;
results.T_mat = T_mat;
results.r_inner_m = r_inner_m;
results.r_outer_m = r_outer_m;
results.R_20_DC = R_20_DC;
results.k_skin = k_skin;
results.k_proximity = k_proximity;
results.R_20_AC = R_20_AC;
results.R_Tmat_AC = R_Tmat_AC;
results.T_surface_at_max = T_surface_at_max;
results.P_dissipated_max = P_dissipated_max;
results.I_max_AC = I_max_AC;
results.sim_current = sim_current;
results.T_ss_ac = T_ss_ac;

end

