% =========================================================================
% SCRIPT for Ring Network Analysis and Reporting (Week 3)
% =========================================================================
% Description:
% This is the primary entry point for the Ring Network analysis module.
% It calls the main analysis function (C1_Ring_Analysis) and then uses
% the returned data to generate a detailed report in the command window.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;

%% --- 1. Run the Full Analysis ---
% Call the main analysis function, which returns all data in a struct
results = J1_Ring_Analysis();

%% --- 2. Generate and Display the Final Report Table ---
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE TECHNICAL REPORT: RING NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

% --- General Inputs ---
fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %s\n', 'Student Scenario', results.scenarioName);
fprintf('%-35s: %.1f V\n', 'Feed-in Voltage', results.Ua);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %.4f Ohm*mm^2/m\n', 'Conductor Resistivity', 1/results.sigma);
fprintf('%-35s: %.1f mm^2\n', 'Conductor Cross-Section', results.crossSection);
fprintf('%-35s: %.1f m\n', 'Total Ring Circumference', results.L_total);

% --- Load Data ---
fprintf('\n--- 2. Load Data ---\n');
fprintf('%-10s | %-25s | %-15s\n', 'Load', 'Distance along Ring (m)', 'Current (A)');
fprintf('---------------------------------------------------------------\n');
for i = 1:length(results.loads)
    fprintf(' %-9s | %-25.1f | %-15.1f\n', ['Load ' num2str(i)], results.loads(i).distance, results.loads(i).current);
end

% --- Intermediate Calculations ---
fprintf('\n--- 3. Equivalent Dual-Fed Analysis ---\n');
fprintf('The ring is opened at the feed point and solved as a dual-fed line.\n');
fprintf('%-35s: %.1f A\n', 'Current Supplied Clockwise (Ia)', results.Ia);
fprintf('%-35s: %.1f A\n', 'Current Supplied Anti-Clockwise (Ib)', results.Ib);
fprintf('%-35s: %.1f m\n', 'Location of Min Voltage Point', results.min_voltage_node_distance);

% --- Final Results ---
fprintf('\n--- 4. Final Results ---\n');
fprintf('----------------------------------------------------------------------\n');
fprintf('%-35s: %.2f V\n', 'MINIMUM VOLTAGE IN RING', results.min_voltage);
fprintf('%-35s: %.2f V (%.2f %%)\n', 'Maximum Voltage Drop in Ring', results.max_drop_V, results.max_drop_percent);
fprintf('----------------------------------------------------------------------\n');


fprintf('\n======================================================================\n');
fprintf('                      END OF REPORT\n');
fprintf('======================================================================\n');

