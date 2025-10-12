function C4_PlotLoadingDiagram(results)
% =========================================================================
% FUNCTION: C4_PlotLoadingDiagram (NEW for C Module)
% =========================================================================
% Description:
% Generates a network loading diagram for an unwrapped ring network. This
% plot visualizes the current distribution, showing the flow clockwise and
% anti-clockwise from the feed-in point.
%
% Input:
%   results - The struct containing all analysis data from C1_Ring_Analysis.
% =========================================================================
figure;
hold on;
box on;
grid on;

% --- Prepare data for plotting ---
% Start with the current flowing clockwise
distances = [0];
currents = [results.Ia];

% Add points for each load
current_in_segment = results.Ia;
sorted_loads = sortrows(struct2table(results.loads), 'distance');
for i = 1:height(sorted_loads)
    % Point just before the load
    distances(end+1) = sorted_loads.distance(i);
    currents(end+1) = current_in_segment;
    
    % Update the current after serving the load
    current_in_segment = current_in_segment - sorted_loads.current(i);
    
    % Point just after the load to create the vertical drop
    distances(end+1) = sorted_loads.distance(i);
    currents(end+1) = current_in_segment;
end

% Add the final point at the end of the unwrapped ring
distances(end+1) = results.L_total;
% The remaining current should be equal to -Ib
currents(end+1) = -results.Ib; 

% --- Create the Plot ---
plot(distances, currents, '-r', 'LineWidth', 2);

% Add a horizontal line at y=0 to show the current division point
line([0, results.L_total], [0, 0], 'Color', 'k', 'LineStyle', '--');

% Annotate start and end currents
text(0, results.Ia, sprintf('  Clockwise = %.1f A', results.Ia), 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
text(results.L_total, -results.Ib, sprintf('Anti-Clockwise = %.1f A  ', results.Ib), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'FontWeight', 'bold');

% Formatting
title(['Ring Network Loading Diagram (Unwrapped)']);
xlabel('Distance from Feed Point along Ring (m)');
ylabel('Current (A)');
legend('Current Distribution', 'Location', 'best');

end
