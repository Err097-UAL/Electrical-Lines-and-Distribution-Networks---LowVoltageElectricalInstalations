function A3_plot_temperature_profile(r_i, r_o, T_cond, T_surf)
    % =========================================================================
    % PLOTS THE TEMPERATURE PROFILE THROUGH THE INSULATION
    % =========================================================================
    % The temperature drop across a hollow cylinder is logarithmic.

    % Create a radius vector from inner to outer edge
    r_vector = linspace(r_i, r_o, 100);

    % Calculate temperature at each point in the radius vector
    % T(r) = T_cond - (Q * R_cond(r))
    % This simplifies to the logarithmic relation below:
    T_vector = T_cond - (T_cond - T_surf) .* log(r_vector./r_i) ./ log(r_o/r_i);

    % Convert to Celsius for plotting
    T_vector_C = T_vector - 273.15;
    
    % Create the plot
    figure('Name', 'Cable Temperature Profile');
    plot(r_vector * 1000, T_vector_C, 'r-', 'LineWidth', 2);
    grid on;
    hold on;
    
    % Add markers for key points
    plot(r_i*1000, T_cond-273.15, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
    text(r_i*1000, T_cond-273.15, sprintf('  Conductor: %.1f °C', T_cond-273.15), 'VerticalAlignment','bottom');
    
    plot(r_o*1000, T_surf-273.15, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
    text(r_o*1000, T_surf-273.15, sprintf('  Surface: %.1f °C', T_surf-273.15), 'VerticalAlignment','top');
    
    % Formatting
    title('Steady-State Temperature Profile in Insulation');
    xlabel('Radius from Cable Center (mm)');
    ylabel('Temperature (°C)');
    xlim([r_i*1000-0.5, r_o*1000+0.5]); % Add some padding
    legend('Temperature Profile', 'Location', 'best');
    hold off;
end
