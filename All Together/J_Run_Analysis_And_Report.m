% =========================================================================
% SCRIPT for Ring Network Analysis and Reporting (V2 - Corrected)
% =========================================================================
% MODIFIED:
% - Updated the report to display the new 'conductivity' variable.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;

%% --- 1. Run the Full Analysis ---
results = J1_Ring_Analysis();

%% --- 2. Generate and Display the Final Report Table ---
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE REPORT: RING NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

% --- General Inputs ---
fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %s\n', 'Scenario', results.scenarioName);
fprintf('%-35s: %.1f V\n', 'Feed-In Voltage', results.Ua);
fprintf('%-35s: %.1f m\n', 'Total Ring Circumference', results.L_total);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %.1f m/(Ohm*mm^2)\n', 'Conductivity', results.conductivity);
fprintf('%-35s: %d mm^2\n', 'Conductor Cross-Section', results.crossSection);

% --- Methodology Confirmation ---
fprintf('\n--- 2. Methodology Confirmation ---\n');
fprintf('%-35s: Ring is "unwrapped" into a linear\n', 'Ring to Dual-Feed Conversion');
fprintf('%-35s: equivalent for calculation.\n', '');
fprintf('%-35s: Dual-feed method applied to find\n', 'Calculation Method');
fprintf('%-35s: current split and voltage drops.\n', '');

% --- Load Data ---
fprintf('\n--- 3. Load Data ---\n');
fprintf('%-10s | %-20s | %-15s\n', 'Load', 'Distance from Feed (m)', 'Current (A)');
fprintf('----------------------------------------------------------\n');
loads_table = sortrows(struct2table(results.loads), 'distance');
for i = 1:height(loads_table)
    fprintf('%-10d | %-20.1f | %-15.1f\n', i, loads_table.distance(i), loads_table.current(i));
end

% --- Performance Analysis ---
fprintf('\n--- 4. Performance Analysis (Normal Operation) ---\n');
fprintf('%-35s: %.2f A\n', 'Current Supplied Clockwise (Ia)', results.Ia);
fprintf('%-35s: %.2f A\n', 'Current Supplied Anti-Clockwise (Ib)', results.Ib);
fprintf('%-35s: %.2f V\n', 'Minimum Voltage in Ring', results.min_voltage);
fprintf('%-35s: %.1f m\n', 'Location of Minimum Voltage', results.min_voltage_node_distance);
fprintf('%-35s: %.2f V\n', 'Maximum Voltage Drop', results.max_drop_V);
fprintf('%-35s: %.2f %%\n', 'Maximum Voltage Drop', results.max_drop_percent);

fprintf('======================================================================\n');

