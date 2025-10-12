function results = I1_DualFed_Analysis()
% =========================================================================
% FUNCTION: Main Dual-Fed Network Analysis (V7 - Unifilar)
% =========================================================================
% Description:
% This is the main analysis function for the Dual-Fed Network module.
% It handles all user input for the different student scenarios, including
% the reliability analysis for Student C. It calculates current
% distribution and voltage profiles.
%
% MODIFIED:
% - Corrected a sign error in the Ia calculation.
% - Integrated the material properties database.
% - Added a call to the new B4_PlotUnifilarDiagram function.
% =========================================================================
results = []; 
scenarioChoice = centeredMenu3('Select Dual-Fed Network Scenario:', ...
    'Symmetrical Network (Single Load) - Student A', ...
    'Asymmetrical Network (Single Load) - Student B', ...
    'Backup Feeding / Reliability Analysis (Multiple Loads) - Student C');
if scenarioChoice == 0, return; end

% --- Get common inputs ---
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
sigma = materialProps.sigma;

crossSection = input('Enter conductor cross-section [mm^2]: ');
L_total = input('Enter total distance between Source A and B [m]: ');
loads = [];

% --- Gather scenario-specific inputs ---
switch scenarioChoice
    case 1 % Symmetrical
        results.scenarioName = 'Symmetrical Network';
        Ua = input('Enter source voltage (Ua = Ub) [V]: '); Ub = Ua;
        loads(1).current = input('Enter current of the single central load [A]: ');
        loads(1).distance = L_total / 2;
    case 2 % Asymmetrical
        results.scenarioName = 'Asymmetrical Network';
        Ua = input('Enter Source A voltage [V]: ');
        Ub = input('Enter Source B voltage [V]: ');
        loads(1).current = input('Enter current of the single load [A]: ');
        loads(1).distance = input('Enter distance of load from Source A [m]: ');
    case 3 % Reliability / Backup Scenario
        results.scenarioName = 'Backup Feeding / Reliability';
        Ua = input('Enter Source A voltage [V]: '); 
        Ub = input('Enter Source B voltage [V]: ');
        num_loads = input('Enter number of loads for the reliability analysis: ');
        for i = 1:num_loads
            loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
            loads(i).distance = input(['Enter distance of load ' num2str(i) ' from Source A [m]: ']);
        end
end

% --- Calculations ---
I_total = sum([loads.current]);
sorted_loads = sortrows(struct2table(loads), 'distance');
sorted_loads = table2struct(sorted_loads);

% 1. NORMAL OPERATION (DUAL-FED)
R_total = (1/(sigma*crossSection)) * L_total;
% Corrected formula for Ia
Ia = ( (Ua - Ub) / R_total ) + ...
     (1/L_total) * sum(arrayfun(@(l) l.current * (L_total - l.distance), loads));
Ib = I_total - Ia;

min_voltage_normal = inf;
min_voltage_node_distance = 0;
cumulative_Ia = Ia;
voltage_at_node = Ua;
nodes_to_check = [struct('distance', 0, 'current', 0); sorted_loads];
for i = 2:length(nodes_to_check)
    segment_length = nodes_to_check(i).distance - nodes_to_check(i-1).distance;
    voltage_drop_segment = (1/(sigma*crossSection)) * cumulative_Ia * segment_length;
    voltage_at_node = voltage_at_node - voltage_drop_segment;
    if voltage_at_node < min_voltage_normal, min_voltage_normal = voltage_at_node; min_voltage_node_distance = nodes_to_check(i).distance; end
    cumulative_Ia = cumulative_Ia - nodes_to_check(i).current;
end

% 2. RELIABILITY ANALYSIS (only for Student C)
if scenarioChoice == 3
    % Scenario A: Source B Fails (Radial from A)
    radial_nodes_A = sorted_loads;
    total_drop_fail_B = 0;
    for i = 1:length(radial_nodes_A)
        current_in_segment = sum([radial_nodes_A(i:end).current]);
        if i == 1, segment_length = radial_nodes_A(i).distance; else, segment_length = radial_nodes_A(i).distance - radial_nodes_A(i-1).distance; end
        drop_segment = (1 / (sigma * crossSection)) * current_in_segment * segment_length;
        total_drop_fail_B = total_drop_fail_B + drop_segment;
    end
    results.min_voltage_fail_B = Ua - total_drop_fail_B;

    % Scenario B: Source A Fails (Radial from B)
    radial_nodes_B = sortrows(struct2table(loads), 'distance', 'descend'); % Sort from B's perspective
    radial_nodes_B = table2struct(radial_nodes_B);
    total_drop_fail_A = 0;
    for i = 1:length(radial_nodes_B)
        current_in_segment = sum([radial_nodes_B(i:end).current]);
        if i == 1, segment_length = L_total - radial_nodes_B(i).distance; else, segment_length = radial_nodes_B(i-1).distance - radial_nodes_B(i).distance; end
        drop_segment = (1 / (sigma * crossSection)) * current_in_segment * segment_length;
        total_drop_fail_A = total_drop_fail_A + drop_segment;
    end
    results.min_voltage_fail_A = Ub - total_drop_fail_A;
end

% --- Finalize results and Plot ---
results.Ua = Ua; results.Ub = Ub;
results.materialName = materialName;
results.sigma = sigma; results.crossSection = crossSection;
results.L_total = L_total; results.loads = sorted_loads;
results.I_total = I_total;
results.Ia = Ia; results.Ib = Ib;
results.min_voltage_normal = min_voltage_normal;
results.min_voltage_node_distance = min_voltage_node_distance;

% Generate Plots
I4_PlotUnifilarDiagram(results); % Generate the schematic diagram
I2_PlotDualFedProfile(results); 
I3_PlotLoadingDiagram(results); 
end

