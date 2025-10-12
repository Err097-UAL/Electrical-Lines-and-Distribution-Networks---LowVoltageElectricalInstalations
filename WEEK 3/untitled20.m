% =========================================================================
% SCRIPT for Network Comparison Analysis and Reporting (NEW)
% =========================================================================
% Description:
% This script is the entry point for the network comparison tool. It calls
% the main comparison function and then generates a detailed report
% comparing a Ring network and a Radial network based on key metrics.
% =========================================================================

clc;
results = C5_CompareNetworks();

if isempty(results)
    disp('Analysis cancelled. No report generated.');
    return;
end

fprintf('\n\n\n======================================================================\n');
fprintf('        COMPREHENSIVE REPORT: NETWORK TOPOLOGY COMPARISON\n');
fprintf('======================================================================\n');

fprintf('\n--- 1. General Inputs ---\n');
fprintf('%-35s: %.1f V\n', 'Source Voltage', results.U_source);
fprintf('%-35s: %s\n', 'Conductor Material', results.materialName);
fprintf('%-35s: %.1f mm^2\n', 'Conductor Cross-Section', results.crossSection);

fprintf('\n--- 2. Load Data ---\n');
fprintf('Total of %d loads with a combined current of %.1f A.\n', length(results.loads), sum([results.loads.current]));

fprintf('\n--- 3. Voltage Quality Comparison (Normal Operation) ---\n');
fprintf('%-20s | %-20s | %-20s\n', 'Metric', 'Ring Network', 'Radial Network');
fprintf('------------------------------------------------------------------\n');
fprintf('%-20s | %-20.2f | %-20.2f\n', 'Min Voltage (V)', results.ring.min_voltage, results.radial.min_voltage);
fprintf('%-20s | %-20.2f | %-20.2f\n', 'Max Voltage Drop (%)', results.ring.max_drop_percent, results.radial.max_drop_percent);
fprintf('------------------------------------------------------------------\n');
fprintf('Conclusion: The %s network provides better voltage quality.\n', results.voltage_winner);

fprintf('\n--- 4. Reliability / Failure Impact Analysis ---\n');
fprintf('Analysis simulates a single-point open-circuit fault in the Ring network.\n');
fprintf('%-35s: %.2f V\n', 'Min Voltage in Ring (Fault)', results.reliability.min_voltage_fault);
fprintf('%-35s: %.2f %% \n', 'Max Voltage Drop in Ring (Fault)', results.reliability.max_drop_percent_fault);
fprintf('Conclusion: Ring network maintains supply to all loads during a fault, while a radial network would cause a complete outage for downstream loads.\n');

fprintf('\n--- 5. Economic Analysis (Lifecycle Cost) ---\n');
fprintf('%-20s | %-20s | %-20s\n', 'Cost Component', 'Ring Network', 'Radial Network');
fprintf('------------------------------------------------------------------\n');
fprintf('%-20s | %-20.2f | %-20.2f\n', 'Initial Cable Cost', results.ring.cable_cost, results.radial.cable_cost);
fprintf('%-20s | %-20.2f | %-20.2f\n', 'Cost of Losses (20yr)', results.ring.loss_cost, results.radial.loss_cost);
fprintf('------------------------------------------------------------------\n');
fprintf('%-20s | %-20.2f | %-20.2f\n', 'TOTAL LIFECYCLE COST', results.ring.total_cost, results.radial.total_cost);
fprintf('------------------------------------------------------------------\n');
fprintf('Conclusion: The %s network is more economical over the lifecycle.\n', results.economic_winner);

fprintf('\n======================================================================\n');
fprintf('                      END OF REPORT\n');
fprintf('======================================================================\n');
