function H2_PlotRadialProfile(results)
% =========================================================================
% FUNCTION: Plot Radial Voltage Profile (V2 - Corrected)
% =========================================================================
% MODIFIED:
% - Corrected the error by using the field name 'loads' instead of 'nodes'.
% - Uses the pre-calculated 'distance' field for the x-axis.
% =========================================================================
figure;
hold on;
box on;
grid on;

% CORRECTED: Use 'loads' field, which exists in the results struct.
distances = [0, [results.loads.distance]];
voltages = [results.U_source, [results.loads.voltage]];

plot(distances, voltages, '-ob', 'LineWidth', 2, 'MarkerFaceColor', 'r');

title(['Voltage Profile for Radial Network (' results.scenarioName ')']);
xlabel('Distance from Source (m)');
ylabel('Voltage (V)');
xlim([0, distances(end) * 1.1]);
if ~isempty(voltages) && all(isfinite(voltages)) && voltages(end) > 0
    ylim([voltages(end) * 0.99, results.U_source * 1.01]);
end
legend('Voltage Profile', 'Location', 'southwest');
end

