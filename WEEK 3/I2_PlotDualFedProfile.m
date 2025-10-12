function I2_PlotDualFedProfile(results)
% =========================================================================
% FUNCTION: Plot Dual-Fed Voltage Profile (V2 - Reliability)
% =========================================================================
% MODIFIED: Now plots failure scenarios if the data is available.
% =========================================================================
figure;
hold on; box on; grid on;

% 1. Plot Normal Operation Profile
sorted_loads = results.loads;
distances = [0, [sorted_loads.distance], results.L_total];
voltages_normal = [results.Ua];
current_in_segment = results.Ia;
for i = 1:length(sorted_loads)
    prev_dist = distances(i);
    segment_length = sorted_loads(i).distance - prev_dist;
    drop = (1/(results.sigma*results.crossSection)) * current_in_segment * segment_length;
    voltages_normal(end+1) = voltages_normal(end) - drop;
    current_in_segment = current_in_segment - sorted_loads(i).current;
end
voltages_normal(end+1) = results.Ub;

plot(distances, voltages_normal, '-ob', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'DisplayName', 'Normal Operation');
plot(results.min_voltage_node_distance, results.min_voltage_normal, 'kd', 'MarkerSize', 10, 'MarkerFaceColor', 'y');

% 2. Plot Failure Scenarios if data exists
if isfield(results, 'min_voltage_fail_B')
    % Source B Fails (Radial from A)
    voltages_fail_B = [results.Ua];
    drop = 0;
    for i = 1:length(sorted_loads)
        current = sum([sorted_loads(i:end).current]);
        if i==1, seg_len = sorted_loads(i).distance; else, seg_len = sorted_loads(i).distance - sorted_loads(i-1).distance; end
        drop = drop + (1/(results.sigma*results.crossSection)) * current * seg_len;
        voltages_fail_B(end+1) = results.Ua - drop;
    end
    plot([0, [sorted_loads.distance]], voltages_fail_B, '--r', 'LineWidth', 1.5, 'DisplayName', 'Source B Failure');
end

if isfield(results, 'min_voltage_fail_A')
    % Source A Fails (Radial from B)
    voltages_fail_A = [results.Ub];
    loads_from_B = sortrows(struct2table(results.loads), 'distance', 'descend');
    drop = 0;
    for i = 1:height(loads_from_B)
        current = sum(loads_from_B.current(i:end));
        if i==1, seg_len = results.L_total - loads_from_B.distance(i); else, seg_len = loads_from_B.distance(i-1) - loads_from_B.distance(i); end
        drop = drop + (1/(results.sigma*results.crossSection)) * current * seg_len;
        voltages_fail_A(end+1) = results.Ub - drop;
    end
    plot([results.L_total, loads_from_B.distance'], voltages_fail_A, ':g', 'LineWidth', 1.5, 'DisplayName', 'Source A Failure');
end


title(['Voltage Profile for Dual-Fed Network (' results.scenarioName ')']);
xlabel('Distance from Source A (m)');
ylabel('Voltage (V)');
legend('show', 'Location', 'south');
end

