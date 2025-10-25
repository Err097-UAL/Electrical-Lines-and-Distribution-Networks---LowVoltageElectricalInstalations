% =========================================================================
% MASTER SCRIPT for Week 3: Network Topology (V2 - Comparison)
% =========================================================================
% Description:
% This script is the main entry point for the Week 3 coursework. It allows
% the user to select which type of network they wish to analyze and then
% launches the corresponding analysis and reporting module.
% MODIFIED: Standardized menu function call to 'centeredMenu3'.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- User Selection of Analysis Case ---
% UPDATED: Changed centeredMenu32 to centeredMenu3
analysisChoice = centeredMenu3('Select which network type to analyze:', ...
                              'Radial Networks (Problem 1)', ...
                              'Networks Fed from Both Ends (Problem 2)', ...
                              'Ring and Meshed Networks (Problem 3)', ...
                              '--- NETWORK COMPARISON TOOL ---');

%% --- Run the Selected Analysis Script ---
switch analysisChoice
    case 1 % --- RADIAL NETWORKS ---
        disp('--- Launching Radial Network Analysis Module ---');
        run('H_Run_Analysis_And_Report.m'); % Assuming H module is Radial

    case 2 % --- DUAL-FED NETWORKS ---
        disp('--- Launching Dual-Fed Network Analysis Module ---');
        % Assuming I module is Dual-Fed based on Week3_Master context
        if exist('I_Run_Analysis_And_Report.m', 'file') 
             run('I_Run_Analysis_And_Report.m');
        else 
             run('B_Run_Analysis_And_Report.m'); % Fallback to original name
        end
       
    case 3 % --- RING/MESHED NETWORKS ---
        disp('--- Launching Ring and Meshed Network Analysis Module ---');
        run('C_Run_Analysis_And_Report.m');
        
    case 4 % --- NEW: COMPARISON TOOL ---
        disp('--- Launching Network Comparison Tool ---');
        run('C_Run_Comparison_And_Report.m');
         
    case 0
        disp('No analysis selected. Exiting.');
end
