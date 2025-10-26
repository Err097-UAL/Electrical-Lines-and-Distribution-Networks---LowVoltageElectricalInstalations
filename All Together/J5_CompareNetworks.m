function results = J5_CompareNetworks()
% =========================================================================
% FUNCTION: Compare Ring and Radial Networks (V7 - Data Structure Fix)
% =========================================================================
% MODIFIED:
% - Explicitly stores the calculated currents (Ia_ring, Ib_ring, Ia_radial)
%   into the results sub-structs (results.ring and results.radial) to
%   ensure the plotting function receives the correct data.
% - CHANGED: Load inputs modified to accept Power (kW) and Power Factor (PF)
%   instead of current. Current is now calculated.
% =========================================================================
results = [];

disp('--- Network Comparison Tool ---');
disp('This tool will design and compare a Ring vs. a Radial network for the same loads.');

% --- Get common inputs for both networks ---
U_source = input('Enter the source/feed-in voltage [V] (e.g., Line-to-Neutral 230V): ');
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
conductivity = materialProps.sigma; % Use a safe variable name

% --- Use a menu for cross-section selection ---
conductors = getStandardConductors(materialName);
section_options = arrayfun(@(s) sprintf('%d mm^2', s), conductors.CrossSection, 'UniformOutput', false);
sectionChoice = centeredMenu3('Select a standard conductor cross-section:', section_options{:});
if sectionChoice == 0, return; end
crossSection = conductors.CrossSection(sectionChoice);
cost_per_meter = conductors.CostPerMeter(sectionChoice);

% --- Get load data ---
% === MODIFICATION START ===
num_loads = input('Enter the number of loads on the line: ');
loads(num_loads) = struct('distance', 0, 'current', 0); % Pre-allocate
for i = 1:num_loads
    fprintf('--- Load %d ---\n', i);
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from Source [m]: ']);
    
    % Get Power (kW) and Power Factor (PF)
    loadPower_kW = input(['Enter Power for load ' num2str(i) ' [kW]: ']);
    cos_phi = input(['Enter Power Factor for load ' num2str(i) ' (e.g., 0.9): ']);

    % Calculate current using the nominal source voltage 'U_source'
    % Formula: P_3phase = 3 * V_phase * I * pf
    loadPower_W = loadPower_kW * 1000;
    loads(i).current = loadPower_W / (3 * U_source * cos_phi);
    fprintf(' -> Calculated Current: %.2f A\n', loads(i).current);
end
% === MODIFICATION END ===

sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));
L_radial_total = sorted_loads(end).distance; % Total length for the radial line
L_ring_total = L_radial_total; % Assume ring has same "unwrapped" length for this comparison

% --- 1. RING NETWORK ANALYSIS ---
I_total_ring = sum([sorted_loads.current]);
% Calculate Ia (clockwise) using moment method
moment_sum_ring = sum(arrayfun(@(l) l.current * (L_ring_total - l.distance), sorted_loads));
Ia_ring = (1/L_ring_total) * moment_sum_ring;
Ib_ring = I_total_ring - Ia_ring; % Anti-clockwise
[min_v_ring, min_v_dist_ring, dist_ring, v_ring] = calculate_voltage_profile(U_source, Ia_ring, sorted_loads, conductivity, crossSection);
[total_cost_ring, cable_cost_ring, loss_cost_ring] = J6_CalculateNetworkCost('ring', L_ring_total, Ia_ring, Ib_ring, sorted_loads, conductivity, crossSection, cost_per_meter);
results.ring.L_total = L_ring_total;
results.ring.Ia = Ia_ring; results.ring.Ib = Ib_ring;
results.ring.min_voltage = min_v_ring;
results.ring.min_voltage_distance = min_v_dist_ring;
results.ring.max_drop_percent = ((U_source - min_v_ring) / U_source) * 100;
results.ring.voltage_profile_dist = dist_ring;
results.ring.voltage_profile_v = v_ring;
results.ring.total_cost = total_cost_ring;
results.ring.cable_cost = cable_cost_ring;
results.ring.loss_cost = loss_cost_ring;

% --- 2. RADIAL NETWORK ANALYSIS ---
Ia_radial = sum([sorted_loads.current]); % Total current from source
Ib_radial = 0; % No second source
[min_v_radial, min_v_dist_radial, dist_rad, v_rad] = calculate_voltage_profile(U_source, Ia_radial, sorted_loads, conductivity, crossSection);
[total_cost_radial, cable_cost_radial, loss_cost_radial] = J6_CalculateNetworkCost('radial', L_radial_total, Ia_radial, Ib_radial, sorted_loads, conductivity, crossSection, cost_per_meter);
results.radial.L_total = L_radial_total;
results.radial.Ia = Ia_radial; % Store for plotting
results.radial.min_voltage = min_v_radial;
results.radial.min_voltage_distance = min_v_dist_radial;
results.radial.max_drop_percent = ((U_source - min_v_radial) / U_source) * 100;
results.radial.voltage_profile_dist = dist_rad;
results.radial.voltage_profile_v = v_rad;
results.radial.total_cost = total_cost_radial;
results.radial.cable_cost = cable_cost_radial;
results.radial.loss_cost = loss_cost_radial;


% --- 3. RELIABILITY ANALYSIS (Simplified: Fault at most distant load) ---
% For the ring, assume a fault breaks the line just *after* the last load.
% The network becomes a simple radial line of length L_ring_total
Ia_fault = sum([sorted_loads.current]);
[min_v_fault, ~, ~, ~] = calculate_voltage_profile(U_source, Ia_fault, sorted_loads, conductivity, crossSection);
results.reliability.min_voltage_fault = min_v_fault;
results.reliability.status = 'All loads still supplied, but with reduced voltage quality';
results.reliability.max_drop_percent_fault = ((U_source - results.reliability.min_voltage_fault) / U_source) * 100;


% --- 4. FINALIZE & PLOT ---\
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
        if seg_len < 0, seg_len = 0; end % Safety check
        
        % V_drop = (K * I * L) / (sigma * s)
        drop_seg = (1 / (conductivity * s)) * I_seg * seg_len;
        V_node = V_node - drop_seg;
        
        distances(end+1) = nodes_check(i).distance;
        voltages(end+1) = V_node;
        
        if V_node < min_v
            min_v = V_node;
            min_v_dist = nodes_check(i).distance;
        end
        
        I_seg = I_seg - nodes_check(i).current;
    end
end

% --- Other Helper Functions ---
function props = getMaterialProperties(materialName)
    if strcmpi(materialName, 'Copper')
        props.sigma = 56;
    else
        props.sigma = 35;
    end
end

function conductors = getStandardConductors(materialName)
    % This function would ideally read from a file, but we'll hardcode it.
    if strcmpi(materialName, 'Copper')
        CrossSection = [16, 25, 35, 50, 70, 95, 120, 150, 185, 240];
        CostPerMeter = [3,   4,  6,  8, 11, 15,  20,  25,  30,  40];
    else % Aluminum
        CrossSection = [25, 35, 50, 70, 95, 120, 150, 185, 240];
        CostPerMeter = [2,  3,  4,  6,  8,   11,  14,  18,  25];
    end
    conductors = table(CrossSection', CostPerMeter', 'VariableNames', {'CrossSection', 'CostPerMeter'});
end

% (Assuming centeredMenu3 is available on the path)