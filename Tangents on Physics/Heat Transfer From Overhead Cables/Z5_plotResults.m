function plotResults(results)
% -------------------------------------------------------------------------
% plotResults(results)
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
figure('Name', 'Insulation Temperature Profile');
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

end