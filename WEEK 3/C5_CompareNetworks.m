function results = C5_CompareNetworks()
% =========================================================================
% FUNCTION: Compare Ring and Radial Networks (V2 - Corrected)
% =========================================================================
% Description:
% Performs a comparative analysis between a ring and a radial network
% designed to serve the same set of loads. Compares voltage quality,
% reliability (failure impact), and lifecycle economics.
% MODIFIED: Corrected a typo from 'num_str' to 'num2str' which was
%           causing a runtime error.
% =========================================================================
results = [];

disp('--- Network Comparison Tool ---');
disp('This tool will design and compare a Ring vs. a Radial network for the same loads.');

% --- Get common inputs for both networks ---
U_source = input('Enter the source/feed-in voltage [V]: ');
materialChoice = centeredMenu('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
sigma = materialProps.sigma;
crossSection = input('Enter a uniform conductor cross-section [mm^2]: ');
num_loads = input('Enter the number of loads for the comparison: ');
loads = [];
for i = 1:num_loads
    % CORRECTED: Changed num_str to num2str
    loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from the source along the line [m]: ']);
end
sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));

% --- 1. ANALYZE THE RING NETWORK ---
L_total_ring = input('Enter the total circumference of the Ring network [m]: ');
Ia_ring = (1/L_total_ring) * sum(arrayfun(@(l) l.current * (L_total_ring - l.distance), sorted_loads));
Ib_ring = sum([sorted_loads.current]) - Ia_ring;
[min_v_ring, ~] = calculate_min_voltage(U_source, Ia_ring, sorted_loads, sigma, crossSection);
results.ring.min_voltage = min_v_ring;
results.ring.max_drop_percent = (U_source - min_v_ring)/U_source * 100;
results.ring.Ia = Ia_ring;
results.ring.Ib = Ib_ring;
results.ring.L_total = L_total_ring;


% --- 2. ANALYZE THE RADIAL NETWORK ---
L_total_radial = sorted_loads(end).distance;
radial_nodes = sorted_loads;
total_drop_radial = 0;
for i = 1:length(radial_nodes)
    current_in_segment = sum([radial_nodes(i:end).current]);
    if i == 1, segment_length = radial_nodes(i).distance; else, segment_length = radial_nodes(i).distance - radial_nodes(i-1).distance; end
    drop_segment = (1 / (sigma * crossSection)) * current_in_segment * segment_length;
    total_drop_radial = total_drop_radial + drop_segment;
end
results.radial.min_voltage = U_source - total_drop_radial;
results.radial.max_drop_percent = (total_drop_radial / U_source) * 100;
results.radial.L_total = L_total_radial;


% --- 3. RELIABILITY / FAILURE IMPACT (on Ring) ---
% Simulate an open-circuit fault in the ring just after the feed-in point.
% The ring now acts like a single radial line with length L_total_ring.
fault_loads = sorted_loads;
total_drop_fault = 0;
for i = 1:length(fault_loads)
    current_in_segment = sum([fault_loads(i:end).current]);
    if i == 1, segment_length = fault_loads(i).distance; else, segment_length = fault_loads(i).distance - fault_loads(i-1).distance; end
    drop_segment = (1 / (sigma * crossSection)) * current_in_segment * segment_length;
    total_drop_fault = total_drop_fault + drop_segment;
end
results.reliability.min_voltage_fault = U_source - total_drop_fault;
results.reliability.max_drop_percent_fault = (total_drop_fault / U_source) * 100;

% --- 4. ECONOMIC ANALYSIS ---
cost_per_meter = input('Enter an illustrative cost per meter for the conductor [€/m]: ');
[results.ring.total_cost, results.ring.cable_cost, results.ring.loss_cost] = C6_CalculateNetworkCost('ring', L_total_ring, Ia_ring, Ib_ring, sorted_loads, sigma, crossSection, cost_per_meter);
[results.radial.total_cost, results.radial.cable_cost, results.radial.loss_cost] = C6_CalculateNetworkCost('radial', L_total_radial, sum([sorted_loads.current]), 0, sorted_loads, sigma, crossSection, cost_per_meter);

% --- 5. FINALIZE & PLOT ---
results.U_source = U_source;
results.materialName = materialName;
results.crossSection = crossSection;
results.loads = sorted_loads;
if results.ring.max_drop_percent < results.radial.max_drop_percent, results.voltage_winner = 'Ring'; else, results.voltage_winner = 'Radial'; end
if results.ring.total_cost < results.radial.total_cost, results.economic_winner = 'Ring'; else, results.economic_winner = 'Radial'; end

C7_PlotComparison(results);
end

% --- Helper function for min voltage calculation ---
function [min_v, min_v_dist] = calculate_min_voltage(U, I_start, loads, sigma, s)
    min_v = inf;
    min_v_dist = 0;
    I_seg = I_start;
    V_node = U;
    nodes_check = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_check)
        seg_len = nodes_check(i).distance - nodes_check(i-1).distance;
        drop = (1/(sigma*s)) * I_seg * seg_len;
        V_node = V_node - drop;
        if V_node < min_v, min_v = V_node; min_v_dist = nodes_check(i).distance; end
        I_seg = I_seg - nodes_check(i).current;
    end
end

