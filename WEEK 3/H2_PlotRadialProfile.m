function H2_PlotRadialProfile(results)
% =========================================================================
% FUNCTION: Plot Radial Voltage Profile
% =========================================================================
figure;
hold on;
box on;
grid on;

distances = [0, cumsum([results.nodes.length])];
voltages = [results.U_source, [results.nodes.voltage]];

plot(distances, voltages, '-ob', 'LineWidth', 2, 'MarkerFaceColor', 'r');

title(['Voltage Profile for Radial Network (' results.scenarioName ')']);
xlabel('Distance from Source (m)');
ylabel('Voltage (V)');
xlim([0, distances(end) * 1.1]);
ylim([voltages(end) * 0.99, results.U_source * 1.01]);
legend('Voltage Profile', 'Location', 'southwest');
end
 