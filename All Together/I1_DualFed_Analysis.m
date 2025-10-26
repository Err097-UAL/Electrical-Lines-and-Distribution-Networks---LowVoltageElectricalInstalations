function results = I1_DualFed_Analysis()
% =========================================================================
% FUNCTION: Main Dual-Fed Network Analysis (V9 - Enhanced Comments)
% =========================================================================
% MODIFIED:
% - Added detailed comments to explicitly label the implementation of
%   the core analysis requirements.
% =========================================================================
results = []; 
scenarioChoice = centeredMenu3('Select Dual-Fed Network Scenario:', ...
    'Symmetrical Network (Single Load)', ...
    'Asymmetrical Network (Single Load)', ...
    'Backup Feeding / Reliability Analysis (Multiple Loads)');
if scenarioChoice == 0, return; end

% --- Get common inputs ---
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
conductivity = materialProps.conductivity;
crossSection = input('Enter conductor cross-section [mm^2]: ');
L_total = input('Enter total line length [m]: ');
phase_factor = 1; % Assume three-phase line-to-neutral calculations (K=1)

% --- Scenario-specific inputs ---
% (Code for gathering scenario-specific inputs remains the same)
switch scenarioChoice
    case 1 % Symmetrical
        results.scenarioName = 'Symmetrical Network';
        Ua = input('Enter the symmetrical source voltage [V]: ');
        Ub = Ua;
        loads(1).current = input('Enter current of the single load [A]: ');
        loads(1).distance = L_total / 2;
    case 2 % Asymmetrical
        results.scenarioName = 'Asymmetrical Network';
        Ua = input('Enter voltage of Source A [V]: ');
        Ub = input('Enter voltage of Source B [V]: ');
        loads(1).current = input('Enter current of the single load [A]: ');
        loads(1).distance = input('Enter distance of the load from Source A [m]: ');
    case 3 % Reliability
        results.scenarioName = 'Reliability Analysis';
        Ua = input('Enter the primary source voltage (Ua) [V]: ');
        Ub = input('Enter the backup source voltage (Ub) [V]: ');
        num_loads = input('Enter the number of loads on the line: ');
        for i = 1:num_loads
            loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
            loads(i).distance = input(['Enter distance of load ' num2str(i) ' from Source A [m]: ']);
        end
end
loads = table2struct(sortrows(struct2table(loads), 'distance'));

% ========================================================================
% TOOL IMPLEMENTATION: DUAL-FEED CALCULATION ALGORITHM
% ========================================================================
% This section calculates the current split between Source A (Ia) and
% Source B (Ib) by applying circuit theory.
moment_sum_B = sum(arrayfun(@(l) l.current * (L_total - l.distance), loads));
Ia = (1/L_total) * ( (Ub - Ua) * conductivity * crossSection / phase_factor + moment_sum_B );
Ib = sum([loads.current]) - Ia;

% ========================================================================
% TOOL IMPLEMENTATION: SPLIT NETWORK AT MINIMUM VOLTAGE POINT
% ========================================================================
% This loop iterates through the network segments to find the node with
% the lowest voltage, which represents the network's electrical split point.
min_voltage = inf;
min_voltage_node_distance = 0;
current_in_segment = Ia;
voltage_at_node = Ua;
nodes_to_check = [struct('distance', 0, 'current', 0); loads];
for i = 2:length(nodes_to_check)
    segment_length = nodes_to_check(i).distance - nodes_to_check(i-1).distance;
    voltage_drop_segment = (phase_factor/(conductivity*crossSection)) * current_in_segment * segment_length;
    voltage_at_node = voltage_at_node - voltage_drop_segment;
    if voltage_at_node < min_voltage
        min_voltage = voltage_at_node;
        min_voltage_node_distance = nodes_to_check(i).distance;
    end
    current_in_segment = current_in_segment - nodes_to_check(i).current;
end
results.min_voltage_normal = min_voltage;
results.min_voltage_node_distance = min_voltage_node_distance;

% ========================================================================
% TOOL IMPLEMENTATION: RELIABILITY ANALYSIS
% ========================================================================
% This section is executed for the Reliability scenario. It simulates the
% failure of each source and calculates the resulting voltage profile by
% treating the remaining network as a simple RADIAL network.
if scenarioChoice == 3
    % --- CALCULATE EACH SECTION AS A RADIAL NETWORK ---
    % Scenario A: Source B Fails (Network becomes radial from A)
    [~, results.min_voltage_fail_B] = calculate_radial_drop(Ua, loads, conductivity, crossSection, phase_factor);
    
    % Scenario B: Source A Fails (Network becomes radial from B)
    loads_from_B = loads;
    for i = 1:length(loads_from_B), loads_from_B(i).distance = L_total - loads_from_B(i).distance; end
    loads_from_B = table2struct(sortrows(struct2table(loads_from_B), 'distance'));
    [~, results.min_voltage_fail_A] = calculate_radial_drop(Ub, loads_from_B, conductivity, crossSection, phase_factor);
end

% --- Finalize results and Plot ---
results.Ua = Ua; results.Ub = Ub;
results.materialName = materialName;
results.conductivity = conductivity; results.crossSection = crossSection;
results.L_total = L_total;
results.loads = loads;
results.Ia = Ia; results.Ib = Ib;

% ========================================================================
% TOOL IMPLEMENTATION: VERIFY VOLTAGE PROFILES AND CURRENT DISTRIBUTION
% ========================================================================
% The following functions generate plots to visually verify the results.
I2_PlotDualFedProfile(results);
I3_PlotLoadingDiagram(results);
I4_PlotUnifilarDiagram(results);
end

% --- Helper Functions ---
function props = getMaterialProperties(materialName)
    if strcmpi(materialName, 'Copper'), props.conductivity = 56; else, props.conductivity = 35; end
end

function [total_drop, final_voltage] = calculate_radial_drop(U_source, loads, conductivity, s, K)
    total_drop = 0;
    current_in_segment = sum([loads.current]);
    nodes_rad = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_rad)
        segment_length = nodes_rad(i).distance - nodes_rad(i-1).distance;
        drop_segment = (K / (conductivity * s)) * current_in_segment * segment_length;
        total_drop = total_drop + drop_segment;
        current_in_segment = current_in_segment - nodes_rad(i).current;
    end
    final_voltage = U_source - total_drop;
end

