function C7_PlotComparison(results)
% =========================================================================
% FUNCTION: Plot Network Comparison Charts (NEW)
% =========================================================================
% Description:
% Generates a set of bar charts to visually compare the Ring and Radial
% networks based on Voltage Quality, Reliability, and Economics.
% =========================================================================
figure('Name', 'Network Topology Comparison');

% Data for plotting
categories = {'Ring', 'Radial'};
voltage_drops = [results.ring.max_drop_percent, results.radial.max_drop_percent];
reliability_drops = [results.reliability.max_drop_percent_fault, results.radial.max_drop_percent*1.5]; % Radial failure is outage, show as higher drop
costs = [results.ring.total_cost, results.radial.total_cost];
cable_costs = [results.ring.cable_cost, results.radial.cable_cost];
loss_costs = [results.ring.loss_cost, results.radial.loss_cost];

% 1. Voltage Quality Plot
subplot(1, 3, 1);
bar(voltage_drops);
set(gca, 'xticklabel', categories);
ylabel('Max Voltage Drop (%)');
title('Voltage Quality (Normal)');
grid on;

% 2. Reliability / Failure Impact Plot
subplot(1, 3, 2);
b = bar(reliability_drops);
set(gca, 'xticklabel', categories);
ylabel('Max Voltage Drop During Fault (%)');
title('Reliability (Failure Impact)');
grid on;
b.FaceColor = 'flat';
b.CData(2,:) = [0.8500 0.3250 0.0980]; % Make radial bar red
text(2, reliability_drops(2), 'Outage', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');


% 3. Economic Analysis Plot
subplot(1, 3, 3);
bar_data = [cable_costs', loss_costs'];
bar(bar_data, 'stacked');
set(gca, 'xticklabel', categories);
ylabel('Lifecycle Cost (€)');
title('Economic Analysis');
legend('Initial Cable Cost', 'Cost of Losses');
grid on;

end
