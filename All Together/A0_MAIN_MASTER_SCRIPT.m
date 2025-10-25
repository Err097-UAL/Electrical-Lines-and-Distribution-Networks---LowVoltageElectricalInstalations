% =========================================================================
% A0_MAIN_MASTER_SCRIPT - Main Launcher for the Entire EET Analysis Suite
% =========================================================================
% Description:
% This script serves as the single entry point for the entire electrical
% engineering analysis project. It provides a top-level graphical user
% menu that allows the user to launch the master scripts for each of the
% three weeks of coursework.
%
% To run the entire project, simply execute this script.
% =========================================================================

%% --- Cleanup and Initialization --- 
% Ensures a clean and predictable environment each time the suite is started.
clc;
clear;
close all;
fprintf('Welcome to the Electrical Engineering Analysis Suite.\n');

%% --- Main Menu Loop ---
% This loop will continuously display the main menu until the user chooses
% to exit, allowing them to run multiple analyses in one session.
while true
    % Display the main menu. We can use any of the centeredMenu functions
    % as they all provide the necessary functionality. We'll use centeredMenu1.
    mainChoice = centeredMenu1('EET Analysis Suite - Main Menu', ...
                               'Week 1: Line Classification & Materials', ...
                               'Week 2: Advanced Line Calculations', ...
                               'Week 3: Network Topology Analysis', ...
                               'Exit Entire Program');

    % Process the user's choice from the main menu
    try
        switch mainChoice
            case 1
                % --- Launch Week 1 Master Script ---
                fprintf('\nLaunching the Week 1 Analysis Suite...\n');
                % The 'run' command executes the script in the current
                % workspace. Once Week1_Master finishes (i.e., its own
                % loop is exited), control will return here.
                run('Week1_Master.m');
                fprintf('\nReturned to the Main Menu.\n');

            case 2
                % --- Launch Week 2 Master Script ---
                fprintf('\nLaunching the Week 2 Analysis Suite...\n');
                run('week2_master.m');
                fprintf('\nReturned to the Main Menu.\n');

            case 3
                % --- Launch Week 3 Master Script ---
                fprintf('\nLaunching the Week 3 Analysis Suite...\n');
                run('Week3_Master.m');
                fprintf('\nReturned to the Main Menu.\n');

            case 4
                % --- Exit the Program ---
                fprintf('\nExiting the EET Analysis Suite. Goodbye!\n');
                close all; % Close any lingering figures
                return; % Exit the script immediately

            case 0
                % --- Handle Menu Close Event ---
                % This case is triggered if the user closes the menu window
                % without making a selection.
                fprintf('\nMain menu closed. Exiting the EET Analysis Suite.\n');
                return; % Exit the script
        end

    catch ME
        % --- Robust Error Handling ---
        % This block will catch any unexpected errors that occur while
        % trying to run one of the master scripts.
        fprintf(2, '\nAN UNEXPECTED ERROR OCCURRED IN THE MAIN LAUNCHER!\n');
        fprintf(2, 'MATLAB reported the following error:\n');
        fprintf(2, '"%s" in file "%s" at line %d.\n', ME.message, ME.stack(1).name, ME.stack(1).line);
        warndlg('A critical error occurred. Returning to the main menu. Check the Command Window for details.', 'Master Script Error');
        disp('Press any key to return to the main menu...');
        pause;
    end
end
