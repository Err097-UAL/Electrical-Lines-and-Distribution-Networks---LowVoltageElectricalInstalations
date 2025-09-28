% =========================================================================
% MAIN SCRIPT for Conductor Cross-Section Sizing
% =========================================================================
% Description:
% This script provides a comprehensive tool for selecting the optimal
% cross-section for a low-voltage electrical conductor. The process is
% twofold:
% 1. Technical Sizing: It determines the minimum standard cross-section
%    that satisfies both the maximum allowable voltage drop and the
%    conductor's current-carrying capacity (ampacity).
% 2. Economic Optimization: It performs a lifecycle cost analysis to find
%    the cross-section that minimizes the sum of the initial cable cost
%    and the cost of energy losses over a specified period.
%
% How to Run:
% 1. Ensure all required function files are in the same directory:
%    - calculateRequiredSection.m
%    - selectStandardSection.m
%    - calculateLifecycleCost.m
%    - plotEconomicAnalysis.m
%    - verifyFinalDesign.m
% 2. Run this script from the MATLAB command window.
%
% Author: Gemini
% Date: 2025-09-28
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- Define Physical & Economic Constants ---
% Material Conductivities [S*m/mm^2 or Siemens*meter/mm^2]
% Note: sigma = 1 / rho (resistivity)
sigma_copper = 56;
sigma_aluminum = 36;

% Economic Parameters (editable)
LCC_years = 20;            % Lifecycle analysis period [years]
cost_per_kWh = 0.15;       % Average cost of electricity [currency/kWh]
hours_per_year = 8760;     % Total hours in a year

%% --- User Input ---
disp('--- Conductor Cross-Section Sizing ---');

% System Parameters
U_source = input('Enter source voltage (phase-neutral for 1-ph, phase-phase for 3-ph) [V]: ');
lineTypeChoice = menu('Select Line Type:', 'Single-Phase', 'Three-Phase');
circuitTypeChoice = menu('Select Circuit Type (for Voltage Drop Limit):', 'Lighting', 'Power (Other Uses)');

% Load Parameters
loadCurrent = input('Enter the load current [A]: ');
cos_phi = input('Enter the load power factor (e.g., 0.9): ');

% Line Parameters
lineLength = input('Enter the total line length [m]: ');
materialChoice = menu('Select Conductor Material:', 'Copper', 'Aluminum');

%% --- Pre-Calculations ---

% Set line type string
if lineTypeChoice == 1, lineType = 'single-phase'; else, lineType = 'three-phase'; end

% Set circuit type string and voltage drop limit
if circuitTypeChoice == 1
    circuitType = 'lighting';
    max_deltaU_percent = 4.5;
else
    circuitType = 'power';
    max_deltaU_percent = 6.5;
end
max_deltaU_volts = U_source * (max_deltaU_percent / 100);

% Set material conductivity
if materialChoice == 1
    sigma = sigma_copper;
    materialName = 'Copper';
else
    sigma = sigma_aluminum;
    materialName = 'Aluminum';
end

%% --- Part 1: Technical Sizing ---
disp('--- Running Technical Analysis ---');

% 1.1 Calculate the theoretically required cross-section for voltage drop
s_required_vd = C2_calculateRequiredSection(lineType, lineLength, loadCurrent, cos_phi, sigma, max_deltaU_volts);

% 1.2 Select the next standardized section and get its ampacity
[s_technical, ampacity, standard_sections_data] = C3_selectStandardSection(s_required_vd, materialName);

% 1.3 Check if the selected section's ampacity is sufficient
if ampacity < loadCurrent
    fprintf('Warning: Section %.2f mm^2 (for voltage drop) has ampacity (%.1f A) less than load current (%.1f A).\n', s_technical, ampacity, loadCurrent);
    disp('Searching for the next size up that meets current requirements...');
    % Find the smallest standard section that can handle the current
    valid_sections = standard_sections_data([standard_sections_data.ampacity] >= loadCurrent);
    if isempty(valid_sections)
        error('No standard cable size can handle the specified load current.');
    end
    s_technical_ampacity = valid_sections(1).section;
    % The final technical choice is the LARGER of the two requirements
    s_technical = max(s_technical, s_technical_ampacity);
end

% 1.4 Final verification of the technically chosen section
final_vd_percent = C6_verifyFinalDesign(lineType, lineLength, loadCurrent, cos_phi, sigma, s_technical, U_source);

fprintf('--------------------------------------------------\n');
fprintf('TECHNICAL SIZING RESULTS:\n');
fprintf('Required section for %.1f%% voltage drop: %.2f mm^2\n', max_deltaU_percent, s_required_vd);
fprintf('Smallest STANDARD section satisfying voltage drop and ampacity: %.2f mm^2\n', s_technical);
fprintf('Final verified voltage drop with %.2f mm^2 section: %.2f%%\n', s_technical, final_vd_percent);
fprintf('--------------------------------------------------\n');


%% --- Part 2: Economic Optimization ---
disp('--- Running Economic Analysis ---');
disp('Analyzing lifecycle costs for a range of standard conductor sizes...');

% Analyze sections from the minimum technical size up to several larger sizes
startIndex = find([standard_sections_data.section] == s_technical);
if isempty(startIndex), startIndex = 1; end
endIndex = min(startIndex + 5, numel(standard_sections_data)); % Analyze up to 5 sizes larger
sections_to_analyze = standard_sections_data(startIndex:endIndex);

% Calculate costs for each section
num_sections = numel(sections_to_analyze);
total_costs = zeros(1, num_sections);
cable_costs = zeros(1, num_sections);
loss_costs = zeros(1, num_sections);

for i = 1:num_sections
    current_section_data = sections_to_analyze(i);
    [total_costs(i), cable_costs(i), loss_costs(i)] = C4_calculateLifecycleCost(...
        current_section_data, lineType, lineLength, loadCurrent, cos_phi, sigma,...
        LCC_years, hours_per_year, cost_per_kWh);
end

% Find the economically optimal section
[min_cost, optimal_idx] = min(total_costs);
s_optimal = sections_to_analyze(optimal_idx).section;

fprintf('--------------------------------------------------\n');
fprintf('ECONOMIC OPTIMIZATION RESULTS:\n');
fprintf('Analysis Period: %d years, Electricity Cost: %.2f /kWh\n', LCC_years, cost_per_kWh);
fprintf('Economically Optimal Section: %.2f mm^2\n', s_optimal);
fprintf('Associated Lifecycle Cost: %.2f\n', min_cost);
if s_optimal == s_technical
    disp('The smallest technically compliant section is also the most economical.');
else
    fprintf('Recommendation: Using a larger cable (%.2f mm^2) could save %.2f over %d years.\n',...
        s_optimal, total_costs(1) - min_cost, LCC_years);
end
fprintf('--------------------------------------------------\n');

%% --- Visualization ---
C5_plotEconomicAnalysis(sections_to_analyze, cable_costs, loss_costs, total_costs, s_technical, s_optimal);

disp('Analysis complete.');
