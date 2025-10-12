% =========================================================================
% SCRIPT for Dual-Fed Network Analysis and Reporting (V3 - Corrected)
% =========================================================================
% MODIFIED: Corrected function call to use 'I3_PlotLoadingDiagram'.
% =========================================================================
clc;
results = I1_DualFed_Analysis();

if isempty(results), disp('Analysis cancelled.'); return; end

% --- Generate Plots ---
I2_PlotDualFedProfile(results);
I3_PlotLoadingDiagram(results); % Corrected function call
I4_PlotUnifilarDiagram(results);


% --- Generate Command Window Report ---
fprintf('\n\n\n======================================================================\n');
fprintf('      COMPREHENSIVE TECHNICAL REPORT: DUAL-FED NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %s\n', 'Student Scenario', results.scenarioName);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %.1f V\n', 'Source A Voltage', results.Ua);
fprintf('%-35s: %.1f V\n', 'Source B Voltage', results.Ub);
fprintf('%-35s: %.4f Ohm*mm^2/m\n', 'Conductor Resistivity', 1/results.sigma);
fprintf('%-35s: %.1f mm^2\n', 'Conductor Cross-Section', results.crossSection);
fprintf('%-35s: %.1f m\n', 'Total Line Length', results.L_total);

fprintf('\n--- 2. Load Data ---\n');
fprintf('%-10s | %-15s | %-15s\n', 'Load ID', 'Distance (m)', 'Current (A)');
fprintf('----------------------------------------------\n');
for i = 1:length(results.loads)
    fprintf(' %-9s | %-15.1f | %-15.1f\n', ['Load ' num2str(i)], results.loads(i).distance, results.loads(i).current);
end

fprintf('\n--- 3. Normal Operation Results ---\n');
fprintf('%-35s: %.2f A\n', 'Current from Source A (Ia)', results.Ia);
fprintf('%-35s: %.2f A\n', 'Current from Source B (Ib)', results.Ib);
fprintf('%-35s: %.2f m\n', 'Current Division Point', results.division_point);
fprintf('%-35s: %.2f V\n', 'Min Voltage Location', results.min_voltage_node_distance);
fprintf('----------------------------------------------------------------------\n');
fprintf('%-35s: %.2f V\n', 'MINIMUM VOLTAGE (NORMAL)', results.min_voltage_normal);
fprintf('%-35s: %.2f V (%.2f %%)\n', 'Max Voltage Drop (Normal)', results.Ua - results.min_voltage_normal, (results.Ua - results.min_voltage_normal)/results.Ua*100);
fprintf('----------------------------------------------------------------------\n');

% --- Section for Reliability Analysis ---
if strcmp(results.scenarioName, 'Backup Feeding / Reliability Analysis (Multiple Loads)')
    fprintf('\n--- 4. Reliability / Backup Scenario Analysis ---\n');
    fprintf('--- Scenario: Source B Fails (Radial from A) ---\n');
    fprintf('%-35s: %.2f V\n', 'Voltage at final load', results.min_voltage_fail_B);
    fprintf('%-35s: %.2f V (%.2f %%)\n', 'Total Voltage Drop', results.Ua - results.min_voltage_fail_B, (results.Ua - results.min_voltage_fail_B)/results.Ua*100);
    fprintf('\n--- Scenario: Source A Fails (Radial from B) ---\n');
    fprintf('%-35s: %.2f V\n', 'Voltage at final load', results.min_voltage_fail_A);
    fprintf('%-35s: %.2f V (%.2f %%)\n', 'Total Voltage Drop', results.Ub - results.min_voltage_fail_A, (results.Ub - results.min_voltage_fail_A)/results.Ub*100);
end

fprintf('\n======================================================================\n');
fprintf('                      END OF REPORT\n');
fprintf('======================================================================\n\n');
