function I4_PlotUnifilarDiagram(results)
% =========================================================================
% FUNCTION: B4_PlotUnifilarDiagram (NEW)
% =========================================================================
% Description:
% Generates a simplified unifilar-style schematic diagram of the dual-fed
% network. It visually represents the two sources, the main line, and the
% position and magnitude of each load.
%
% Input:
%   results - The struct containing all analysis data from B1_DualFed_Analysis.
% =========================================================================
figure;
hold on;
box on;

% --- Draw the main line/busbar ---
plot([0 results.L_total], [0 0], 'k-', 'LineWidth', 4);

% --- Draw and label the sources ---
plot(0, 0, 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
text(0, 0.15, 'Source A', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');

plot(results.L_total, 0, 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
text(results.L_total, 0.15, 'Source B', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');

% --- Draw and label each load ---
for i = 1:length(results.loads)
    x_pos = results.loads(i).distance;
    
    % Draw the vertical line for the load branch
    plot([x_pos x_pos], [0 -1], '-k', 'LineWidth', 1);
    
    % Draw an arrow to represent the load
    plot(x_pos, -1, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
    
    % Add text label for the load
    label_str = sprintf('Load %d\n%.1f A', i, results.loads(i).current);
    text(x_pos, -1.2, label_str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
end

% --- Formatting ---
ylim([-2.5 1]); % Give space for labels
set(gca, 'YTick', []); % Remove y-axis ticks as they are not meaningful
set(gca, 'YColor', 'none'); % Hide the y-axis line
xlabel('Distance from Source A (m)');
title(['Schematic Network Diagram (' results.scenarioName ')']);
end
