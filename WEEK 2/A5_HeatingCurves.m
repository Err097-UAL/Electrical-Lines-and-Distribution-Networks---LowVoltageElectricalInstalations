function A5_HeatingCurves(I_max, T_mat, T_env, R_20, alpha, T_ref, k, diameter, lineLength, materialName, insulationName)
% =========================================================================
% FUNCTION: plotHeatingCurves
% =========================================================================
% Description:
% Generates a plot showing the conductor's equilibrium temperature as a
% function of the electrical current. It also displays key safety limits,
% including the maximum allowable temperature and the corresponding
% maximum current.
%
% Inputs:
%   I_max          - Maximum allowable current [A]
%   T_mat          - Maximum allowable material temperature [°C]
%   T_env          - Ambient environment temperature [°C]
%   (and other parameters required by solveThermalEquilibrium)
%   materialName   - String name of the conductor material
%   insulationName - String name of the insulation material
% =========================================================================

% 1. Create a vector of currents to plot
% We'll plot from 0A up to 20% beyond the calculated max current
current_vector = linspace(0, I_max * 1.2, 200);

% 2. Calculate the equilibrium temperature for each current in the vector
temp_vector = zeros(size(current_vector));
for i = 1:length(current_vector)
    temp_vector(i) = A4_ThermalEquilibrium(current_vector(i), R_20, alpha, T_ref, T_env, k, diameter, lineLength);
end

% 3. Create the plot
figure;
hold on;

% Plot the main temperature vs. current curve
plot(current_vector, temp_vector, 'b-', 'LineWidth', 2, 'DisplayName', 'Equilibrium Temperature');

% Plot the Maximum Temperature Safety Line (horizontal)
line([0, I_max * 1.2], [T_mat, T_mat], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', sprintf('Max Temp (%.0f°C)', T_mat));

% Plot the Maximum Current Line (vertical)
line([I_max, I_max], [T_env, T_mat], 'Color', 'g', 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', sprintf('Max Current (%.1f A)', I_max));

% Add a marker at the intersection point
plot(I_max, T_mat, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Operating Limit');

% 4. Formatting and Labels
title({'Conductor Heating Curve and Safety Margins', ...
       sprintf('%s Conductor with %s Insulation', materialName, insulationName)});
xlabel('Current (A)');
ylabel('Equilibrium Temperature (°C)');
grid on;
legend('show', 'Location', 'southeast');
axis([0, I_max * 1.2, T_env-5, T_mat * 1.2]); % Set axis limits for better viewing
hold off;

end


