% =========================================================================
% MASTER SCRIPT for Week 2: Advanced Line Calculations
% =========================================================================
% Description:
% This script is the central launcher for all modules developed for the
% Week 2 coursework (E, F, and G). It has been updated to call the
% correct, final versions of all analysis scripts.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- Main Menu Loop ---
while true
    % Call the final version of the menu function
    analysisChoice = centeredMenu2('Select Week 2 Analysis Suite:', ...
                                   'Problem E: Conductor Heating Analysis', ...
                                   'Problem F: Voltage Drop Analysis', ...
                                   'Problem G: Conductor Sizing Analysis', ...
                                   'Exit Program');

    % Process the user's choice
    try
        switch analysisChoice
            case 1
                % --- E: CONDUCTOR HEATING ---
                disp('--- Launching Conductor Heating Analysis ---');
                run('E0_Run_Analysis_and_Report.m');
                disp('Press any key to return to the main menu...');
                pause;

            case 2
                % --- F: VOLTAGE DROP ---
                disp('--- Launching Voltage Drop Analysis ---');
                run('F1_VoltageDropAnalysis.m');
                disp('Press any key to return to the main menu...');
                pause;
            
            case 3
                % --- G: CONDUCTOR SIZING ---
                disp('--- Launching Conductor Sizing Analysis ---');
                G1_ConductorSizingAnalysis(); % This module is a function
                disp('Press any key to return to the main menu...');
                pause;

            case 4
                disp('Exiting the Week 2 Analysis Suite.');
                return; % Exit the script
                
            case 0
                disp('Menu closed. Exiting the Week 2 Analysis Suite.');
                return; % Exit the script
        end
        
    catch ME
        fprintf('\nERROR encountered while running the selected module.\n');
        fprintf('MATLAB reported the following error:\n');
        fprintf('"%s" in file "%s" at line %d.\n', ME.message, ME.stack(1).name, ME.stack(1).line);
        disp('Press any key to return to the main menu...');
        pause;
    end
end

