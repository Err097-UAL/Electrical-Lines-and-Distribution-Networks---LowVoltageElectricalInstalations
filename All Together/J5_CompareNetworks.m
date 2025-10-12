function results = J5_CompareNetworks()
% =========================================================================
% FUNCTION: Compare Ring and Radial Networks (V3 - Plotting Fix)
% =========================================================================
% MODIFIED:
% - This function now calculates the full voltage profile (distances and
%   voltage levels) for both the ring and radial networks.
% - This pre-calculated data is passed in the 'results' struct, which
%   simplifies the plotting function and resolves the "sigma" field error.
% =========================================================================
results = [];

disp('--- Network Comparison Tool ---');
disp('This tool will design and compare a Ring vs. a Radial network for the same loads.');

% --- Get common inputs for both networks ---
U_source = input('Enter the source/feed-in voltage [V]: ');
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
sigma = materialProps.sigma;
crossSection = input('Enter a uniform conductor cross-section [mm^2]: ');
num_loads = input('Enter the number of loads for the comparison: ');
loads = [];
for i = 1:num_loads
    loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from the source along the line [m]: ']);
end
sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));

% --- 1. ANALYZE THE RING NETWORK ---
L_total_ring = input('Enter the total circumference of the Ring network [m]: ');
Ia_ring = (1/L_total_ring) * sum(arrayfun(@(l) l.current * (L_total_ring - l.distance), sorted_loads));
Ib_ring = sum([sorted_loads.current]) - Ia_ring;
[min_v_ring, ~, ring_v_dist, ring_v] = calculate_voltage_profile(U_source, Ia_ring, sorted_loads, sigma, crossSection);
results.ring.min_voltage = min_v_ring;
results.ring.max_drop_percent = (U_source - min_v_ring)/U_source * 100;
results.ring.Ia = Ia_ring;
results.ring.Ib = Ib_ring;
results.ring.L_total = L_total_ring;
results.ring.voltage_profile_dist = ring_v_dist; % Pass profile for plotting
results.ring.voltage_profile_v = ring_v;       % Pass profile for plotting


% --- 2. ANALYZE THE RADIAL NETWORK ---
L_total_radial = sorted_loads(end).distance;
I_radial_start = sum([sorted_loads.current]);
[min_v_radial, ~, radial_v_dist, radial_v] = calculate_voltage_profile(U_source, I_radial_start, sorted_loads, sigma, crossSection);
results.radial.min_voltage = min_v_radial;
results.radial.max_drop_percent = (U_source - min_v_radial) / U_source * 100;
results.radial.L_total = L_total_radial;
results.radial.voltage_profile_dist = radial_v_dist; % Pass profile for plotting
results.radial.voltage_profile_v = radial_v;       % Pass profile for plotting


% --- 3. RELIABILITY / FAILURE IMPACT (on Ring) ---
[min_v_fault, ~] = calculate_voltage_profile(U_source, sum([sorted_loads.current]), sorted_loads, sigma, crossSection);
results.reliability.min_voltage_fault = min_v_fault;
results.reliability.max_drop_percent_fault = (U_source - min_v_fault) / U_source * 100;

% --- 4. ECONOMIC ANALYSIS ---
cost_per_meter = input('Enter an illustrative cost per meter for the conductor [€/m]: ');
[results.ring.total_cost, results.ring.cable_cost, results.ring.loss_cost] = J6_CalculateNetworkCost('ring', L_total_ring, Ia_ring, Ib_ring, sorted_loads, sigma, crossSection, cost_per_meter);
[results.radial.total_cost, results.radial.cable_cost, results.radial.loss_cost] = J6_CalculateNetworkCost('radial', L_total_radial, sum([sorted_loads.current]), 0, sorted_loads, sigma, crossSection, cost_per_meter);

% --- 5. FINALIZE & PLOT ---
results.U_source = U_source;
results.materialName = materialName;
results.crossSection = crossSection;
results.loads = sorted_loads;
if results.ring.max_drop_percent < results.radial.max_drop_percent, results.voltage_winner = 'Ring'; else, results.voltage_winner = 'Radial'; end
if results.ring.total_cost < results.radial.total_cost, results.economic_winner = 'Ring'; else, results.economic_winner = 'Radial'; end

J7_PlotComparison(results);
end

% --- Helper function for min voltage calculation ---
function [min_v, min_v_dist, distances, voltages] = calculate_voltage_profile(U, I_start, loads, sigma, s)
    min_v = inf;
    min_v_dist = 0;
    I_seg = I_start;
    V_node = U;
    
    distances = [0];
    voltages = [U];
    
    nodes_check = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_check)
        seg_len = nodes_check(i).distance - nodes_check(i-1).distance;
        drop = (1/(sigma*s)) * I_seg * seg_len;
        V_node = V_node - drop;
        
        distances(end+1) = nodes_check(i).distance;
        voltages(end+1) = V_node;
        
        if V_node < min_v, min_v = V_node; min_v_dist = nodes_check(i).distance; end
        I_seg = I_seg - nodes_check(i).current;
    end
end

