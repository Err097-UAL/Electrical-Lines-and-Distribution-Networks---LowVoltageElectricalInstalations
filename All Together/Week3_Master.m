% =========================================================================
% MASTER SCRIPT for Week 3: Network Topology (V3 - With Pause)
% =========================================================================
% Description:
% This script is the main entry point for the Week 3 coursework. It allows
% the user to select which type of network they wish to analyze and then
% launches the corresponding analysis and reporting module.
% MODIFIED: Added a 'pause' command after running a module to allow the
%           user to view plots before the menu reappears. Also added
%           'close all' before the pause to clear old figures.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- Main Menu Loop ---
while true
    analysisChoice = centeredMenu3('Select which network type to analyze:', ...
                                  'Radial Networks (Problem 1)', ...
                                  'Networks Fed from Both Ends (Problem 2)', ...
                                  'Ring and Meshed Networks (Problem 3)', ...
                                  '--- NETWORK COMPARISON TOOL ---', ...
                                  '--- Exit ---'); % Added Exit option

    % --- Run the Selected Analysis Script ---
    try % Start of try-catch for error handling
        switch analysisChoice
            case 1 % --- RADIAL NETWORKS ---
                disp('--- Launching Radial Network Analysis Module ---');
                run('H_Run_Analysis_And_Report.m');

            case 2 % --- DUAL-FED NETWORKS ---
                disp('--- Launching Dual-Fed Network Analysis Module ---');
                run('I_Run_Analysis_And_Report.m');

            case 3 % --- RING/MESHED NETWORKS ---
                disp('--- Launching Ring and Meshed Network Analysis Module ---');
                run('J_Run_Analysis_And_Report.m');
                
            case 4 % --- NETWORK COMPARISON TOOL ---
                disp('--- Launching Network Comparison Tool ---');
                run('J_Run_Comparison_And_Report.m');
                 
            case 5 % --- Exit Option ---
                 disp('Exiting the Week 3 Analysis Suite.');
                 break; % Exit the while loop

            case 0 % --- Menu Closed ---
                disp('Menu closed. Exiting the Week 3 Analysis Suite.');
                break; % Exit if user closes the menu
                
            otherwise
                 disp('Invalid selection made.'); % Should not happen with GUI menu
        end
        
        % --- Pause to allow user to view plots ---
        % Check if a valid module was run (not exit or cancel)
        if analysisChoice > 0 && analysisChoice <= 4 
            disp(' '); % Add a blank line for spacing
            disp('Analysis complete. Plots generated.');
            disp('Press any key in the Command Window to return to the main menu...');
            pause; % Wait indefinitely for any key press
            
            % Close figures from the previous run AFTER pausing
            close all; 
        end

    catch ME % Start of the error handling block
        fprintf('\nERROR encountered while running the selected module.\n');
        fprintf('MATLAB reported the following error:\n');
        fprintf('"%s" in file "%s" at line %d.\n', ME.message, ME.stack(1).name, ME.stack(1).line);
        disp('Press any key to return to the main menu...');
        pause; % Pause even if there was an error
        close all; % Close figures after error pause
    end % End of the try-catch block
    
end % End of the while true loop

disp(' ');
disp('Week 3 Analysis Suite terminated.');

