% =========================================================================
% MASTER SCRIPT for Electrical Line Design Suite (V5 - Final)
% =========================================================================
% MODIFIED:
% - For Case 1 (Heating), it now prompts for the scenario and then calls
%   the final reporting script 'A_Run_Analysis_And_Report.m'. This makes
%   the workflow consistent with the other analysis cases.
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
        % Get the scenario choice from the user first
        scenarioChoice = centeredMenu('Select Heating Scenario:', 'Underground (Student A)', 'Overhead (Student B)', 'Building/Grouped (Student C)');
        
        % Check if the user made a selection
        if scenarioChoice > 0
            % Pass the choice to the base workspace so the function can see it
            assignin('base', 'installationChoice', scenarioChoice);
            
            % Now, run the final reporting script
            disp('--- Launching Conductor Heating Analysis with Report ---');
            run('A0_Run_Analysis_and_Report.m');
            
            % Clean up the variable from the workspace after the script is done
            evalin('base', 'clear installationChoice');
        end

    case 2 % --- VOLTAGE DROP ---
        if ~exist('B1_VoltageDropAnalysis.m', 'file')
            warning('Voltage Drop script (B1_VoltageDropAnalysis.m) not found.');
        else
            analysisMode = centeredMenu('Select Voltage Drop Analysis Type:', 'Full Installation Analysis (Multi-Segment)', 'Simple Single Line Analysis');
            if analysisMode > 0
                assignin('base', 'vd_analysisMode', analysisMode);
                disp('--- Launching Voltage Drop Analysis ---');
                run('B1_VoltageDropAnalysis.m');
                evalin('base', 'clear vd_analysisMode');
            end
        end

    case 3 % --- CONDUCTOR SIZING ---
         if ~exist('C1_ConductorSizingAnalysis.m', 'file')
            warning('Conductor Sizing script (C1_ConductorSizingAnalysis.m) not found.');
         else
            scenarioChoice = centeredMenu('Select Sizing Criterion:', 'Voltage Drop (Student A)', 'Current-Carrying Capacity (Student B)', 'Economic Optimization (Student C)');
             if scenarioChoice > 0
                assignin('base', 'sizing_scenarioChoice', scenarioChoice);
                disp('--- Launching Conductor Sizing Analysis ---');
                run('C1_ConductorSizingAnalysis.m');
                evalin('base', 'clear sizing_scenarioChoice');
             end
         end
         
    case 0
        disp('No analysis selected. Exiting.');
end

