function J7_PlotComparison(results)
% =========================================================================
% FUNCTION: Plot Network Comparison Charts (V5 - Data Structure Fix)
% =========================================================================
% MODIFIED:
% - Corrected the logic to access current data from the correct
%   sub-structs (results.ring.Ia, results.radial.Ia) to fix the
%   "Unrecognized field name" error.
% =========================================================================

%% --- FIGURE 1: SCHEMATIC DIAGRAMS ---
figure('Name', 'Network Schematics Comparison');

% 1. Ring Network Schematic
subplot(1, 2, 1);
hold on; axis equal; box on;
radius = 1;
theta = linspace(0, 2*pi, 200);
plot(radius * cos(theta), radius * sin(theta), 'b-', 'LineWidth', 4);
feed_angle = pi/2;
plot(radius * cos(feed_angle), radius * sin(feed_angle), 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g');
text(0, radius + 0.15, 'Feed-In', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
for i = 1:length(results.loads)
    angle = feed_angle - (results.loads(i).distance / results.ring.L_total) * 2 * pi;
    plot([radius*cos(angle) (radius-0.1)*cos(angle)], [radius*sin(angle) (radius-0.1)*sin(angle)], '-k');
    plot((radius-0.1)*cos(angle), (radius-0.1)*sin(angle), 'v', 'MarkerFaceColor', 'r');
end
title('Ring Schematic');

% 2. Radial Network Schematic
subplot(1, 2, 2);
hold on; box on;
plot([0 results.radial.L_total], [0 0], 'b-', 'LineWidth', 4);
plot(0, 0, 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g');
text(0, 0.15, 'Source', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
for i = 1:length(results.loads)
    plot([results.loads(i).distance results.loads(i).distance], [0 -0.5], '-k');
    plot(results.loads(i).distance, -0.5, 'v', 'MarkerFaceColor', 'r');
end
title('Radial Schematic');
set(gca, 'YTick', []);
ylim([-1 1]);


%% --- FIGURE 2: LOADING DIAGRAMS ---
figure('Name', 'Loading Diagrams Comparison');

% 1. Ring Network Loading Diagram
subplot(2, 1, 1);
hold on; grid on; box on;
ring_distances = [0];
ring_currents = [results.ring.Ia];
current_in_segment = results.ring.Ia;
for i = 1:length(results.loads)
    ring_distances(end+1) = results.loads(i).distance;
    ring_currents(end+1) = current_in_segment;
    current_in_segment = current_in_segment - results.loads(i).current;
    ring_distances(end+1) = results.loads(i).distance;
    ring_currents(end+1) = current_in_segment;
end
ring_distances(end+1) = results.ring.L_total;
ring_currents(end+1) = -results.ring.Ib;
plot(ring_distances, ring_currents, '-r', 'LineWidth', 2);
line([0, results.ring.L_total], [0, 0], 'Color', 'b', 'LineStyle', '--');
title('Ring Network Loading (Unwrapped)');
xlabel('Distance from Feed-In (m)'); ylabel('Current (A)'); hold off;

% 2. Radial Network Loading Diagram
subplot(2, 1, 2);
hold on; grid on; box on;
radial_distances = [0];
radial_currents = [results.radial.Ia];
current_in_segment = results.radial.Ia;
for i = 1:length(results.loads)
    radial_distances(end+1) = results.loads(i).distance;
    radial_currents(end+1) = current_in_segment;
    current_in_segment = current_in_segment - results.loads(i).current;
    radial_distances(end+1) = results.loads(i).distance;
    radial_currents(end+1) = current_in_segment;
end
plot(radial_distances, radial_currents, '-b', 'LineWidth', 2);
line([0, results.radial.L_total], [0, 0], 'Color', 'b', 'LineStyle', '--');
title('Radial Network Loading');
xlabel('Distance from Source (m)'); ylabel('Current (A)'); hold off;


%% --- FIGURE 3: PERFORMANCE & ECONOMIC COMPARISON ---
figure('Name', 'Performance and Economic Comparison');

% 1. Voltage Profile Comparison
subplot(1, 2, 1);
hold on; grid on; box on;
plot(results.ring.voltage_profile_dist, results.ring.voltage_profile_v, '-r', 'DisplayName', 'Ring Voltage');
plot(results.radial.voltage_profile_dist, results.radial.voltage_profile_v, '--b', 'DisplayName', 'Radial Voltage');
title('Voltage Profile Comparison');
xlabel('Distance from Source (m)'); ylabel('Voltage (V)');
legend('show', 'Location', 'southwest');

% 2. Economic Analysis Plot
subplot(1, 2, 2);
categories = {'Ring', 'Radial'};
cable_costs = [results.ring.cable_cost, results.radial.cable_cost];
loss_costs = [results.ring.loss_cost, results.radial.loss_cost];
bar_data = [cable_costs; loss_costs]';
bar(bar_data, 'stacked');
set(gca, 'XTickLabel', categories);
ylabel('Cost (Euros)');
title('Lifecycle Cost Comparison');
legend('Initial Cable Cost', 'Cost of Losses (20yr)', 'Location', 'north east');
grid on;
end
