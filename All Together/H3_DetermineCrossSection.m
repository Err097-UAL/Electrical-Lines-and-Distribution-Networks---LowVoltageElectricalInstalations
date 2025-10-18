function [required_s, standard_s] = H3_DetermineCrossSection(results, max_drop_percent)
% =========================================================================
% FUNCTION: Determine Required Conductor Cross-Section
% =========================================================================
% Description:
% This function calculates the minimum required cross-section to satisfy
% a specified maximum voltage drop percentage, based on the method of
% electrical moments. It also suggests the next standard-sized conductor.
% =========================================================================

% --- 1. Calculate the total sum of electrical moments ---
% M = sum(I_segment * L_segment)
total_moment = 0;
current_in_segment = sum([results.loads.current]); % Start with total current
for i = 1:length(results.loads)
    total_moment = total_moment + current_in_segment * results.loads(i).length;
    % Update current for the next segment
    current_in_segment = current_in_segment - results.loads(i).current;
end

% --- 2. Calculate the required cross-section ---
% s = (K * M) / (conductivity * max_drop_V)
max_drop_V = results.U_source * (max_drop_percent / 100);
required_s = (results.phase_factor * total_moment) / (results.conductivity * max_drop_V);

% --- 3. Find the next standard cross-section ---
conductors = getStandardConductors(results.materialName);
standard_sections = conductors.CrossSection;
% Find the first standard section that is greater than or equal to the required one
idx = find(standard_sections >= required_s, 1, 'first');
if isempty(idx)
    standard_s = NaN; % Indicates required section is larger than available
else
    standard_s = standard_sections(idx);
end

fprintf('\n--- Cross-Section Calculation ---\n');
fprintf('Max allowed voltage drop: %.2f V (%.1f%%)\n', max_drop_V, max_drop_percent);
fprintf('Calculated minimum cross-section required: %.2f mm^2\n', required_s);
if ~isnan(standard_s)
    fprintf('Suggested standard cross-section: %d mm^2\n', standard_s);
else
    fprintf('WARNING: Required cross-section is larger than standard tables allow.\n');
end

end

