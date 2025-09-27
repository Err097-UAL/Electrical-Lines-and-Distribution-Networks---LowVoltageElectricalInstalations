
% You can test this in the command window by typing:
% selectLineType(20000, 'main_feeder')

% Interactive Electrical Line Designer
%
% Project: Electrical Lines and Distribution Networks
% Task: Interactively guide a user to select line topology and conductor material.
% Author: [Your Name]
% Date: September 23, 2025
%
% Description:
% This script prompts the user for key project parameters (voltage, location,
% and expected lifetime) to provide a preliminary recommendation for the
% electrical line design. It incorporates engineering logic for material
% selection based on a cost-vs-longevity trade-off.
%
% Sources:
% - Conductor Selection Logic: Based on general engineering principles where
%   Copper is favored for long-term projects (>30 years) due to its superior
%   durability and conductivity, while Aluminum is a cost-effective
%   alternative for shorter-term installations. This aligns with lifecycle
%   cost analysis practices in electrical design.
% - Topology Selection Logic: Adapted from standard distribution network design
%   practices, as discussed in "Líneas Eléctricas" (F. Gil, UAL) and the
%   "Reglamento Electrotécnico para Baja Tensión (REBT)". MT feeders are often
%   overhead for cost and heat dissipation, while BT distribution in new
%   developments is typically underground for safety and aesthetics.

% --- Initialization ---
clear;
clc;
close all;

fprintf('--------------------------------------------------\n');
fprintf('--- Interactive Electrical Line Design Assistant ---\n');
fprintf('--------------------------------------------------\n\n');

% --- Step 1: Get Project Voltage ---
fprintf('Step 1: Define Project Voltage\n');
voltage = input('Enter the nominal voltage of the line in Volts (e.g., 400 or 20000): ');

% Validate input
if isempty(voltage) || ~isnumeric(voltage) || voltage <= 0
    error('Invalid input. Please enter a positive number for the voltage.');
end

% --- Step 2: Get Line Application/Location ---
fprintf('\nStep 2: Define Line Application\n');
fprintf('   1: Main Feeder (e.g., from substation to a distribution point)\n');
fprintf('   2: Local Distribution (e.g., final connection to buildings)\n');
locationChoice = input('Select the line''s primary application (1 or 2): ');

% Map choice to string for the function
if locationChoice == 1
    location = 'main_feeder';
elseif locationChoice == 2
    location = 'local_distribution';
else
    error('Invalid selection. Please enter 1 or 2.');
end

% --- Step 3: Get Project Lifetime Expectancy ---
fprintf('\nStep 3: Define Project Lifetime for Material Selection\n');
lifetime = input('Enter the expected lifetime of the project in years (e.g., 30): ');

if isempty(lifetime) || ~isnumeric(lifetime) || lifetime <= 0
    error('Invalid input. Please enter a positive number for the lifetime.');
end

% --- Analysis and Recommendations ---
% Call functions to get recommendations based on user input

lineTopology = selectLineTopology(voltage, location);
conductorMaterial = selectConductorMaterial(lifetime);

% --- Step 4: Display Final Summary ---
fprintf('\n--------------------------------------------------\n');
fprintf('           DESIGN RECOMMENDATION SUMMARY\n');
fprintf('--------------------------------------------------\n');
fprintf('Based on your inputs:\n');
fprintf(' - Nominal Voltage: %.0f V\n', voltage);
fprintf(' - Line Application: %s\n', strrep(location, '_', ' '));
fprintf(' - Project Lifetime: %.0f years\n\n', lifetime);

fprintf('Recommendations:\n');
fprintf(' * %s\n', conductorMaterial);
fprintf(' * %s\n', lineTopology);
fprintf('--------------------------------------------------\n\n');
fprintf('Disclaimer: This is a preliminary recommendation. A detailed engineering study is required.\n');


% --- Helper Functions ---

function [lineType] = selectLineTopology(voltage, location)
    % This function suggests a line topology based on voltage and location.
    if voltage > 1000 && strcmpi(location, 'main_feeder')
        lineType = 'Topology: Overhead MT Line Recommended for cost-effectiveness and heat dissipation.';
    elseif voltage <= 1000 && strcmpi(location, 'local_distribution')
        lineType = 'Topology: Underground BT Line Recommended for safety and aesthetics in populated areas.';
    else
        % This case handles scenarios like underground MT lines or special overhead BT lines.
        lineType = 'Topology: Mixed/Special Case - Requires detailed analysis (e.g., Underground MT).';
    end
end

function [material] = selectConductorMaterial(years)
    % This function suggests a conductor material based on project lifetime.
    % Threshold is set to 30 years, a common benchmark for infrastructure projects.
    if years > 30
        material = 'Conductor Material: Copper Recommended for its high durability and lower long-term losses.';
    else
        material = 'Conductor Material: Aluminum Recommended as a cost-effective solution for shorter-term projects.';
    end
end
