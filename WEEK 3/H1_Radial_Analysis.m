function results = H1_Radial_Analysis()
% =========================================================================
% FUNCTION: Main Radial Network Analysis (V3 - Phase Selection)
% =========================================================================
% Description:
% This is the main analysis function for the Radial Network module. It
% handles all user input, including the system phase type, and calculates
% the voltage profile using the method of electrical moments.
% MODIFIED:
% - Asks user to select between single-phase and three-phase systems.
% - Applies the correct phase factor (K=2 for single-phase, K=1 for
%   three-phase line-to-neutral) to the voltage drop calculation.
% =========================================================================

results = []; % Initialize
% UPDATED: Corrected the text for Student C's scenario
scenarioChoice = centeredMenu3('Select Radial Network Scenario:', ...
    'Industrial Estate (Concentrated Loads) - Student A', ...
    'Residential Area (Distributed Loads) - Student B', ...
    'Street Lighting (Uniform Loads) - Student C');
if scenarioChoice == 0, return; end

% --- Get common inputs ---
U_source = input('Enter source line-to-neutral voltage [V] (e.g., 230): ');

% --- NEW: Ask for phase type ---
lineTypeChoice = centeredMenu3('Select System Type:', 'Single-Phase', 'Three-Phase');
if lineTypeChoice == 0, return; end
if lineTypeChoice == 1
    lineType = 'single-phase';
    phase_factor = 2; % K=2 for single-phase
else
    lineType = 'three-phase';
    phase_factor = 1 % K=1 for three-phase (line-to-neutral voltage drop)
end

% Material Selection Menu
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 0, return; end
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end
materialProps = getMaterialProperties(materialName);
sigma = materialProps.sigma;

crossSection = input('Enter conductor cross-section [mm^2] (e.g., 95): ');
nodes = [];
switch scenarioChoice
    case 1 % Concentrated Loads
        results.scenarioName = 'Industrial Estate';
        num_loads = input('Enter the number of concentrated loads: ');
        for i = 1:num_loads
            fprintf('--- Load %d ---\n', i);
            nodes(i).length = input(['Enter length of segment leading to load ' num2str(i) ' [m]: ']);
            nodes(i).load = input(['Enter current of load ' num2str(i) ' [A]: ']);
        end

    case 2 % Distributed Loads
        results.scenarioName = 'Residential Area';
        total_length = input('Enter total length of the residential line [m]: ');
        total_current = input('Enter total distributed current [A]: ');
        num_segments = 20; % Model as 20 small point loads for accuracy
        for i = 1:num_segments
            nodes(i).length = total_length / num_segments;
            nodes(i).load = total_current / num_segments;
        end

    case 3 % Street Lighting (Uniform/Distributed Loads)
        results.scenarioName = 'Street Lighting';
        total_length = input('Enter total length of the street lighting circuit [m]: ');
        total_current = input('Enter total uniformly distributed current [A]: ');
        num_segments = 20; % Model as 20 small point loads for accuracy
        for i = 1:num_segments
            nodes(i).length = total_length / num_segments;
            nodes(i).load = total_current / num_segments;
        end
end

% --- Calculations using Electrical Moments ---
num_nodes = length(nodes);
% 1. Calculate moments for each individual load relative to its start point
for i = 1:num_nodes
    nodes(i).moment = nodes(i).load * nodes(i).length;
end

% 2. Calculate voltage drop at each node
for i = 1:num_nodes
    % Calculate cumulative moment for reporting
    moment_sum = 0;
    dist_from_node_i = 0;
    for j = i:num_nodes
        dist_from_node_i = dist_from_node_i + nodes(j).length;
        moment_sum = moment_sum + nodes(j).load * dist_from_node_i;
    end
    nodes(i).cumulativeMoment = moment_sum;
    
    % The total drop at a node is the sum of drops in all preceding segments
    % drop_segment = (K / (sigma * s)) * I_segment * L_segment
    current_in_segment = sum([nodes(i:end).load]);
    drop_segment = (phase_factor / (sigma * crossSection)) * current_in_segment * nodes(i).length;
    
    if i == 1
        nodes(i).voltageDrop = drop_segment;
    else
        nodes(i).voltageDrop = nodes(i-1).voltageDrop + drop_segment;
    end
    nodes(i).voltage = U_source - nodes(i).voltageDrop;
end

% --- Finalize results for reporting and Plot ---
results.lineType = lineType;
results.U_source = U_source;
results.materialName = materialName;
results.sigma = sigma;
results.resistivity = 1/sigma;
results.crossSection = crossSection;
results.nodes = nodes;
results.totalVoltageDrop = nodes(end).voltageDrop;
results.totalVoltageDropPercent = (results.totalVoltageDrop / U_source) * 100;
H2_PlotRadialProfile(results);
end


