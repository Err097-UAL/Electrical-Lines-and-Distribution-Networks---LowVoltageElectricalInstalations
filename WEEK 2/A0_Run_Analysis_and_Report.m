% =========================================================================
% FINAL SCRIPT for Conductor Heating Analysis and Reporting
% =========================================================================
% Description:
% This script serves as the final entry point for the Conductor Heating
% module (Case A). It performs two main actions:
% 1. Calls the main analysis function (A1_ConductorHeatingAnalysis) to
%    execute all calculations and generate plots. This function returns
%    a struct containing all key values from the simulation.
% 2. Uses the returned struct to generate and display a comprehensive
%    summary table of all inputs, intermediate values, and final results.
%
% How to Run:
% This script is intended to be called by the master ProjectSelector.m
% =========================================================================

%% --- Cleanup and Initialization ---
clc; % Clear the command window for a clean report
% clear; close all; % Controlled by master ProjectSelector

%% --- 1. Run the Full Analysis ---
% The main analysis script has been converted to a function that returns
% all its important data in a single 'results' struct.
results = A1_ConductorHeatingAnalysis();


%% --- 2. Generate and Display the Final Report Table ---
% Check if the analysis was completed (user might have cancelled a menu)
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE TECHNICAL REPORT: CONDUCTOR HEATING\n');
fprintf('======================================================================\n');

% --- General and Material Inputs ---
fprintf('\n--- 1. General & Material Inputs ---\n');
fprintf('%-35s: %s\n', 'Installation Scenario', results.scenario);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %s\n', 'Insulation Type', results.insulationName);
fprintf('%-35s: %.1f m\n', 'Line Length', results.lineLength);
fprintf('%-35s: %.1f mm^2\n', 'Conductor Cross-Section', results.crossSection);
fprintf('%-35s: %.2f mm\n', 'Insulator Thickness', results.insulatorThickness);
fprintf('%-35s: %.1f Hz\n', 'AC Frequency', results.frequency);

% --- Environmental Inputs (Scenario-Specific) ---
fprintf('\n--- 2. Environmental & Scenario Parameters ---\n');
fprintf('%-35s: %.1f °C\n', 'Ambient Temperature (T_env)', results.envParams.T_env);
if strcmp(results.scenario, 'underground')
    fprintf('%-35s: %.2f K*m/W\n', 'Soil Thermal Resistivity', results.envParams.rho_soil);
    fprintf('%-35s: %.2f m\n', 'Burial Depth', results.envParams.burial_depth);
elseif strcmp(results.scenario, 'overhead')
    fprintf('%-35s: %.2f m/s\n', 'Wind Speed', results.envParams.wind_speed);
    fprintf('%-35s: %.0f W/m^2\n', 'Solar Irradiance', results.envParams.solar_irradiance);
    fprintf('%-35s: %.2f\n', 'Surface Emissivity', results.envParams.emissivity);
    fprintf('%-35s: %.2f\n', 'Solar Absorptivity', results.envParams.absorptivity);
elseif strcmp(results.scenario, 'building')
    fprintf('%-35s: %d\n', 'Number of Cables in Group', results.envParams.num_cables);
    fprintf('%-35s: %.2f\n', 'Grouping Derating Factor (k_g)', results.envParams.grouping_factor);
end

% --- Intermediate Calculated Values ---
fprintf('\n--- 3. Intermediate Calculated Values ---\n');
fprintf('%-35s: %.4f m\n', 'Conductor Radius (r_inner)', results.r_inner_m);
fprintf('%-35s: %.4f m\n', 'Outer Cable Radius (r_outer)', results.r_outer_m);
fprintf('%-35s: %.5f Ohm\n', 'DC Resistance at 20°C (R_20_DC)', results.R_20_DC);
fprintf('%-35s: %.5f\n', 'Skin Effect Factor (k_skin)', results.k_skin);
fprintf('%-35s: %.5f\n', 'Proximity Effect Factor (k_prox)', results.k_proximity);
fprintf('%-35s: %.5f Ohm\n', 'AC Resistance at 20°C (R_20_AC)', results.R_20_AC);
fprintf('%-35s: %.5f Ohm\n', 'AC Resistance at T_max (R_Tmat)', results.R_Tmat_AC);
fprintf('%-35s: %.1f °C\n', 'Surface Temp at Max Load', results.T_surface_at_max);
fprintf('%-35s: %.2f kW\n', 'Max Heat Dissipation', results.P_dissipated_max / 1000);

% --- Final Results ---
fprintf('\n--- 4. Final Analysis Results ---\n');
fprintf('%-35s: %.1f °C\n', 'Max Conductor Temperature (T_mat)', results.T_mat);
fprintf('----------------------------------------------------------------------\n');
fprintf('%-35s: %.2f A\n', 'AMPACITY (Max AC Current)', results.I_max_AC);
fprintf('----------------------------------------------------------------------\n');
fprintf('%-35s: %.1f A\n', 'Transient Sim. Current', results.sim_current);
fprintf('%-35s: %.1f °C\n', 'Final Equilibrium Temp (T_ss)', results.T_ss_ac);

fprintf('\n======================================================================\n');
fprintf('                      END OF REPORT\n');
fprintf('======================================================================\n');
