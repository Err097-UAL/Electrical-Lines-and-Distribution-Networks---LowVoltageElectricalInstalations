% =========================================================================
% MAIN SCRIPT for Voltage Drop Analysis (V2.1 - Scope Fix)
% =========================================================================
% MODIFIED:
% - Moved the physical constant definitions (resistivity, conductivity)
%   inside the nested run_voltage_drop_calc function to resolve the
%   "unrecognized variable" scope error.
% =========================================================================

%% --- Cleanup ---
% clc; clear; close all; % Controlled by master script

%% --- Scenario Selection ---
if ~exist('vd_scenarioChoice', 'var')
    vd_scenarioChoice = centeredMenu('Select Voltage Drop Scenario:', 'Single-Phase Circuit', 'Three-Phase Circuit', 'Mixed Load Analysis');
end

%% --- Execute Analysis Based on Scenario ---
switch vd_scenarioChoice
    case 1, disp('--- Running Single-Phase Circuit Analysis (Student A) ---'); run_voltage_drop_calc('single-phase');
    case 2, disp('--- Running Three-Phase Circuit Analysis (Student B) ---'); run_voltage_drop_calc('three-phase');
    case 3, disp('--- Running Mixed Load Analysis (Student C) ---');
        disp('--- First: The Single-Phase Load ---'); run_voltage_drop_calc('single-phase');
        disp('--- Second: The Three-Phase Load ---'); run_voltage_drop_calc('three-phase');
    case 0, disp('No scenario selected. Exiting.'); return;
end

%% --- Main Calculation Sub-function ---
function run_voltage_drop_calc(lineType)
    %% --- Define Physical Constants (FIXED LOCATION) ---
    rho_copper = 0.0172;   % Resistivity of Copper [Ohm * mm^2 / m]
    rho_aluminum = 0.0282; % Resistivity of Aluminum [Ohm * mm^2 / m]
    sigma_copper = 56;     % Conductivity of Copper [S*m/mm^2]
    sigma_aluminum = 36;   % Conductivity of Aluminum [S*m/mm^2]

    %% --- User Input ---
    fprintf('\n--- Input for %s Line ---\n', upper(lineType));
    if strcmp(lineType, 'single-phase'), U_source = input('Enter single-phase source voltage (L-N) [V] (e.g., 230): ');
    else, U_source = input('Enter three-phase source voltage (L-L) [V] (e.g., 400): '); end
    loadCurrent = input('Enter load current [A] (e.g., 25): ');
    cos_phi = input('Enter load power factor (e.g., 0.9): ');
    lineLength = input('Enter total line length [m] (e.g., 150): ');
    reactance = input('Enter line reactance per unit length [Ohm/m] (e.g., 0.0001): ');
    frequency = input('Enter AC frequency [Hz] (e.g., 50): ');
    materialChoice = centeredMenu('Select Conductor Material:', 'Copper', 'Aluminum');
    crossSection = input('Enter conductor cross-section [mm^2] (e.g., 16): ');
    circuitChoice = centeredMenu('Select Circuit Type (for REBT limits):', 'Lighting', 'Power (Other uses)');
    if materialChoice == 0 || circuitChoice == 0, disp('Invalid selection. Aborting.'); return; end
    
    %% --- Set Parameters ---
    switch materialChoice, case 1, resistivity = rho_copper; sigma = sigma_copper; case 2, resistivity = rho_aluminum; sigma = sigma_aluminum; end
    switch circuitChoice, case 1, circuitType = 'lighting'; case 2, circuitType = 'power'; end
    
    %% --- Resistance Calculations (DC and AC) ---
    resistance_dc_per_meter = resistivity / crossSection;
    diameter_m = sqrt(4 * crossSection / pi) / 1000;
    [k_skin, k_proximity] = A3b_AC_Resistance_Factor(frequency, diameter_m, sigma);
    resistance_ac_per_meter = resistance_dc_per_meter * (1 + k_skin + k_proximity);

    %% --- Perform Voltage Drop Calculations ---
    deltaU_exact_dc = B2_calculateExactVoltageDrop(lineType, lineLength, loadCurrent, resistance_dc_per_meter, reactance, cos_phi);
    deltaU_exact_ac = B2_calculateExactVoltageDrop(lineType, lineLength, loadCurrent, resistance_ac_per_meter, reactance, cos_phi);
    [isCompliant, percentDrop, limit] = B4_checkREBTCompliance(deltaU_exact_ac, U_source, circuitType);

    %% --- Display Results ---
    fprintf('\n--- RESULTS for %s Line ---\n', upper(lineType));
    fprintf('DC Resistance per meter: %.5f Ohm/m\n', resistance_dc_per_meter);
    fprintf('AC Resistance per meter: %.5f Ohm/m (Skin: %.2f%%, Prox: %.2f%%)\n', resistance_ac_per_meter, k_skin*100, k_proximity*100);
    fprintf('--------------------------------------------------\n');
    fprintf('Voltage Drop (using DC Resistance): %.2f V\n', deltaU_exact_dc);
    fprintf('Voltage Drop (using AC Resistance): %.2f V (%.2f%%)\n', deltaU_exact_ac, percentDrop);
    fprintf('Voltage at Load (based on AC drop): %.2f V\n', U_source - deltaU_exact_ac);
    fprintf('REBT Compliance for %s: %s (Limit: %.1f%%)\n', circuitType, string(isCompliant), limit);
    fprintf('--------------------------------------------------\n');

    %% --- Plotting ---
    B5_plotVoltageProfile(U_source, deltaU_exact_dc, deltaU_exact_ac, lineLength, circuitType);
end

