function A5_HeatingCurves(I_max_DC, I_max_AC, T_mat, T_env, R_20_DC, R_20_AC, alpha, T_ref, k, lineLength, r_inner, r_outer, materialName, insulationName)
% =========================================================================
% FUNCTION: plotHeatingCurves (V3)
% =========================================================================
% Description:
% Generates a comparative plot showing the steady-state temperature for
% both DC and AC resistance as a function of current.
% =========================================================================

% Create a current vector based on the larger of the two max currents
current_vector = linspace(0, I_max_DC * 1.2, 200);

% Calculate equilibrium temperatures for both DC and AC cases
temp_vector_dc = zeros(size(current_vector));
temp_vector_ac = zeros(size(current_vector));
for i = 1:length(current_vector)
    temp_vector_dc(i) = A4_ThermalEquilibrium(current_vector(i), R_20_DC, alpha, T_ref, T_env, k, lineLength, r_inner, r_outer);
    temp_vector_ac(i) = A4_ThermalEquilibrium(current_vector(i), R_20_AC, alpha, T_ref, T_env, k, lineLength, r_inner, r_outer);
end

% Create the plot
figure;
hold on;
plot(current_vector, temp_vector_dc, 'b-', 'LineWidth', 2, 'DisplayName', 'Temp (DC Res.)');
plot(current_vector, temp_vector_ac, 'r-', 'LineWidth', 2, 'DisplayName', 'Temp (AC Res.)');

% Plot Max Temperature Line
line([0, current_vector(end)], [T_mat, T_mat], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', sprintf('Max Temp (%.0f°C)', T_mat));

% Plot Max Current Lines for DC and AC
line([I_max_DC, I_max_DC], [T_env, T_mat], 'Color', 'b', 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', sprintf('I_{max,DC} (%.1f A)', I_max_DC));
line([I_max_AC, I_max_AC], [T_env, T_mat], 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', sprintf('I_{max,AC} (%.1f A)', I_max_AC));

% Formatting
title(sprintf('DC vs AC Steady-State Heating for %s (%s)', materialName, insulationName));
xlabel('Current (A)');
ylabel('Equilibrium Temperature (°C)');
grid on;
legend('show', 'Location', 'southeast');
ylim([T_env-10, T_mat + 20]);
hold off;

end

