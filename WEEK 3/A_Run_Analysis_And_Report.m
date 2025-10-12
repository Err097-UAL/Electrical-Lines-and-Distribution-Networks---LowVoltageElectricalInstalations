% =========================================================================
% SCRIPT for Radial Network Analysis and Reporting (Week 3)
% =========================================================================
% Description:
% This is the primary entry point for the Radial Network analysis module.
% It calls the main analysis function (A1_Radial_Analysis) which handles all
% user input and calculations. Upon completion, this script takes the
% returned data and generates a detailed report in the command window,
% displaying all inputs, intermediate values, and final results.
% =========================================================================

%% --- Cleanup and Initialization ---
clc; % Clear the command window for a clean report

%% --- 1. Run the Full Analysis ---
% Call the main analysis function, which returns all data in a struct
results = A1_Radial_Analysis();


%% --- 2. Generate and Display the Final Report Table ---
% Check if the analysis was completed (user might have cancelled a menu)
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE TECHNICAL REPORT: RADIAL NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

% --- General and Material Inputs ---
fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %s\n', 'Student Scenario', results.scenarioName);
fprintf('%-35s: %.1f V\n', 'Source Voltage', results.U_source);
fprintf('%-35s: %.4f Ohm*mm^2/m\n', 'Conductor Resistivity', 1/results.sigma);
fprintf('%-35s: %.1f mm^2\n', 'Conductor Cross-Section', results.crossSection);

% --- Load and Segment Data ---
fprintf('\n--- 2. Load and Segment Data ---\n');
fprintf('%-15s | %-15s | %-15s | %-15s\n', 'Segment', 'Length (m)', 'Load (A)', 'Moment (A*m)');
fprintf('-----------------------------------------------------------------------\n');
for i = 1:length(results.nodes)
    if i == 1
        start_node = 'Source';
    else
        start_node = ['Node ' num2str(i-1)];
    end
    end_node = ['Node ' num2str(i)];
    fprintf(' %-14s | %-15.1f | %-15.1f | %-15.1f\n', [start_node ' -> ' end_node], results.nodes(i).length, results.nodes(i).load, results.nodes(i).moment);
end

% --- Voltage Drop Results ---
fprintf('\n--- 3. Voltage Drop Results (Method of Moments) ---\n');
fprintf('%-15s | %-20s | %-20s | %-15s\n', 'Node', 'Cumulative Moment(A*m)', 'Voltage Drop (V)', 'Voltage (V)');
fprintf('------------------------------------------------------------------------------\n');
for i = 1:length(results.nodes)
    fprintf(' %-14s | %-20.1f | %-20.2f | %-15.2f\n', ['Node ' num2str(i)], results.nodes(i).cumulativeMoment, results.nodes(i).voltageDrop, results.nodes(i).voltage);
end
fprintf('------------------------------------------------------------------------------\n');
fprintf('%-35s: %.2f V (%.2f %%)\n', 'Total Voltage Drop at Final Node', results.totalVoltageDrop, results.totalVoltageDropPercent);

fprintf('\n======================================================================\n');
fprintf('                      END OF REPORT\n');
fprintf('======================================================================\n');

