% =========================================================================
% MAIN SCRIPT for Conductor Cross-Section Sizing (V2 - Integrated)
% =========================================================================
% MODIFIED:
% - Renamed from C1_CrossSection.m for consistency.
% - Integrated into the master project, controlled by 'sizing_scenarioChoice'.
% - The script's workflow changes based on the selected scenario.
% - All user menus are now centered.
% =========================================================================

%% --- Cleanup and Initialization ---
% clc; clear; close all; % Controlled by master script

%% --- Scenario Selection ---
if ~exist('sizing_scenarioChoice', 'var')
    sizing_scenarioChoice = centeredMenu('Select Sizing Criterion:', 'Voltage Drop (Student A)', 'Current-Carrying Capacity (Student B)', 'Economic Optimization (Student C)');
end

%% --- Define Physical & Economic Constants ---
sigma_copper = 56;
sigma_aluminum = 36;
LCC_years = 20;
hours_per_year = 4000;
cost_per_kWh = 0.15;

%% --- User Input ---
disp('--- Conductor Sizing Input ---');
lineTypeChoice = centeredMenu('Select Line Type:', 'Single-Phase', 'Three-Phase');
if lineTypeChoice == 1, lineType = 'single-phase'; else, lineType = 'three-phase'; end
if strcmp(lineType, 'single-phase'), U_source = input('Enter source voltage (L-N) [V] (e.g., 230): ');
else, U_source = input('Enter source voltage (L-L) [V] (e.g., 400): '); end
loadCurrent = input('Enter load current [A] (e.g., 45): ');
cos_phi = input('Enter load power factor (e.g., 0.9): ');
lineLength = input('Enter total line length [m] (e.g., 200): ');
vd_limit_percent = input('Enter maximum allowable voltage drop [%] (e.g., 5): ');
materialChoice = centeredMenu('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 1, material = 'Copper'; sigma = sigma_copper; else, material = 'Aluminum'; sigma = sigma_aluminum; end

deltaU_max = U_source * (vd_limit_percent / 100);

%% --- Execute Analysis Based on Scenario ---
switch sizing_scenarioChoice
    case 1 % Student A: Voltage Drop Criterion
        fprintf('\n--- ANALYSIS by VOLTAGE DROP Criterion ---\n');
        s_vd = C2_calculateRequiredSection(lineType, lineLength, loadCurrent, cos_phi, sigma, deltaU_max);
        fprintf('Theoretical section required for voltage drop: %.2f mm^2\n', s_vd);
        [s_final, ampacity] = C3_selectStandardSection(s_vd, material);
        fprintf('Selected standard section: %.2f mm^2\n', s_final);
        if loadCurrent > ampacity
            fprintf('WARNING: This section may not support the load current! (Load: %.1f A, Ampacity: %.1f A)\n', loadCurrent, ampacity);
        end
        final_vd = C6_verifyFinalDesign(lineType, lineLength, loadCurrent, cos_phi, sigma, s_final, U_source);
        fprintf('Final calculated voltage drop with %.2f mm^2 section: %.2f%%\n', s_final, final_vd);

    case 2 % Student B: Current-Carrying Capacity Criterion
        fprintf('\n--- ANALYSIS by CURRENT-CARRYING CAPACITY Criterion ---\n');
        [s_final, ~, all_sections] = C3_selectStandardSection(0, material); % Get the table
        
        s_ampacity_options = all_sections([all_sections.ampacity] >= loadCurrent, :);
        if isempty(s_ampacity_options)
            error('No standard conductor can support the specified load current of %.1f A.', loadCurrent);
        end
        s_final = s_ampacity_options(1).section; % Select the smallest section that meets ampacity
        
        fprintf('Minimum section required for ampacity (%.1f A): %.2f mm^2\n', loadCurrent, s_final);
        final_vd = C6_verifyFinalDesign(lineType, lineLength, loadCurrent, cos_phi, sigma, s_final, U_source);
        fprintf('Final calculated voltage drop with this section: %.2f%%\n', final_vd);
        if final_vd > vd_limit_percent
            fprintf('WARNING: This section does not meet the voltage drop requirement! (Calculated: %.2f%%, Limit: %.1f%%)\n', final_vd, vd_limit_percent);
        end

    case 3 % Student C: Economic Optimization
        fprintf('\n--- ANALYSIS by ECONOMIC OPTIMIZATION Criterion ---\n');
        % 1. Technical Sizing First
        s_vd = C2_calculateRequiredSection(lineType, lineLength, loadCurrent, cos_phi, sigma, deltaU_max);
        [s_vd_std, ~] = C3_selectStandardSection(s_vd, material);
        
        [~, ~, all_sections] = C3_selectStandardSection(0, material);
        s_ampacity_options = all_sections([all_sections.ampacity] >= loadCurrent, :);
        if isempty(s_ampacity_options), error('Load current %.1f A is too high for available conductors.', loadCurrent); end
        s_amp_std = s_ampacity_options(1).section;
        
        s_technical = max(s_vd_std, s_amp_std);
        fprintf('Technically minimum required section: %.2f mm^2\n', s_technical);
        
        % 2. Economic Analysis
        idx_start = find([all_sections.section] == s_technical);
        sections_to_analyze = all_sections(idx_start:end);
        
        num_sections = numel(sections_to_analyze);
        total_costs = zeros(1, num_sections); cable_costs = zeros(1, num_sections); loss_costs = zeros(1, num_sections);

        for i = 1:num_sections
            [total_costs(i), cable_costs(i), loss_costs(i)] = C4_calculateLifecycleCost(...
                sections_to_analyze(i), lineType, lineLength, loadCurrent, cos_phi, sigma,...
                LCC_years, hours_per_year, cost_per_kWh);
        end

        [min_cost, optimal_idx] = min(total_costs);
        s_optimal = sections_to_analyze(optimal_idx).section;

        fprintf('--------------------------------------------------\n');
        fprintf('ECONOMIC OPTIMIZATION RESULTS:\n');
        fprintf('Economically Optimal Section: %.2f mm^2\n', s_optimal);
        fprintf('Associated Lifecycle Cost: %.2f\n', min_cost);
        if s_optimal == s_technical
            disp('The smallest technically compliant section is also the most economical.');
        else
            cost_at_technical = total_costs(1);
            fprintf('Recommendation: Using a larger cable (%.2f mm^2 vs %.2f mm^2) could save %.2f over %d years.\n', s_optimal, s_technical, cost_at_technical-min_cost, LCC_years);
        end
        
        C5_plotEconomicAnalysis(sections_to_analyze, cable_costs, loss_costs, total_costs, s_technical, s_optimal);
end

if sizing_scenarioChoice == 0, disp('No scenario selected. Exiting.'); end
