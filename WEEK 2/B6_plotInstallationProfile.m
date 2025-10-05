function B6_plotInstallationProfile(results, U_source)
% =========================================================================
% FUNCTION: B6_plotInstallationProfile (NEW)
% =========================================================================
% Description:
% Plots the voltage profile for an entire electrical installation, showing
% the step-wise voltage drop across each defined segment.
% =========================================================================

numSegments = length(results);
node_voltages = [U_source, cellfun(@(x) x.voltage_out, results)'];
node_lengths = [0, cumsum(cellfun(@(x) x.length, results))'];
segment_names = cellfun(@(x) x.name, results, 'UniformOutput', false);

% Create the plot
figure;
hold on;

% Plot the voltage profile as a step-line plot
stairs(node_lengths, node_voltages, 'b-', 'LineWidth', 2, 'DisplayName', 'Voltage Profile');
plot(node_lengths, node_voltages, 'ro', 'MarkerFaceColor','r', 'HandleVisibility','off');

% --- Add REBT Limit Lines (simplified) ---
% Overall limit for power is 6.5% for DI + Internal
limit_total_percent = 6.5 / 100; 
min_voltage_limit = U_source * (1 - limit_total_percent);
line([0, node_lengths(end)], [min_voltage_limit, min_voltage_limit], ...
    'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Overall REBT Limit (%.2f V)', min_voltage_limit));

% Formatting
title('Voltage Profile Across Complete Installation');
xlabel('Cumulative Line Length (m)');
ylabel('Voltage (V)');
grid on;
box on;
legend('show', 'Location', 'southwest');

% Add labels for each segment node
for i = 2:length(node_lengths)
    text(node_lengths(i), node_voltages(i), sprintf('  %s', segment_names{i-1}), 'VerticalAlignment', 'bottom');
end

% Adjust axis limits for better visualization
xlim([0, node_lengths(end) * 1.1]);
ylim([min(node_voltages) * 0.99, U_source * 1.01]);
hold off;

end
