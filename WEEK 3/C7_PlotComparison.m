function C7_PlotComparison(results)
% =========================================================================
% FUNCTION: Plot Network Comparison Charts (V3 - Multi-Window)
% =========================================================================
% MODIFIED: This function now generates three separate figure windows to
%           provide a clearer, more detailed comparison of the network
%           schematics, loading diagrams, and performance metrics.
% =========================================================================

%% --- FIGURE 1: SCHEMATIC DIAGRAMS ---
figure('Name', 'Network Schematics Comparison');

% 1. Ring Network Schematic
subplot(1, 2, 1);
hold on; axis equal; box on;
radius = 1;
theta = linspace(0, 2*pi, 200);
plot(radius * cos(theta), radius * sin(theta), 'k-', 'LineWidth', 4);
feed_angle = pi/2;
plot(radius * cos(feed_angle), radius * sin(feed_angle), 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g');
text(0, radius + 0.15, 'Feed-In', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
for i = 1:length(results.loads)
    angle = feed_angle - (results.loads(i).distance / results.ring.L_total) * 2 * pi;
    plot([radius*cos(angle) (radius-0.1)*cos(angle)], [radius*sin(angle) (radius-0.1)*sin(angle)], '-k');
    plot((radius-0.1)*cos(angle), (radius-0.1)*sin(angle), 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text((radius-0.3)*cos(angle), (radius-0.3)*sin(angle), sprintf('L%d',i), 'HorizontalAlignment', 'center');
end
axis off;
title('Ring Network Schematic');

% 2. Radial Network Schematic
subplot(1, 2, 2);
hold on; box on;
plot([0 results.radial.L_total], [0 0], 'k-', 'LineWidth', 4);
plot(0, 0, 's', 'MarkerSize', 20, 'MarkerFaceColor', 'g');
text(0, 0.15, 'Source', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
for i = 1:length(results.loads)
    x_pos = results.loads(i).distance;
    plot([x_pos x_pos], [0 -1], '-k');
    plot(x_pos, -1, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text(x_pos, -1.2, sprintf('L%d\n%.1f A', i, results.loads(i).current), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
end
ylim([-2.5 1]);
set(gca, 'YColor', 'none');
xlabel('Distance from Source (m)');
title('Radial Network Schematic');


%% --- FIGURE 2: LOADING DIAGRAMS ---
figure('Name', 'Loading Diagram Comparison');

% 1. Ring Network Loading Diagram
subplot(1, 2, 1);
hold on; box on; grid on;
ring_distances = [0]; ring_currents = [results.ring.Ia]; current_in_segment = results.ring.Ia;
for i = 1:length(results.loads), ring_distances(end+1) = results.loads(i).distance; ring_currents(end+1) = current_in_segment; current_in_segment = current_in_segment - results.loads(i).current; ring_distances(end+1) = results.loads(i).distance; ring_currents(end+1) = current_in_segment; end
ring_distances(end+1) = results.ring.L_total; ring_currents(end+1) = -results.ring.Ib;
plot(ring_distances, ring_currents, '-r', 'LineWidth', 2);
line([0, results.ring.L_total], [0, 0], 'Color', 'k', 'LineStyle', '--');
title('Ring Network Loading');
xlabel('Distance from Feed Point (m)'); ylabel('Current (A)'); hold off;

% 2. Radial Network Loading Diagram
subplot(1, 2, 2);
hold on; box on; grid on;
radial_distances = [0]; radial_currents = [sum([results.loads.current])]; current_in_segment = sum([results.loads.current]);
for i = 1:length(results.loads), radial_distances(end+1) = results.loads(i).distance; radial_currents(end+1) = current_in_segment; current_in_segment = current_in_segment - results.loads(i).current; radial_distances(end+1) = results.loads(i).distance; radial_currents(end+1) = current_in_segment; end
plot(radial_distances, radial_currents, '-b', 'LineWidth', 2);
line([0, results.radial.L_total], [0, 0], 'Color', 'k', 'LineStyle', '--');
title('Radial Network Loading');
xlabel('Distance from Source (m)'); ylabel('Current (A)'); hold off;


%% --- FIGURE 3: PERFORMANCE & ECONOMIC COMPARISON ---
figure('Name', 'Performance and Economic Comparison');

% 1. Voltage Profile Comparison
subplot(1, 2, 1);
hold on; grid on; box on;
% Plot Ring Profile
ring_v_dist = [0]; ring_v = [results.U_source]; I_seg = results.ring.Ia;
for i = 1:length(results.loads), seg_len = results.loads(i).distance - ring_v_dist(end); drop = (1/(results.sigma*results.crossSection))*I_seg*seg_len; ring_v(end+1) = ring_v(end)-drop; ring_v_dist(end+1) = results.loads(i).distance; I_seg = I_seg - results.loads(i).current; end
plot(ring_v_dist, ring_v, '-r', 'DisplayName', 'Ring Voltage');
% Plot Radial Profile
rad_v_dist = [0]; rad_v = [results.U_source]; I_seg = sum([results.loads.current]);
for i = 1:length(results.loads), seg_len = results.loads(i).distance - rad_v_dist(end); drop = (1/(results.sigma*results.crossSection))*I_seg*seg_len; rad_v(end+1) = rad_v(end)-drop; rad_v_dist(end+1) = results.loads(i).distance; I_seg = I_seg - results.loads(i).current; end
plot(rad_v_dist, rad_v, '--b', 'DisplayName', 'Radial Voltage');
title('Voltage Profile Comparison');
xlabel('Distance from Source (m)'); ylabel('Voltage (V)');
legend('show', 'Location', 'southwest');

% 2. Economic Analysis Plot
subplot(1, 2, 2);
categories = {'Ring', 'Radial'};
cable_costs = [results.ring.cable_cost, results.radial.cable_cost];
loss_costs = [results.ring.loss_cost, results.radial.loss_cost];
bar_data = [cable_costs', loss_costs'];
bar(bar_data, 'stacked');
set(gca, 'xticklabel', categories);
ylabel('Lifecycle Cost (€)');
title('Economic Analysis (20 Years)');
legend('Initial Cable Cost', 'Cost of Losses');
grid on;

end




% function C7_PlotComparison(results)
% % =========================================================================
% % FUNCTION: Plot Network Comparison Charts (V2 - with Loading Diagrams)
% % =========================================================================
% % Description:
% % Generates a 2x2 figure to visually compare the Ring and Radial
% % networks. The top row shows side-by-side loading diagrams, and the
% % bottom row shows bar charts for Voltage Quality and Economics.
% %
% % MODIFIED: The figure layout is now a 2x2 grid.
% % =========================================================================
% figure('Name', 'Network Topology Comparison', 'Position', [100, 100, 1200, 800]);
% 
% % --- TOP ROW: LOADING DIAGRAMS ---
% 
% % 1. Ring Network Loading Diagram
% subplot(2, 2, 1);
% hold on; box on; grid on;
% ring_distances = [0];
% ring_currents = [results.ring.Ia];
% current_in_segment = results.ring.Ia;
% for i = 1:length(results.loads)
%     ring_distances(end+1) = results.loads(i).distance;
%     ring_currents(end+1) = current_in_segment;
%     current_in_segment = current_in_segment - results.loads(i).current;
%     ring_distances(end+1) = results.loads(i).distance;
%     ring_currents(end+1) = current_in_segment;
% end
% ring_distances(end+1) = results.ring.L_total;
% ring_currents(end+1) = -results.ring.Ib;
% plot(ring_distances, ring_currents, '-r', 'LineWidth', 2);
% line([0, results.ring.L_total], [0, 0], 'Color', 'k', 'LineStyle', '--');
% title('Ring Network Loading Diagram');
% xlabel('Distance from Feed Point (m)');
% ylabel('Current (A)');
% hold off;
% 
% % 2. Radial Network Loading Diagram
% subplot(2, 2, 2);
% hold on; box on; grid on;
% radial_distances = [0];
% radial_currents = [sum([results.loads.current])];
% current_in_segment = sum([results.loads.current]);
% for i = 1:length(results.loads)
%     radial_distances(end+1) = results.loads(i).distance;
%     radial_currents(end+1) = current_in_segment;
%     current_in_segment = current_in_segment - results.loads(i).current;
%     radial_distances(end+1) = results.loads(i).distance;
%     radial_currents(end+1) = current_in_segment;
% end
% plot(radial_distances, radial_currents, '-b', 'LineWidth', 2);
% line([0, results.radial.L_total], [0, 0], 'Color', 'k', 'LineStyle', '--');
% title('Radial Network Loading Diagram');
% xlabel('Distance from Source (m)');
% ylabel('Current (A)');
% hold off;
% 
% 
% % --- BOTTOM ROW: BAR CHARTS ---
% 
% % 3. Voltage Quality Plot
% subplot(2, 2, 3);
% categories = {'Ring', 'Radial'};
% voltage_drops = [results.ring.max_drop_percent, results.radial.max_drop_percent];
% bar(voltage_drops);
% set(gca, 'xticklabel', categories);
% ylabel('Max Voltage Drop (%)');
% title('Voltage Quality (Normal Operation)');
% grid on;
% 
% % 4. Economic Analysis Plot
% subplot(2, 2, 4);
% cable_costs = [results.ring.cable_cost, results.radial.cable_cost];
% loss_costs = [results.ring.loss_cost, results.radial.loss_cost];
% bar_data = [cable_costs', loss_costs'];
% bar(bar_data, 'stacked');
% set(gca, 'xticklabel', categories);
% ylabel('Lifecycle Cost (€)');
% title('Economic Analysis (20 Years)');
% legend('Initial Cable Cost', 'Cost of Losses');
% grid on;
% 
% end
% 
