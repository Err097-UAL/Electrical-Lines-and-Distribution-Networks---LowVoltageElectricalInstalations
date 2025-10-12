% =========================================================================
% MASTER SCRIPT for Week 1: Line Classification and Basic Calculations
% =========================================================================
% Description:
% This script acts as a central launcher for all the analysis and
% visualization tools developed for the Week 1 coursework. It provides a
% user-friendly menu to execute each of the individual scripts.
%
% FIX: Replaced 'break' with 'return' for the exit conditions to ensure
% the script terminates immediately and reliably.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- Main Menu Loop ---
while true
    % Call the menu function and store the output in a variable 'choice'.
    choice = centeredMenu1('Select which Week 1 Analysis to run:', ...
                           'Problem A1: Line Classification Database', ...
                           'Problem A2: Interactive Line Designer', ...
                           'Problem A3: Conductor Type Pie Chart', ...
                           'Problem B1-B3: Conductor Material Comparison', ...
                           'Problem C1: Insulation Systems Comparison', ...
                           'Problem D1: Basic Line Calculations', ...
                           'Exit Program');

    % Process the user's choice
    try
        switch choice
            case 1
                disp('--- Running A1: Line Classification & Selection ---');
                run('A1_Line_Classification_And_Selection.m');
                disp('Press any key to return to the main menu...');
                pause;

            case 2
                disp('--- Running A2: Interactive Line Designer ---');
                run('A2_LineTypeSelector.m');
                % This script already pauses for input, so no extra pause needed.

            case 3
                disp('--- Running A3: Conductor Type Pie Chart ---');
                run('A3_piechart.m');
                disp('Press any key to return to the main menu...');
                pause;

            case 4
                disp('--- Running B1-B3: Conductor Material Comparison ---');
                run('B2_ElectricalConductivityWithPowerLossV2.m');
                run('B3_StrenghtPropertyComparisons.m');
                msgbox('Conductor material comparison complete. Check plots and command window for results.');
                disp('Press any key to return to the main menu...');
                pause;

            case 5
                disp('--- Running C1: Insulation Systems Comparison ---');
                run('C1_InsulationSystems.m');
                disp('Press any key to return to the main menu...');
                pause;

            case 6
                disp('--- Running D1: Basic Line Calculations ---');
                run('D1_BasicLineCalculations.m');
                disp('Press any key to return to the main menu...');
                pause;

            case 7
                disp('Exiting the Week 1 Analysis Suite.');
                return; % Exit the script immediately
                
            case 0
                disp('Menu closed. Exiting the Week 1 Analysis Suite.');
                return; % Exit the script immediately
        end
        
    catch ME
        fprintf('\nERROR encountered while running the selected module.\n');
        fprintf('MATLAB reported the following error:\n');
        fprintf('"%s" in file "%s" at line %d.\n', ME.message, ME.stack(1).name, ME.stack(1).line);
        disp('Press any key to return to the main menu...');
        pause;
    end
end

