function results = H1_Radial_Analysis()
% =========================================================================
% FUNCTION: Main Radial Network Analysis (V4 - With Optimization)
% =========================================================================
% MODIFIED:
% - Integrated calls to new functions for cross-section determination and
%   network optimization.
% - Added a new main menu to select between "Analysis" mode (for a fixed
%   cross-section) and "Design/Optimize" mode (to find the best section).
% - Added menu centering for better UI.
% =========================================================================

clc;
results = []; 

% % --- Main Operation Mode Selection ---
% modeChoice = centeredMenu3('Select Operation Mode:', ...
%     'Analyze Network (with a known cross-section)', ...
%     'Design & Optimize Network (find best cross-section)');
% if modeChoice == 0, return; end

% --- Get common inputs ---
scenarioChoice = centeredMenu3('Select Radial Network Scenario:', ...
    'Industrial Estate (Concentrated Loads)', ...
    'Residential Area (Distributed Loads)', ...
    'Street Lighting (Uniform Loads)');
if scenarioChoice == 0, return; end

U_source = input('Enter source line-to-neutral voltage [V] (e.g., 230): ');
lineTypeChoice = centeredMenu3('Select System Type:', 'Single-Phase', 'Three-Phase');
if lineTypeChoice == 1, phase_factor = 2; else, phase_factor = 1; end
materialChoice = centeredMenu3('Select Conductor Material:', 'Copper', 'Aluminum');
if materialChoice == 1, materialName = 'Copper'; else, materialName = 'Aluminum'; end

materialProps = getMaterialProperties(materialName);
loads = getLoads(scenarioChoice);

% --- Store base results ---
base_results.U_source = U_source;
base_results.phase_factor = phase_factor;
base_results.materialName = materialName;
base_results.conductivity = materialProps.conductivity;
base_results.loads = loads;
base_results.scenarioName = getScenarioName(scenarioChoice);

% --- Execute selected mode ---
if modeChoice == 1 % ANALYSIS MODE
    crossSection = input('Enter the conductor cross-section to analyze [mm^2]: ');
    base_results.crossSection = crossSection;
    
    % Calculate voltage profile for the given section
    voltage_at_node = base_results.U_source;
    current_in_segment = sum([base_results.loads.current]);
    for k = 1:length(base_results.loads)
         drop_segment = (base_results.phase_factor / (base_results.conductivity * crossSection)) * current_in_segment * base_results.loads(k).length;
         voltage_at_node = voltage_at_node - drop_segment;
         base_results.loads(k).voltage = voltage_at_node;
         current_in_segment = current_in_segment - base_results.loads(k).current;
    end
    results = base_results;
    
    % Optionally, run cross-section check for context
    H3_DetermineCrossSection(results, 5); % Check against a 5% drop

else % DESIGN & OPTIMIZE MODE
    results = H4_OptimizeRadialNetwork(base_results);
end

% Plot profile if a valid result was found
if ~isempty(results)
    H2_PlotRadialProfile(results);
end

end

% --- Helper sub-functions ---
function loads = getLoads(~)
    num_loads = input('Enter the number of loads/nodes: ');
    loads(num_loads) = struct('length', 0, 'current', 0, 'voltage', 0, 'distance', 0);
    total_dist = 0;
    for i = 1:num_loads
        fprintf('--- Node %d ---\n', i);
        loads(i).length = input(['Enter length of segment leading to node ' num2str(i) ' [m]: ']);
        loads(i).current = input(['Enter current of load at node ' num2str(i) ' [A]: ']);
        total_dist = total_dist + loads(i).length;
        loads(i).distance = total_dist;
    end
end

function name = getScenarioName(choice)
    names = {'Industrial Estate', 'Residential Area', 'Street Lighting'};
    name = names{choice};
end

function props = getMaterialProperties(materialName)
    if strcmpi(materialName, 'Copper')
        props.conductivity = 56;
    else
        props.conductivity = 35;
    end
end

function choice = centeredMenu3(title, varargin)
    % Creates and centers a menu dialog box
    fig = figure('Name', title, 'NumberTitle', 'off', 'MenuBar', 'none', ...
                 'Units', 'pixels', 'Position', [0 0 400 150], 'Visible', 'off');
    movegui(fig, 'center');
    set(fig, 'Visible', 'on');
    choice = menu(title, varargin{:});
    close(fig);
end

