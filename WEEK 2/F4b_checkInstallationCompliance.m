function F4b_checkInstallationCompliance(results, U_source)
% =========================================================================
% FUNCTION: B4b_checkInstallationCompliance (NEW)
% =========================================================================
% Description:
% Checks the cumulative voltage drop at key points of an installation
% against the tiered limits specified in the Spanish REBT.
%
% REBT Limits (ITC-BT-19):
% - Main Feeder Line (LGA): 1.5% (for centralized meters)
% - Individual Branch Line (DI): 1.5%
% - Internal Circuits: 3% (Lighting), 5% (Power)
% =========================================================================

fprintf('\n--- REBT COMPLIANCE CHECK ---\n');

% Find the indices of the key segments
idx_lga = find(strcmp(cellfun(@(x) x.name, results, 'UniformOutput', false), 'Main Feeder Line (LGA)'));
idx_di = find(strcmp(cellfun(@(x) x.name, results, 'UniformOutput', false), 'Individual Branch Line (DI)'));
idx_internal = find(strcmp(cellfun(@(x) x.name, results, 'UniformOutput', false), 'Internal Circuits'));

% --- Check Drop at end of LGA ---
if ~isempty(idx_lga)
    cumulative_drop_lga = sum(cellfun(@(x) x.voltageDrop, results(1:idx_lga)));
    percent_drop_lga = (cumulative_drop_lga / U_source) * 100;
    limit_lga = 1.5;
    isCompliant_lga = percent_drop_lga <= limit_lga;
    fprintf('Drop at Main Feeder (LGA): %.2f%%. Limit: %.1f%%. Compliant: %s\n', percent_drop_lga, limit_lga, string(isCompliant_lga));
end

% --- Check Drop at end of DI ---
if ~isempty(idx_di)
    % The DI limit applies to the drop *within* the DI itself, not cumulative
    drop_di = results{idx_di}.voltageDrop;
    U_start_di = results{idx_di}.voltage_in;
    percent_drop_di = (drop_di / U_start_di) * 100;
    limit_di = 1.5;
    isCompliant_di = percent_drop_di <= limit_di;
    fprintf('Drop within Individual Branch (DI): %.2f%%. Limit: %.1f%%. Compliant: %s\n', percent_drop_di, limit_di, string(isCompliant_di));
end

% --- Check Drop for Internal Circuits ---
if ~isempty(idx_internal)
    drop_internal = results{idx_internal}.voltageDrop;
    U_start_internal = results{idx_internal}.voltage_in;
    percent_drop_internal = (drop_internal / U_start_internal) * 100;
    % Assuming 'power' for the limit; can be made more complex if needed
    limit_internal = 5.0;
    isCompliant_internal = percent_drop_internal <= limit_internal;
    fprintf('Drop within Internal Circuits: %.2f%%. Limit: %.1f%%. Compliant: %s\n', percent_drop_internal, limit_internal, string(isCompliant_internal));
end

fprintf('---------------------------------\n');
end
