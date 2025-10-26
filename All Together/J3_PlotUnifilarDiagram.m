function J3_PlotUnifilarDiagram(results)
% =========================================================================
% FUNCTION: C3_PlotUnifilarDiagram (NEW)
% =========================================================================
% Description:
% Generates a simplified unifilar-style schematic diagram of the ring
% network. It visually represents the feed-in point, the circular bus,
% and the position and magnitude of each load around the ring.
%
% Input:
%   results - The struct containing all analysis data from C1_Ring_Analysis.
% =========================================================================
figure;
hold on;
axis equal; % Ensure the ring is drawn as a circle, not an ellipse
box on;

% --- Define Ring Geometry ---
radius = 1;
center_x = 0;
center_y = 0;

% --- Draw the main ring conductor ---
theta = linspace(0, 2*pi, 200);
plot(center_x + radius * cos(theta), center_y + radius * sin(theta), 'c-', 'LineWidth', 4);

% --- Draw and label the feed-in point ---
feed_angle = pi/2; % Place at the top
feed_x = center_x + radius * cos(feed_angle);
feed_y = center_y + radius * sin(feed_angle);
plot(feed_x, feed_y, 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'c');
text(feed_x, feed_y + 0.15, 'Feed-In', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');

% --- Draw and label each load ---
for i = 1:length(results.loads)
    dist = results.loads(i).distance;
    
    % Calculate the angle for the load (clockwise from the top)
    angle = feed_angle - (dist / results.L_total) * 2 * pi;
    
    % Position on the ring
    load_x = center_x + radius * cos(angle);
    load_y = center_y + radius * sin(angle);
    
    % Position for the arrow (slightly inside the ring)
    arrow_x = center_x + (radius - 0.1) * cos(angle);
    arrow_y = center_y + (radius - 0.1) * sin(angle);
    
    % Position for the text label (further inside the ring)
    text_x = center_x + (radius - 0.3) * cos(angle);
    text_y = center_y + (radius - 0.3) * sin(angle);
    
    % Draw the branch line from the ring to the arrow
    plot([load_x, arrow_x], [load_y, arrow_y], '-k', 'LineWidth', 1);
    
    % Draw the load arrow
    plot(arrow_x, arrow_y, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
    
    % Add the text label
    label_str = sprintf('L%d\n%.1f A', i, results.loads(i).current);
    text(text_x, text_y, label_str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% --- Formatting ---
axis off; % Turn off the x and y axes for a cleaner schematic look
title(['Schematic Ring Diagram (' results.scenarioName ')']);
end
