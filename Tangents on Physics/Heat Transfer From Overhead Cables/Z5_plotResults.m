function Z5_plotResults(results)
% -------------------------------------------------------------------------
% Z5_plotResults(results)
% -------------------------------------------------------------------------
% Generates a set of plots based on the data in the 'results' struct.
% -------------------------------------------------------------------------

% Unpack common data
t_hours = results.t_vector / 3600; % Time in hours for plotting
T_A = results.T_A_t;
T_B = results.T_B_t;
T_C = results.scenario.T_ambient;
T_ss = results.T_ss;

% --- Figure 1: Temperature vs. Time ---
figure('Name', 'Temperature vs. Time');
hold on;
plot(t_hours, T_A, 'r-', 'LineWidth', 2);
plot(t_hours, T_B, 'b--', 'LineWidth', 2);
plot(t_hours, repmat(T_ss, size(t_hours)), 'k:', 'LineWidth', 1.5);
plot(t_hours, repmat(T_C, size(t_hours)), 'g:', 'LineWidth', 1.5);
hold off;
grid on;
title('Cable Temperature vs. Time');
xlabel('Time (hours)');
ylabel('Temperature (deg C)');
legend('Conductor (T_A)', 'Surface (T_B)', 'Steady-State (T_{ss})', 'Ambient (T_C)', 'Location', 'best');
axis tight;

% --- Figure 2: Radial Profile (Insulation) ---
figure('Name', 'Insulation Temperature Profile (2D)');
hold on;
r_ins_mm = results.r_ins_vector * 1000; % Convert to mm
profile_times_sec = results.sim.profile_times_sec;
legend_entries = cell(length(profile_times_sec), 1);

for i = 1:length(profile_times_sec)
    plot(r_ins_mm, results.T_ins_profile(i, :), 'LineWidth', 2);
    legend_entries{i} = ['t = ' num2str(profile_times_sec(i)/3600, '%.1f') ' hours'];
end
hold off;
grid on;
title('Radial Temperature Profile (Insulation)');
xlabel('Radius (mm)');
ylabel('Temperature (deg C)');
legend(legend_entries, 'Location', 'best');
axis tight;

% --- Figure 3: Radial Profile (Soil) ---
% Only plot if this data exists
if ~isempty(results.T_soil_profile)
    figure('Name', 'Soil Temperature Profile');
    hold on;
    r_soil_m = results.r_soil_vector; % In meters
    legend_entries = cell(length(profile_times_sec), 1);

    for i = 1:length(profile_times_sec)
        plot(r_soil_m, results.T_soil_profile(i, :), 'LineWidth', 2);
        legend_entries{i} = ['t = ' num2str(profile_times_sec(i)/3600, '%.1f') ' hours'];
    end
    
    % Plot ambient soil temp
    plot(r_soil_m, repmat(T_C, size(r_soil_m)), 'g:', 'LineWidth', 1.5);
    legend_entries{end+1} = 'Ambient Soil (T_C)';
    
    hold off;
    grid on;
    title('Radial Temperature Profile (Soil)');
    xlabel('Distance from Cable Center (m)');
    ylabel('Temperature (deg C)');
    legend(legend_entries, 'Location', 'best');
    axis tight;
end

% --- Figure 4: Insulation Profile (3D Surface) ---
figure('Name', 'Insulation Temperature Profile (3D)');

% Create meshgrid for 3D plot
[T_MESH, R_MESH] = meshgrid(t_hours, r_ins_mm);

% Plot the surface. Note: T_ins_profile_full is [time, radius]
% We need to transpose it to [radius, time] to match the meshgrid.
surf(T_MESH, R_MESH, results.T_ins_profile_full', 'EdgeColor', 'none');
title('3D Temperature Profile (Insulation)');
xlabel('Time (hours)');
ylabel('Radius (mm)');
zlabel('Temperature (deg C)');
colorbar;
axis tight;

% --- Figure 5: Cable Cross-Section ---
figure('Name', 'Cable Geometry');
hold on;
r1_mm = results.params.conductor.r1 * 1000;
r2_mm = results.params.conductor.r2 * 1000;

% Use a helper function to draw filled circles
plot_circle(0, 0, r2_mm, [0.4 0.4 1]); % Insulation (light blue)
plot_circle(0, 0, r1_mm, [1 0.5 0.2]); % Conductor (orange)

hold off;
axis equal; % Ensures the circles are round
axis off; % Hide the x/Y axes
title('Cable Cross-Section');
legend('Insulation', 'Conductor', 'Location', 'northeastoutside');

end


function h = plot_circle(x, y, r, c)
% Helper function to plot a filled circle
% x, y: center coordinates
% r: radius
% c: color triplet [R G B]
    t = linspace(0, 2*pi, 100);
    X = r * cos(t) + x;
    Y = r * sin(t) + y;
    h = fill(X, Y, c);
end