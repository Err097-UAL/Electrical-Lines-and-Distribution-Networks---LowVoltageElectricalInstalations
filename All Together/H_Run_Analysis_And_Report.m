% =========================================================================
% SCRIPT for Radial Network Analysis and Reporting
% =========================================================================
% Description:
% This is the main entry point for the radial network module. It calls
% the main analysis function (H1_Radial_Analysis) and then generates a
% detailed summary report in the command window based on the results.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;

%% --- 1. Run the Full Analysis ---
% Call the main analysis function, which returns all data in a struct
results = H1_Radial_Analysis();

%% --- 2. Generate and Display the Final Report Table ---
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE REPORT: RADIAL NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

% --- General Inputs ---
fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %s\n', 'Scenario', results.scenarioName);
fprintf('%-35s: %.1f V\n', 'Source Voltage', results.U_source);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %d mm^2\n', 'Conductor Cross-Section', results.crossSection);

% --- Load and Segment Data ---
fprintf('\n--- 2. Load and Segment Data ---\n');
fprintf('%-10s | %-15s | %-15s | %-15s\n', 'Node', 'Segment L (m)', 'Load I (A)', 'Distance (m)');
fprintf('------------------------------------------------------------------\n');
for i = 1:length(results.loads)
    fprintf('%-10d | %-15.1f | %-15.1f | %-15.1f\n', ...
            i, results.loads(i).length, results.loads(i).current, results.loads(i).distance);
end

% --- Performance Analysis ---
fprintf('\n--- 3. Performance Analysis ---\n');
final_voltage = results.loads(end).voltage;
total_drop_V = results.U_source - final_voltage;
total_drop_percent = (total_drop_V / results.U_source) * 100;

fprintf('%-35s: %.2f V\n', 'Voltage at Final Node', final_voltage);
fprintf('%-35s: %.2f V\n', 'Total Voltage Drop', total_drop_V);
fprintf('%-35s: %.2f %%\n', 'Total Voltage Drop Percentage', total_drop_percent);

% --- Economic Analysis (if optimization was run) ---
if isfield(results, 'total_cost')
    fprintf('\n--- 4. Economic Analysis (from Optimization) ---\n');
    fprintf('%-35s: %d mm^2\n', 'Optimal Cross-Section', results.crossSection);
    fprintf('%-35s: %.2f EUR\n', 'Total Estimated Conductor Cost', results.total_cost);
end

fprintf('======================================================================\n');
