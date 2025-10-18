% =========================================================================
% SCRIPT for Meshed Network Analysis and Reporting (NEW)
% =========================================================================
% Description:
% This script calls the nodal analysis function for a predefined meshed
% network and generates a detailed report of the results, including bus
% voltages, line currents, and power losses.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;

%% --- 1. Run the Full Analysis ---
results = J8_Meshed_Analysis();

%% --- 2. Generate and Display the Final Report ---
if isempty(results)
    disp('Analysis cancelled by user. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE REPORT: MESHED NETWORK ANALYSIS\n');
fprintf('======================================================================\n');

% --- Methodology ---
fprintf('\n--- 1. Methodology Confirmation ---\n');
fprintf('%-35s: Implemented in J8_Meshed_Analysis.m\n', 'Nodal Analysis Method');
fprintf('%-35s: Calculated from bus voltages and Y_bus.\n', 'Load Flow and Losses');
fprintf('%-35s: Performed by identifying highest loss line.\n', 'Simplified Optimization');

% --- Bus Voltages ---
fprintf('\n--- 2. Bus Voltage Results (Load Flow) ---\n');
fprintf('%-10s | %-20s | %-20s\n', 'Bus', 'Voltage Magnitude (V)', 'Voltage Angle (deg)');
fprintf('----------------------------------------------------------\n');
for i = 1:results.num_buses
    fprintf('%-10d | %-20.2f | %-20.2f\n', i, abs(results.V_bus(i)), angle(results.V_bus(i))*180/pi);
end

% --- Line Currents and Losses ---
fprintf('\n--- 3. Line Currents and Power Losses ---\n');
fprintf('%-15s | %-20s | %-20s\n', 'Line (From-To)', 'Current Mag. (A)', 'Active Power Loss (W)');
fprintf('----------------------------------------------------------\n');
for i = 1:size(results.lines, 1)
    from = results.lines(i, 1);
    to = results.lines(i, 2);
    fprintf('Line %d-%-10d | %-20.2f | %-20.2f\n', from, to, abs(results.line_currents(i)), results.line_losses_P(i));
end
fprintf('----------------------------------------------------------\n');
fprintf('%-15s | %-20s | %-20.2f\n', 'TOTAL', '', sum(results.line_losses_P));

% --- Optimization Suggestion ---
fprintf('\n--- 4. Optimization Suggestion ---\n');
[max_loss, idx] = max(results.line_losses_P);
from = results.lines(idx, 1);
to = results.lines(idx, 2);
fprintf('The line with the highest losses is Line %d-%d with %.2f W.\n', from, to, max_loss);
fprintf('To optimize, consider reducing the impedance of this line (e.g., by increasing its cross-section).\n');

fprintf('======================================================================\n');
