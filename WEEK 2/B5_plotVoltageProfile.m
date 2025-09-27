function [] = B5_plotVoltageProfile(U_source, deltaU_total, total_length, circuitType)
% =========================================================================
% FUNCTION: plotVoltageProfile
% =========================================================================
% Description:
% Generates a plot of voltage versus line length, illustrating how the
% voltage decreases from the source to the load. It also plots the
% REBT compliance limit as a horizontal line for easy visual inspection.
%
% Inputs:
%   U_source     - The source voltage [V]
%   deltaU_total - The total calculated voltage drop over the line [V]
%   total_length - The total length of the line [m]
%   circuitType  - String: 'lighting' or 'power'
% =========================================================================

% 1. Create a vector of distances from source to load
length_vector = linspace(0, total_length, 200);

% 2. Calculate the voltage at each point along the line
% Voltage drop is assumed to be linear with distance
voltage_profile = U_source - (deltaU_total / total_length) * length_vector;

% 3. Determine the minimum allowed voltage based on REBT limits
switch circuitType
    case 'lighting'
        limit_percent = 4.5 / 100;
    case 'power'
        limit_percent = 6.5 / 100;
end
min_voltage_limit = U_source * (1 - limit_percent);

% 4. Create the plot
figure;
hold on;

% Plot the voltage profile
plot(length_vector, voltage_profile, 'b-', 'LineWidth', 2, 'DisplayName', 'Voltage Profile');

% Plot the REBT minimum voltage limit line
line([0, total_length], [min_voltage_limit, min_voltage_limit], ...
    'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('REBT Limit (%.2f V)', min_voltage_limit));

% Add a marker at the end of the line (load voltage)
plot(total_length, U_source - deltaU_total, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8, ...
    'DisplayName', sprintf('Voltage at Load (%.2f V)', U_source - deltaU_total));

% 5. Formatting and Labels
title('Voltage Profile Along the Line');
xlabel('Line Length (m)');
ylabel('Voltage (V)');
grid on;
legend('show', 'Location', 'best');
% Adjust y-axis to start slightly below the lowest voltage for better visibility
ylim([min(voltage_profile) * 0.99, U_source * 1.01]);
xlim([0, total_length]);
hold off;

end
