function [] = B5_plotVoltageProfile(U_source, deltaU_total_dc, deltaU_total_ac, total_length, circuitType)
% =========================================================================
% FUNCTION: plotVoltageProfile (V2 - AC/DC Comparison)
% =========================================================================
% MODIFIED:
% - Now accepts voltage drop values calculated from both DC and AC resistance.
% - Plots both voltage profiles on the same axes for direct comparison.
% =========================================================================

% 1. Create a vector of distances from source to load
length_vector = linspace(0, total_length, 200);

% 2. Calculate the voltage profile for both DC and AC resistance cases
voltage_profile_dc = U_source - (deltaU_total_dc / total_length) * length_vector;
voltage_profile_ac = U_source - (deltaU_total_ac / total_length) * length_vector;

% 3. Determine the minimum allowed voltage based on REBT limits
switch circuitType
    case 'lighting', limit_percent = 4.5 / 100;
    case 'power', limit_percent = 6.5 / 100;
end
min_voltage_limit = U_source * (1 - limit_percent);

% 4. Create the plot
figure;
hold on;

% Plot the voltage profiles
plot(length_vector, voltage_profile_dc, 'b-', 'LineWidth', 2, 'DisplayName', 'Voltage Profile (DC Res.)');
plot(length_vector, voltage_profile_ac, 'r-', 'LineWidth', 2, 'DisplayName', 'Voltage Profile (AC Res.)');

% Plot the REBT minimum voltage limit line
line([0, total_length], [min_voltage_limit, min_voltage_limit], ...
    'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('REBT Limit (%.2f V)', min_voltage_limit));

% Add markers at the end of the line
plot(total_length, U_source - deltaU_total_dc, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'HandleVisibility', 'off');
plot(total_length, U_source - deltaU_total_ac, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility', 'off');

% Formatting
title(sprintf('Voltage Profile Comparison (DC vs AC Resistance) for %s Line', circuitType));
xlabel('Line Length (m)');
ylabel('Voltage (V)');
legend('show', 'Location', 'southwest');
grid on;
box on;
ylim([min_voltage_limit * 0.99, U_source * 1.01]);
xlim([0, total_length]);
hold off;

end

