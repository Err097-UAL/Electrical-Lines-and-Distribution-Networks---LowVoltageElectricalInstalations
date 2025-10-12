% =========================================================================
% MASTER SCRIPT for Week 3: Network Topology (V2 - Comparison)
% =========================================================================
% Description:
% This script is the main entry point for the Week 3 coursework. It allows
% the user to select which type of network they wish to analyze and then
% launches the corresponding analysis and reporting module.
% =========================================================================

%% --- Cleanup and Initialization ---
clc;
clear;
close all;

%% --- User Selection of Analysis Case ---
analysisChoice = centeredMenu3('Select which network type to analyze:', ...
                              'Radial Networks (Problem 1)', ...
                              'Networks Fed from Both Ends (Problem 2)', ...
                              'Ring and Meshed Networks (Problem 3)', ...
                              '--- NETWORK COMPARISON TOOL ---');

%% --- Run the Selected Analysis Script ---
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
        
    case 4 % --- NEW: COMPARISON TOOL ---
        disp('--- Launching Network Comparison Tool ---');
        run('J_Run_Comparison_And_Report.m');
         
    case 0
        disp('No analysis selected. Exiting.');
end



% % =========================================================================
% % MASTER SCRIPT for Week 3: Network Topology and Dimensioning
% % =========================================================================
% % Description:
% % This script is the main entry point for the Week 3 coursework. It allows
% % the user to select which type of network they wish to analyze and then
% % launches the corresponding, self-contained analysis and reporting module.
% % This file corrects the structure and ensures the correct modules are called.
% % =========================================================================
% 
% %% --- Cleanup and Initialization ---
% clc;
% clear;
% close all;
% 
% %% --- User Selection of Analysis Case ---
% % Initialize the variable to ensure it always exists
% analysisChoice = 0; 
% try
%     analysisChoice = centeredMenu('Select which Week 3 network type to analyze:', ...
%                                   'Radial Networks (Problem 1)', ...
%                                   'Networks Fed from Both Ends (Problem 2)', ...
%                                   'Ring and Meshed Networks (Problem 3)');
% catch ME
%     warning('The graphical menu failed with the following error:');
%     disp(ME.message);
%     disp('Please ensure centeredMenu.m is in the correct directory and up to date.');
%     disp('Exiting script.');
%     return; % Stop execution if menu fails
% end
% 
% 
% %% --- Run the Selected Analysis and Reporting Script ---
% switch analysisChoice
%     case 1 % --- RADIAL NETWORKS ---
%         % Check if the required file exists before running
%         if exist('A0_MainScript.m', 'file')
%             disp('--- Launching Radial Network Analysis Module ---');
%             run('A0_MainScript.m');
%         else
%             error('Required file A0_MainScript.m not found in the current directory.');
%         end
% 
%     case 2 % --- DUAL-FED NETWORKS ---
%         if exist('B0_MainScript.m', 'file')
%             disp('--- Launching Dual-Fed Network Analysis Module ---');
%             run('B0_MainScript.m');
%         else
%             error('Required file B_Run_Analysis_And_Report.m not found in the current directory.');
%         end
% 
%     case 3 % --- RING/MESHED NETWORKS ---
%         if exist('C0_MainScript.m', 'file')
%             disp('--- Launching Ring and Meshed Network Analysis Module ---');
%             run('C0_MainScript.m');
%         else
%             error('Required file C0_MainScript.m not found in the current directory.');
%         end
% 
%     case 0
%         disp('No analysis selected. Exiting.');
% end
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % =========================================================================
% % MASTER SCRIPT for Week 3: Network Topology (V2 - Comparison)
% % =========================================================================
% % Description:
% % This script is the main entry point for the Week 3 coursework. It allows
% % the user to select which type of network they wish to analyze and then
% % launches the corresponding analysis and reporting module.
% % =========================================================================
% 
% %% --- Cleanup and Initialization ---
% clc;
% clear;
% close all;
% 
% %% --- User Selection of Analysis Case ---
% analysisChoice = centeredMenu3('Select which network type to analyze:', ...
%                               'Radial Networks (Problem 1)', ...
%                               'Networks Fed from Both Ends (Problem 2)', ...
%                               'Ring and Meshed Networks (Problem 3)', ...
%                               '--- NETWORK COMPARISON TOOL ---');
% 
% %% --- Run the Selected Analysis Script ---
% switch analysisChoice
%     case 1 % --- RADIAL NETWORKS ---
%         disp('--- Launching Radial Network Analysis Module ---');
%         run('A_Run_Analysis_And_Report.m');
% 
%     case 2 % --- DUAL-FED NETWORKS ---
%         disp('--- Launching Dual-Fed Network Analysis Module ---');
%         run('B_Run_Analysis_And_Report.m');
% 
%     case 3 % --- RING/MESHED NETWORKS ---
%         disp('--- Launching Ring and Meshed Network Analysis Module ---');
%         run('C_Run_Analysis_And_Report.m');
% 
%     case 4 % --- NEW: COMPARISON TOOL ---
%         disp('--- Launching Network Comparison Tool ---');
%         run('C_Run_Comparison_And_Report.m');
% 
%     case 0
%         disp('No analysis selected. Exiting.');
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % =========================================================================
% % MASTER SCRIPT for Week 3: Network Topology and Dimensioning
% % =========================================================================
% % Description:
% % This script is the main entry point for the Week 3 coursework. It allows
% % the user to select which type of network they wish to analyze and then
% % launches the corresponding, self-contained analysis and reporting module.
% % This file corrects the structure and ensures the correct modules are called.
% % =========================================================================
% 
% %% --- Cleanup and Initialization ---
% clc;
% clear;
% close all;
% 
% %% --- User Selection of Analysis Case ---
% % Initialize the variable to ensure it always exists
% analysisChoice = 0; 
% try
%     analysisChoice = centeredMenu('Select which Week 3 network type to analyze:', ...
%                                   'Radial Networks (Problem 1)', ...
%                                   'Networks Fed from Both Ends (Problem 2)', ...
%                                   'Ring and Meshed Networks (Problem 3)');
% catch ME
%     warning('The graphical menu failed with the following error:');
%     disp(ME.message);
%     disp('Please ensure centeredMenu.m is in the correct directory and up to date.');
%     disp('Exiting script.');
%     return; % Stop execution if menu fails
% end
% 
% 
% %% --- Run the Selected Analysis and Reporting Script ---
% switch analysisChoice
%     case 1 % --- RADIAL NETWORKS ---
%         % Check if the required file exists before running
%         if exist('A0_MainScript.m', 'file')
%             disp('--- Launching Radial Network Analysis Module ---');
%             run('A0_MainScript.m');
%         else
%             error('Required file A0_MainScript.m not found in the current directory.');
%         end
% 
%     case 2 % --- DUAL-FED NETWORKS ---
%         if exist('B0_MainScript.m', 'file')
%             disp('--- Launching Dual-Fed Network Analysis Module ---');
%             run('B0_MainScript.m');
%         else
%             error('Required file B_Run_Analysis_And_Report.m not found in the current directory.');
%         end
% 
%     case 3 % --- RING/MESHED NETWORKS ---
%         if exist('C0_MainScript.m', 'file')
%             disp('--- Launching Ring and Meshed Network Analysis Module ---');
%             run('C0_MainScript.m');
%         else
%             error('Required file C0_MainScript.m not found in the current directory.');
%         end
% 
%     case 0
%         disp('No analysis selected. Exiting.');
% end
% 
% 