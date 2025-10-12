function C2_PlotRingProfile(results)
% =========================================================================
% FUNCTION: Plot Ring Voltage Profile (as an unwrapped line)
% =========================================================================
figure;
hold on;
box on;
grid on;

% Create points for plotting the unwrapped ring
sorted_loads = sortrows(struct2table(results.loads), 'distance');
distances = [0, sorted_loads.distance', results.L_total];
voltages = [results.Ua];
current_in_segment = results.Ia;

for i = 1:height(sorted_loads)
    prev_dist = distances(i);
    segment_length = sorted_loads.distance(i) - prev_dist;
    drop = (1/(results.sigma*results.crossSection)) * current_in_segment * segment_length;
    voltages(end+1) = voltages(end) - drop;
    current_in_segment = current_in_segment - sorted_loads.current(i);
end
voltages(end+1) = results.Ua; % It must return to the start voltage at the end of the line

plot(distances, voltages, '-ob', 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(results.min_voltage_node_distance, results.min_voltage, 'kd', 'MarkerSize', 10, 'MarkerFaceColor', 'y');

title(['Voltage Profile for Ring Network (Unwrapped)']);
xlabel('Distance from Feed Point along Ring (m)');
ylabel('Voltage (V)');
legend('Voltage Profile', 'Minimum Voltage Point', 'Location', 'south');
end

