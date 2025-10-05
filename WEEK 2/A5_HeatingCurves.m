function A5_HeatingCurves(I_max, T_mat, envParams, R_20_DC, R_20_AC, alpha, T_ref, lineLength, r_inner, r_outer, materialName, insulationName)
% =========================================================================
% FUNCTION: A5_HeatingCurves (V5 - Corrected)
% =========================================================================
% Description:
% Generates plots showing the conductor's equilibrium temperature vs. current.
% MODIFIED: The input variable 'length' was renamed to 'lineLength' to
%           avoid conflict with MATLAB's built-in length() function, which
%           was causing a runtime error.
% =========================================================================

% 1. Create a vector of currents to plot
current_vector = linspace(0, I_max * 1.2, 100);

% 2. Calculate equilibrium temperatures for both DC and AC resistance
temp_vector_dc = zeros(size(current_vector));
temp_vector_ac = zeros(size(current_vector));

% The loop now correctly calls the built-in 'length' function
for i = 1:length(current_vector)
    % The variable 'lineLength' is correctly passed to the next function
    temp_vector_dc(i) = A4_ThermalEquilibrium(current_vector(i), R_20_DC, alpha, T_ref, envParams, lineLength, r_inner, r_outer);
    temp_vector_ac(i) = A4_ThermalEquilibrium(current_vector(i), R_20_AC, alpha, T_ref, envParams, lineLength, r_inner, r_outer);
end

% 3. Create the plot
figure;
hold on;

% Plot the curves
plot(current_vector, temp_vector_dc, 'b-', 'LineWidth', 2, 'DisplayName', 'Equilibrium Temp (DC)');
plot(current_vector, temp_vector_ac, 'r-', 'LineWidth', 2, 'DisplayName', 'Equilibrium Temp (AC)');

% Plot safety and reference lines
line([0, I_max * 1.2], [T_mat, T_mat], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', sprintf('Max Temp (%.0f°C)', T_mat));
line([I_max, I_max], [envParams.T_env, T_mat], 'Color', [0.4660 0.6740 0.1880], 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', sprintf('Max AC Current (%.1f A)', I_max));

% Add marker at the intersection
plot(I_max, T_mat, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility', 'off');

% Formatting
title(sprintf('Steady-State Heating Curve (%s)', envParams.scenario));
subtitle(sprintf('%s Conductor, %s Insulation', materialName, insulationName));
xlabel('Current (A)');
ylabel('Conductor Temperature (°C)');
legend('show', 'Location', 'southeast');
grid on;
box on;
ylim([envParams.T_env - 10, T_mat + 20]);
xlim([0, I_max * 1.25]);
hold off;

end

