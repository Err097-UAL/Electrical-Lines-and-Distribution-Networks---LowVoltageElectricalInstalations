% =========================================================================
% MAIN SCRIPT for Voltage Drop Analysis (V3.1 - Mode Selection)
% =========================================================================
% MODIFIED:
% - Added a selection menu at the start to allow the user to choose
%   between a 'Full Installation' analysis (multi-segment) and a
%   'Single Line' analysis (the previous, simpler version).
% - The script now contains both workflows.
% =========================================================================

%% --- Cleanup ---
% clc; clear; close all; % Controlled by master script

%% --- User Selection of Analysis Mode ---
analysisMode = centeredMenu2('Select Voltage Drop Analysis Type:', 'Full Installation Analysis (Multi-Segment)', 'Simple Single Line Analysis');

if analysisMode == 0
    disp('No analysis type selected. Exiting.');
    return;
end

%% --- Execute Selected Analysis ---
if analysisMode == 1
    % --- RUN FULL INSTALLATION ANALYSIS (MULTI-SEGMENT) ---
    run_full_installation_analysis();
else
    % --- RUN SIMPLE SINGLE LINE ANALYSIS ---
    run_single_line_analysis();
end


%% ========================================================================
%                     WORKFLOW 1: FULL INSTALLATION
% =========================================================================
function run_full_installation_analysis()
    % --- Initialize Installation Structure ---
    installationSegments = {
        'LV Distribution Line',
        'Individual Connection Line',
        'Main Feeder Line (LGA)',
        'Individual Branch Line (DI)',
        'Internal Circuits'
    };
    numSegments = length(installationSegments);
    results = cell(numSegments, 1);
    
    % --- Define Physical Constants ---
    rho_copper = 0.0172; sigma_copper = 56;
    rho_aluminum = 0.0282; sigma_aluminum = 36;

    % --- Get Global Parameters ---
    disp('--- Entering Global Parameters for Full Installation ---');
    U_source_initial = input('Enter source voltage at LV Distribution Line [V] (e.g., 230 or 400): ');
    %loadCurrent = input('Enter final load current [A] (e.g., 30): ');
    loadPower = input('enter load power consumption [W] (e.g. 9000):');
    cos_phi = input('Enter final load power factor (e.g., 0.95): ');
    loadCurrent = (loadPower/((sqrt(3))*U_source_initial*cos_phi))
    frequency = input('Enter AC frequency [Hz] (e.g., 50): ');

    lineTypeChoice = centeredMenu2('Select Dominant System Type:', 'Single-Phase', 'Three-Phase');
    if lineTypeChoice == 1, lineType = 'single-phase'; else, lineType = 'three-phase'; end
    
    % --- Data Collection Loop for Each Segment ---
    voltage_at_start_of_segment = U_source_initial;
    for i = 1:numSegments
        fprintf('\n--- Input for Segment %d: %s ---\n', i, installationSegments{i});
        segmentData.name = installationSegments{i};
        segmentData.length = input(sprintf('Enter length [m] for %s: ', segmentData.name));
        segmentData.crossSection = input(sprintf('Enter cross-section [mm^2] for %s: ', segmentData.name));
        materialChoice = centeredMenu2(['Select Material for ' segmentData.name], 'Copper', 'Aluminum');
        if materialChoice == 0, disp('Selection cancelled. Aborting.'); return; end
        switch materialChoice, case 1, segmentData.resistivity = rho_copper; segmentData.sigma = sigma_copper; case 2, segmentData.resistivity = rho_aluminum; segmentData.sigma = sigma_aluminum; end
        segmentData.reactance_per_meter = input(sprintf('Enter reactance [Ohm/m] for %s (e.g., 0.0001): ', segmentData.name));
        
        r_dc = segmentData.resistivity / segmentData.crossSection;
        diameter_m = sqrt(4 * segmentData.crossSection / pi) / 1000;
        [k_skin, k_prox] = E3b_AC_Resistance_Factor(frequency, diameter_m, segmentData.sigma);
        r_ac = r_dc * (1 + k_skin + k_prox);
        
        segmentData.voltageDrop = F2_calculateExactVoltageDrop(lineType, segmentData.length, loadCurrent, r_ac, segmentData.reactance_per_meter, cos_phi);
        segmentData.voltage_in = voltage_at_start_of_segment;
        segmentData.voltage_out = voltage_at_start_of_segment - segmentData.voltageDrop;
        voltage_at_start_of_segment = segmentData.voltage_out;
        results{i} = segmentData;
    end
    
    % --- Display Summary and Compliance ---
    display_summary_table(results, U_source_initial);
    F4b_checkInstallationCompliance(results, U_source_initial);
    F6_plotInstallationProfile(results, U_source_initial);
end

function display_summary_table(results, U_source_initial)
    fprintf('\n\n--- COMPLETE INSTALLATION VOLTAGE DROP SUMMARY ---\n');
    fprintf('==========================================================================================\n');
    fprintf('%-30s | %-10s | %-10s | %-12s | %-12s\n', 'Segment', 'Length (m)', 'Drop (V)', 'Voltage In (V)', 'Voltage Out (V)');
    fprintf('------------------------------------------------------------------------------------------\n');
    cumulativeDrop = 0;
    for i = 1:length(results)
        data = results{i};
        cumulativeDrop = cumulativeDrop + data.voltageDrop;
        fprintf('%-30s | %-10.1f | %-10.2f | %-12.2f | %-12.2f\n', data.name, data.length, data.voltageDrop, data.voltage_in, data.voltage_out);
    end
    fprintf('==========================================================================================\n');
    fprintf('Total Voltage Drop from Source to Final Load: %.2f V (%.2f%%)\n', cumulativeDrop, (cumulativeDrop/U_source_initial)*100);
end


%% ========================================================================
%                     WORKFLOW 2: SINGLE LINE
% =========================================================================
function run_single_line_analysis()
    % --- Define Physical Constants ---
    rho_copper = 0.0172;   sigma_copper = 56;
    rho_aluminum = 0.0282; sigma_aluminum = 36;

    % --- User Input ---
    fprintf('\n--- Input for Single Line Analysis ---\n');
    lineTypeChoice = centeredMenu2('Select Line Type:', 'Single-Phase', 'Three-Phase');
    if lineTypeChoice == 1
        lineType = 'single-phase';
        U_source = input('Enter single-phase source voltage (L-N) [V] (e.g., 230): ');
    else
        lineType = 'three-phase';
        U_source = input('Enter three-phase source voltage (L-L) [V] (e.g., 400): ');
    end

 %loadCurrent = input('Enter final load current [A] (e.g., 30): ');
    loadPower = input('enter load power consumption [W] (e.g. 9000):');
    cos_phi = input('Enter final load power factor (e.g., 0.95): ');
    loadCurrent = (loadPower/((sqrt(3))*U_source*cos_phi))
   % loadCurrent = input('Enter load current [A] (e.g., 25): ');
   % cos_phi = input('Enter load power factor (e.g., 0.9): ');
    lineLength = input('Enter total line length [m] (e.g., 150): ');
    reactance = input('Enter line reactance per unit length [Ohm/m] (e.g., 0.0001): ');
    frequency = input('Enter AC frequency [Hz] (e.g., 50): ');
    materialChoice = centeredMenu2('Select Conductor Material:', 'Copper', 'Aluminum');
    crossSection = input('Enter conductor cross-section [mm^2] (e.g., 16): ');
    circuitChoice = centeredMenu2('Select Circuit Type (for REBT limits):', 'Lighting', 'Power (Other uses)');
    if materialChoice == 0 || circuitChoice == 0, disp('Invalid selection. Aborting.'); return; end
    
    % --- Set Parameters ---
    switch materialChoice, case 1, resistivity = rho_copper; sigma = sigma_copper; case 2, resistivity = rho_aluminum; sigma = sigma_aluminum; end
    switch circuitChoice, case 1, circuitType = 'lighting'; case 2, circuitType = 'power'; end
    
    % --- Resistance Calculations (DC and AC) ---
    resistance_dc_per_meter = resistivity / crossSection;
    diameter_m = sqrt(4 * crossSection / pi) / 1000;
    [k_skin, k_proximity] = E3b_AC_Resistance_Factor(frequency, diameter_m, sigma);
    resistance_ac_per_meter = resistance_dc_per_meter * (1 + k_skin + k_proximity);

    % --- Perform Voltage Drop Calculations ---
    deltaU_exact_dc = F2_calculateExactVoltageDrop(lineType, lineLength, loadCurrent, resistance_dc_per_meter, reactance, cos_phi);
    deltaU_exact_ac = F2_calculateExactVoltageDrop(lineType, lineLength, loadCurrent, resistance_ac_per_meter, reactance, cos_phi);
    [isCompliant, percentDrop, limit] = F4_checkREBTCompliance(deltaU_exact_ac, U_source, circuitType);

    % --- Display Results ---
    fprintf('\n--- RESULTS for Single Line ---\n');
    fprintf('DC Resistance per meter: %.5f Ohm/m\n', resistance_dc_per_meter);
    fprintf('AC Resistance per meter: %.5f Ohm/m (Skin: %.2f%%, Prox: %.2f%%)\n', resistance_ac_per_meter, k_skin*100, k_proximity*100);
    fprintf('--------------------------------------------------\n');
    fprintf('Voltage Drop (using DC Resistance): %.2f V\n', deltaU_exact_dc);
    fprintf('Voltage Drop (using AC Resistance): %.2f V (%.2f%%)\n', deltaU_exact_ac, percentDrop);
    fprintf('Voltage at Load (based on AC drop): %.2f V\n', U_source - deltaU_exact_ac);
    fprintf('REBT Compliance for %s: %s (Limit: %.1f%%)\n', circuitType, string(isCompliant), limit);
    fprintf('--------------------------------------------------\n');

    % --- Plotting ---
    F5_plotVoltageProfile(U_source, deltaU_exact_dc, deltaU_exact_ac, lineLength, circuitType);
end

