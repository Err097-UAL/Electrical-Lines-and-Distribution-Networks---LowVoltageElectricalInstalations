function results = J1_Ring_Analysis()
% =========================================================================
% FUNCTION: Main Ring Network Analysis (V7 - Sigma Fix)
% =========================================================================
% MODIFIED:
% - Corrected variable naming to avoid conflict with MATLAB's 'sigma' function.
%   Calls getMaterialProperties and stores the conductivity value in a safe
%   variable named 'conductivity'.
% - CHANGED: Load inputs modified to accept Power (kW) and Power Factor (PF)
%   instead of current. Current is now calculated.
% =========================================================================
results = [];
% For this module, we will focus only on the Simple Ring Network analysis
disp('--- Launching Simple Ring Network Analysis ---');
results.scenarioName = 'Simple Ring Network';

% --- Get Inputs ---
Ua = input('Enter the feed-in voltage [V] (e.g., Line-to-Neutral 230V): ');
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
conductivity = materialProps.sigma; % Use a safe variable name

crossSection = input('Enter conductor cross-section [mm^2]: ');
L_total = input('Enter the total circumference of the ring [m]: ');
num_loads = input('Enter the number of loads on the ring: ');
loads = [];

% === MODIFICATION START ===
% Loop to get load data (Power and PF)
for i = 1:num_loads
    fprintf('--- Load %d ---\n', i);
    
    % Get Power (kW) and Power Factor (PF)
    loadPower_kW = input(['Enter Power for load ' num2str(i) ' [kW]: ']);
    cos_phi = input(['Enter Power Factor for load ' num2str(i) ' (e.g., 0.9): ']);
    
    % Calculate current using the nominal source voltage 'Ua'
    % Formula: P_3phase = 3 * V_phase * I * pf
    loadPower_W = loadPower_kW * 1000;
    loads(i).current = loadPower_W / (3 * Ua * cos_phi);
    fprintf(' -> Calculated Current: %.2f A\n', loads(i).current);
    
    % Get the distance
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from feed-point (clockwise) [m]: ']);
    
    if loads(i).distance > L_total
        warning('Load distance is greater than total ring length. Check inputs.');
    end
end
% === MODIFICATION END ===


% --- Solve the network ---
% This block models the ring as a dual-fed line to find the split point.
Ub = Ua; % In a ring, the "start" and "end" voltage are the same
I_total = sum([loads.current]);

% Calculate Ia (clockwise current) using the moment method
moment_sum = sum(arrayfun(@(l) l.current * (L_total - l.distance), loads));
Ia = (1/L_total) * moment_sum;
Ib = I_total - Ia; % Ib is the anti-clockwise current

% --- Calculate Voltage Profile ---
min_voltage = inf;
min_voltage_node_distance = 0;
cumulative_Ia = Ia; % Start with the clockwise current
voltage_at_node = Ua;
sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));
nodes_to_check = [struct('distance', 0, 'current', 0); sorted_loads];

% Iterate through segments clockwise
for i = 2:length(nodes_to_check)
    segment_length = nodes_to_check(i).distance - nodes_to_check(i-1).distance;
    
    % V_drop = (K * I * L) / (sigma * s)
    % Here K=1 (for 3-phase L-N)
    voltage_drop_segment = (1/(conductivity*crossSection)) * cumulative_Ia * segment_length;
    voltage_at_node = voltage_at_node - voltage_drop_segment;
    
    if voltage_at_node < min_voltage
        min_voltage = voltage_at_node;
        min_voltage_node_distance = nodes_to_check(i).distance;
    end
    
    % Subtract the load current for the next segment
    cumulative_Ia = cumulative_Ia - nodes_to_check(i).current;
end

% --- Finalize results and Plot ---
results.Ua = Ua;
results.materialName = materialName;
results.conductivity = conductivity; 
results.crossSection = crossSection;
results.L_total = L_total;
results.loads = sorted_loads;
results.Ia = Ia; % Clockwise current
results.Ib = Ib; % Anti-clockwise current
results.min_voltage = min_voltage;
results.min_voltage_node_distance = min_voltage_node_distance;

% Call plotting functions
J2_PlotRingProfile(results);
J3_PlotUnifilarDiagram(results);
J4_PlotLoadingDiagram(results);
end

% --- Helper Functions ---
function props = getMaterialProperties(materialName)
    if strcmpi(materialName, 'Copper')
        props.sigma = 56; % m/(Ohm*mm^2)
    else
        props.sigma = 35; % m/(Ohm*mm^2)
    end
end

% (Assuming centeredMenu3 and other helpers are available on the path)