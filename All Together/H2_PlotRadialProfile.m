function H2_PlotRadialProfile(results)
% =========================================================================
% FUNCTION: Plot Radial Voltage and Current Profile (V3)
% =========================================================================
% MODIFIED (V3):
% - Added a second y-axis to plot the current profile alongside voltage.
% - Current is plotted as a step function, decreasing at each load point.
% - Uses yyaxis for dual axes.
% =========================================================================

figure;
hold on; % Keep plots on the same figure
box on;
grid on;

% --- Prepare Data ---
% Voltage data (already correct)
distances = [0, [results.loads.distance]]; % X-coordinates for voltage points
voltages = [results.U_source, [results.loads.voltage]]; % Y-coordinates for voltage points

% Current data (needs processing for step plot)
num_loads = length(results.loads);
current_x = [0]; % Start at distance 0
current_y = [];
segment_currents = zeros(1, num_loads + 1); % Current in segment *before* the node

% Calculate total current at the source
total_current = sum([results.loads.current]);
segment_currents(1) = total_current;
current_y = [total_current]; % Add initial current value

% Loop through loads to build step plot coordinates
current_in_segment = total_current;
for i = 1:num_loads
    % Point before the current drop
    current_x = [current_x, results.loads(i).distance];
    current_y = [current_y, current_in_segment]; % Current remains constant until the node
    
    % Update current for the next segment
    current_in_segment = current_in_segment - results.loads(i).current;
    segment_currents(i+1) = current_in_segment; % Store for potential use (optional)
    
    % Point after the current drop (at the same distance)
    current_x = [current_x, results.loads(i).distance];
    current_y = [current_y, current_in_segment]; % Current drops at the node
end

% Add a final point to extend the last segment visually if needed
% If the last load isn't at the very end, extend the line
if distances(end) > current_x(end)
    current_x = [current_x, distances(end)];
    current_y = [current_y, current_y(end)];
elseif isempty(results.loads) % Handle case with no loads
     current_x = [current_x, distances(end)];
     current_y = [current_y, current_y(end)];
end


% --- Plotting ---

% Define colors
voltage_color = [0 0.4470 0.7410]; % Blue
current_color = [0.8500 0.3250 0.0980]; % Red

% Plot Voltage on the Left Y-Axis
yyaxis left;
plot(distances, voltages, '-o', 'LineWidth', 2, 'Color', voltage_color, 'MarkerFaceColor', 'r'); % Original voltage plot style
ylabel('Voltage (V)');
ax = gca; % Get current axis
ax.YColor = voltage_color; % Set left axis color

% Set Voltage Limits (original logic)
if ~isempty(voltages) && all(isfinite(voltages)) && voltages(end) > 0
    ylim([voltages(end) * 0.99, results.U_source * 1.01]);
else
    ylim([results.U_source * 0.95, results.U_source * 1.01]); % Fallback limits
end

% Plot Current on the Right Y-Axis
yyaxis right;
plot(current_x, current_y, '-', 'LineWidth', 2, 'Color', current_color); % Step plot for current
ylabel('Current (A)');
ax = gca; % Get current axis again
ax.YColor = current_color; % Set right axis color
ylim([0, total_current * 1.15]); % Set current limits slightly above max

% --- Final Touches ---
title(['Voltage & Current Profile (' results.scenarioName ')']);
xlabel('Distance from Source (m)');
xlim([0, distances(end) * 1.1]); % Use voltage distances for x limits

legend('Voltage Profile', 'Current Profile', 'Location', 'southwest');
hold off; % Release the figure hold

end
