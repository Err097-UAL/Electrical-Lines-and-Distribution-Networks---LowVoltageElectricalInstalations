function results = J1_Ring_Analysis()
% =========================================================================
% FUNCTION: Main Ring Network Analysis (V7 - Sigma Fix)
% =========================================================================
% MODIFIED:
% - Corrected variable naming to avoid conflict with MATLAB's 'sigma' function.
%   Calls getMaterialProperties and stores the conductivity value in a safe
%   variable named 'conductivity'.
% =========================================================================
results = [];
% For this module, we will focus only on the Simple Ring Network analysis
disp('--- Launching Simple Ring Network Analysis ---');
results.scenarioName = 'Simple Ring Network';

% --- Get Inputs ---
Ua = input('Enter the feed-in voltage [V]: ');
materialChoice = centeredMenu('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
conductivity = materialProps.sigma; % Use a safe variable name

crossSection = input('Enter conductor cross-section [mm^2]: ');
L_total = input('Enter the total circumference of the ring [m]: ');
num_loads = input('Enter the number of loads on the ring: ');
loads = [];
for i = 1:num_loads
    loads(i).current = input(['Enter current for load ' num2str(i) ' [A]: ']);
    loads(i).distance = input(['Enter distance of load ' num2str(i) ' from feed point along the ring [m]: ']);
end

% --- METHOD: Convert to equivalent dual-fed network and solve ---
Ub = Ua;
I_total = sum([loads.current]);
Ia = (1/L_total) * sum(arrayfun(@(l) l.current * (L_total - l.distance), loads));
Ib = I_total - Ia;

min_voltage = inf;
min_voltage_node_distance = 0;
cumulative_Ia = Ia;
voltage_at_node = Ua;
sorted_loads = table2struct(sortrows(struct2table(loads), 'distance'));
nodes_to_check = [struct('distance', 0, 'current', 0); sorted_loads];

for i = 2:length(nodes_to_check)
    segment_length = nodes_to_check(i).distance - nodes_to_check(i-1).distance;
    voltage_drop_segment = (1/(conductivity*crossSection)) * cumulative_Ia * segment_length;
    voltage_at_node = voltage_at_node - voltage_drop_segment;
    
    if voltage_at_node < min_voltage
        min_voltage = voltage_at_node;
        min_voltage_node_distance = nodes_to_check(i).distance;
    end
    
    cumulative_Ia = cumulative_Ia - nodes_to_check(i).current;
end

% --- Finalize results and Plot ---
results.Ua = Ua;
results.materialName = materialName;
results.conductivity = conductivity; 
results.crossSection = crossSection;
results.L_total = L_total; 
results.loads = loads;
results.Ia = Ia; 
results.Ib = Ib;
results.min_voltage = min_voltage;
results.min_voltage_node_distance = min_voltage_node_distance;
results.max_drop_V = Ua - min_voltage;
results.max_drop_percent = (results.max_drop_V / Ua) * 100;

% Generate Plots
J3_PlotUnifilarDiagram(results);
J2_PlotRingProfile(results);
J4_PlotLoadingDiagram(results);
end

