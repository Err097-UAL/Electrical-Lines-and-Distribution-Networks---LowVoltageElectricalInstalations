function results = J5_CompareNetworks()
% =========================================================================
% FUNCTION: Compare Ring and Radial Networks (V7 - Data Structure Fix)
% =========================================================================
% MODIFIED:
% - Explicitly stores the calculated currents (Ia_ring, Ib_ring, Ia_radial)
%   into the results sub-structs (results.ring and results.radial) to
%   ensure the plotting function receives the correct data.
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
conductivity = materialProps.sigma; % Use a safe variable name

% --- Use a menu for cross-section selection ---
conductors = getStandardConductors(materialName);
section_options = arrayfun(@(s) sprintf('%d mm^2', s), conductors.CrossSection, 'UniformOutput', false);
sectionChoice = centeredMenu('Select a standard conductor cross-section:', section_options{:});
if sectionChoice == 0, return; end
crossSection = conductors.CrossSection(sectionChoice);
% --- END MODIFICATION ---

conductor_row = conductors(conductors.CrossSection == crossSection, :);
cost_per_meter = conductor_row.CostPerMeter;

num_loads = input('Enter the number of loads for the comparison: ');
loads = [];
for i = 1:num_loads
    loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from source/feed-in [m]: ']);
end
sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));


% --- 1. RING ANALYSIS ---
results.ring.L_total = input('Enter total circumference for the RING network [m]: ');
Ia_ring = (1/results.ring.L_total) * sum(arrayfun(@(l) l.current * (results.ring.L_total - l.distance), sorted_loads));
Ib_ring = sum([sorted_loads.current]) - Ia_ring;
results.ring.Ia = Ia_ring; % Store current in struct
results.ring.Ib = Ib_ring; % Store current in struct
[results.ring.min_voltage, ~, results.ring.voltage_profile_dist, results.ring.voltage_profile_v] = calculate_voltage_profile(U_source, Ia_ring, sorted_loads, conductivity, crossSection);
results.ring.max_drop_percent = ((U_source - results.ring.min_voltage) / U_source) * 100;
[results.ring.total_cost, results.ring.cable_cost, results.ring.loss_cost] = J6_CalculateNetworkCost('ring', results.ring.L_total, Ia_ring, Ib_ring, sorted_loads, conductivity, crossSection, cost_per_meter);

% --- 2. RADIAL ANALYSIS ---
L_total_radial = sorted_loads(end).distance;
results.radial.L_total = L_total_radial;
Ia_radial = sum([sorted_loads.current]);
results.radial.Ia = Ia_radial; % Store current in struct
[results.radial.min_voltage, ~, results.radial.voltage_profile_dist, results.radial.voltage_profile_v] = calculate_voltage_profile(U_source, Ia_radial, sorted_loads, conductivity, crossSection);
results.radial.max_drop_percent = ((U_source - results.radial.min_voltage) / U_source) * 100;
[results.radial.total_cost, results.radial.cable_cost, results.radial.loss_cost] = J6_CalculateNetworkCost('radial', L_total_radial, Ia_radial, 0, sorted_loads, conductivity, crossSection, cost_per_meter);

% --- 3. RELIABILITY & FAILURE IMPACT ANALYSIS ---
% Simulates a fault before the last load and analyzes the impact
fault_location = sorted_loads(end).distance;
results.reliability.fault_location = fault_location;
% Impact on Radial Network (outage for the last load)
results.reliability.radial_impact = 'Outage for last load';
results.reliability.radial_unserved_current = sorted_loads(end).current;
% Impact on Ring Network (all loads are still served)
% To simulate, we treat the ring as a new, longer radial line
new_radial_loads = sorted_loads;
for i = 1:length(new_radial_loads)
    if new_radial_loads(i).distance >= fault_location
        % Reroute the path for loads after the fault
        if i > 1
             new_radial_loads(i).distance = results.ring.L_total - new_radial_loads(i).distance + (fault_location - new_radial_loads(i-1).distance);
        else
             new_radial_loads(i).distance = results.ring.L_total - new_radial_loads(i).distance;
        end
    end
end
new_radial_loads = table2struct(sortrows(struct2table(new_radial_loads), 'distance'));
Ia_fault = sum([new_radial_loads.current]);
[results.reliability.min_voltage_fault, ~] = calculate_voltage_profile(U_source, Ia_fault, new_radial_loads, conductivity, crossSection);
results.reliability.ring_impact = 'All loads served, reduced voltage quality';
results.reliability.max_drop_percent_fault = ((U_source - results.reliability.min_voltage_fault) / U_source) * 100;


% --- 4. FINALIZE & PLOT ---
results.U_source = U_source;
results.materialName = materialName;
results.conductivity = conductivity;
results.crossSection = crossSection;
results.loads = sorted_loads;
if results.ring.max_drop_percent < results.radial.max_drop_percent, results.voltage_winner = 'Ring'; else, results.voltage_winner = 'Radial'; end
if results.ring.total_cost < results.radial.total_cost, results.economic_winner = 'Ring'; else, results.economic_winner = 'Radial'; end

J7_PlotComparison(results);
end

% --- Helper function for min voltage calculation ---
function [min_v, min_v_dist, distances, voltages] = calculate_voltage_profile(U, I_start, loads, conductivity, s)
    min_v = inf;
    min_v_dist = 0;
    I_seg = I_start;
    V_node = U;
    
    distances = [0];
    voltages = [U];
    
    nodes_check = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_check)
        seg_len = nodes_check(i).distance - nodes_check(i-1).distance;
        drop = (1/(conductivity*s)) * I_seg * seg_len;
        V_node = V_node - drop;
        if V_node < min_v
            min_v = V_node;
            min_v_dist = nodes_check(i).distance;
        end
        I_seg = I_seg - nodes_check(i).current;
        distances(end+1) = nodes_check(i).distance;
        voltages(end+1) = V_node;
    end
end

