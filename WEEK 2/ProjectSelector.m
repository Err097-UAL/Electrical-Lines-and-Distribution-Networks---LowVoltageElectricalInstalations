% =========================================================================
% MASTER SCRIPT for Electrical Line Design Suite (V2.1 - Centered)
% =========================================================================
% MODIFIED: This version now calls the custom 'centeredMenu.m' function
% to ensure all selection dialogs appear in the middle of the screen.
%
% Author: Gemini
% Date: 2025-10-05
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- User Selection of Analysis Case ---
analysisChoice = centeredMenu('Select which project case to work with:', ...
                              'Conductor Heating Analysis', ...
                              'Voltage Drop Analysis', ...
                              'Conductor Sizing Analysis');

%% --- Run the Selected Analysis Script ---
switch analysisChoice
    case 1 % --- CONDUCTOR HEATING ---
        scenarioChoice = centeredMenu('Select Heating Scenario:', 'Underground (Student A)', 'Overhead (Student B)', 'Building/Grouped (Student C)');
        if scenarioChoice > 0
            % Pass the user's choice to the workspace for the script to use
            assignin('base', 'installationChoice', scenarioChoice);
            disp('--- Launching Conductor Heating Analysis ---');
            run('A1_ConductorHeatingAnalysis.m');
            % Clean up the variable after the script finishes
            evalin('base', 'clear installationChoice');
        end

    case 2 % --- VOLTAGE DROP ---
        scenarioChoice = centeredMenu('Select Voltage Drop Scenario:', 'Lighting Circuit (REBT 4.5%)', 'Power Circuit (REBT 6.5%)', 'Main Feeder');
        if scenarioChoice > 0
            assignin('base', 'vd_scenarioChoice', scenarioChoice);
            disp('--- Launching Voltage Drop Analysis ---');
            if exist('B1_VoltageDropAnalysis.m', 'file')
                run('B1_VoltageDropAnalysis.m');
            else
                warning('Voltage Drop script (e.g., ''B1_VoltageDropAnalysis.m'') not found.');
            end
            evalin('base', 'clear vd_scenarioChoice');
        end

    case 3 % --- CONDUCTOR SIZING ---
         scenarioChoice = centeredMenu('Select Sizing Priority:', 'Size by Voltage Drop Limit', 'Size by Current-Carrying Capacity', 'Economic Optimization');
         if scenarioChoice > 0
            assignin('base', 'sizing_scenarioChoice', scenarioChoice);
            disp('--- Launching Conductor Sizing Analysis ---');
            if exist('C1_ConductorSizingAnalysis.m', 'file')
                run('C1_ConductorSizingAnalysis.m');
            else
                warning('Conductor Sizing script (e.g., ''C1_ConductorSizingAnalysis.m'') not found.');
            end
            evalin('base', 'clear sizing_scenarioChoice');
         end
         
    case 0
        disp('No analysis selected. Exiting.');
end

