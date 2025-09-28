function [] = C5_plotEconomicAnalysis(sections, cable_costs, loss_costs, total_costs, s_technical, s_optimal)
% =========================================================================
% FUNCTION: plotEconomicAnalysis
% =========================================================================
% Description:
% Generates a bar chart to visually compare the lifecycle costs of
% different standard conductor sizes. It highlights the technically
% minimum and economically optimal cross-sections.
%
% Inputs:
%   sections    - A struct array of the sections analyzed
%   cable_costs - Vector of initial cable costs
%   loss_costs  - Vector of energy loss costs
%   total_costs - Vector of total lifecycle costs
%   s_technical - The technically minimum section [mm^2]
%   s_optimal   - The economically optimal section [mm^2]
% =========================================================================

figure;

% Extract section sizes for x-axis labels
section_labels = arrayfun(@(x) num2str(x.section), sections, 'UniformOutput', false);
x_categories = categorical(section_labels);
x_categories = reordercats(x_categories, section_labels); % Preserve order

% Create a stacked bar chart
bar_data = [cable_costs', loss_costs'];
b = bar(x_categories, bar_data, 'stacked');
hold on;

% Overlay the total cost as a line plot with markers
plot(x_categories, total_costs, 'd-r', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Total Lifecycle Cost');

% Highlight the optimal section
optimal_idx = find([sections.section] == s_optimal);
if ~isempty(optimal_idx)
    text(x_categories(optimal_idx), total_costs(optimal_idx), '  Optimal', 'Color', 'red', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
end

% Highlight the technical minimum section
technical_idx = find([sections.section] == s_technical);
if ~isempty(technical_idx)
     text(x_categories(technical_idx), total_costs(technical_idx), '  Technical Min.', 'Color', 'black', 'VerticalAlignment', 'top');
end

% Formatting and Labels
title('Economic Analysis of Conductor Sizing');
xlabel('Standard Conductor Cross-Section (mm^2)');
ylabel('Lifecycle Cost (Currency)');
legend('Initial Cable Cost', 'Cost of Energy Losses', 'Total Lifecycle Cost', 'Location', 'northeast');
grid on;
hold off;

b(1).FaceColor = [0.2, 0.6, 1]; % Blue for cable cost
b(2).FaceColor = [1, 0.6, 0.2]; % Orange for loss cost

end
