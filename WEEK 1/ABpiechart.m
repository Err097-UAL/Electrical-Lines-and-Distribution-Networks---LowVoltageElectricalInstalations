% MATLAB Script for Week 1 Project: Conductor Type Visualization
%
% Project: Electrical Lines and Distribution Networks
% Task: Generate a pie chart of conductor types for different installations.
% Author: Student Name
% Date: September 23, 2025
%
% Source: This script addresses the requirements outlined in the "Block 2 Project"
% document, section 2.2, for visualizing project data.

% --- Configuration ---
clear;      % Clear workspace variables
clc;        % Clear command window
close all;  % Close all open figures

% --- Data Definition ---
% Define the conductor types used in each installation as a structure.
% This data simulates the output of a selection analysis.
powerLines.IndustrialFacility.TypicalConductor = 'XLPE Insulated Copper';
powerLines.ResidentialComplex.TypicalConductor = 'PVC Insulated Copper';
powerLines.CommercialCentreMV.TypicalConductor = 'XLPE Insulated Aluminum';
powerLines.CommercialCentreLV.TypicalConductor = 'XLPE Insulated Copper';

% --- Data Processing ---
% Consolidate all conductor types into a single cell array for analysis.
conductors = {
    powerLines.IndustrialFacility.TypicalConductor;
    powerLines.ResidentialComplex.TypicalConductor;
    powerLines.CommercialCentreMV.TypicalConductor;
    powerLines.CommercialCentreLV.TypicalConductor
};

% Convert the cell array to a categorical array to easily group and count.
% Source: MATLAB Documentation on Categorical Arrays for data analysis.
conductorCategories = categorical(conductors);

% Get the unique conductor types and their respective counts.
uniqueConductors = categories(conductorCategories);
conductorCounts = countcats(conductorCategories);
percentages = 100 * conductorCounts / sum(conductorCounts);

% --- Visualization ---
% Create a new figure for the pie chart.
fig = figure('Name', 'Conductor Type Distribution', 'NumberTitle', 'off');
set(fig, 'Color', 'white'); % Set background color to white for clarity

% Generate the pie chart.
p = pie(conductorCounts);
title('Distribution of Conductor Types Across Installations', 'FontSize', 14, 'FontWeight', 'bold');

% --- Chart Enhancement ---
% Create detailed labels for the legend, including conductor type, count, and percentage.
legendLabels = cell(size(uniqueConductors));
for i = 1:length(uniqueConductors)
    legendLabels{i} = sprintf('%s (%d installation(s), %.1f%%)', uniqueConductors{i}, conductorCounts(i), percentages(i));
end

% Add a legend to the chart for better readability.
% Source: MATLAB Documentation on `legend` function.
lgd = legend(legendLabels, 'Location', 'northeastoutside', 'FontSize', 10);
title(lgd, 'Conductor Key');

% --- Save the Output ---
% Save the figure as a high-quality PNG file for inclusion in the technical report.
% The file will be saved in the current MATLAB directory.
outputFileName = 'conductor_pie_chart.png';
saveas(fig, outputFileName);

fprintf('Pie chart has been successfully generated and saved as %s\n', outputFileName);