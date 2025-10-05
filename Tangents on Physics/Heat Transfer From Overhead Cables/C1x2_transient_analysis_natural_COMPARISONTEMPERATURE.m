function C1x2_transient_analysis_natural_COMPARISONTEMPERATURE()

%THIS MODEL WILL REACH 85 DEGREES OF TEMPERATURE AT A LESSER CURRENT TO
%COMPARE WITH THE FORCED CONVECTION MODEL


% =========================================================================
% FUNCTION: TRANSIENT ANALYSIS FOR NATURAL CONVECTION (RK4 METHOD)
% =========================================================================
% This script simulates the temperature evolution of a cable in still air.
% It uses a two-node thermal model and the 4th Order Runge-Kutta (RK4)
% numerical method for a stable and realistic solution.

clear; clc; close all;

%% 1. SIMULATION SETUP
% -- Current and Time Parameters --
% NOTE: This current is set lower than the forced convection case.
% This value is chosen to make the final conductor temperature reach a
% similar high level (~85-90 C) for comparison purposes.
I_applied = 108;      % Applied current [A]
t_end = 7200;        % Total simulation time [s] (e.g., 7200s = 2 hours)
dt = 1;              % Time step [s]

% -- Environmental & Boundary Conditions --
T_initial = 40 + 273.15;      % Initial cable temperature [K]
T_infinity = 40 + 273.15;     % Ambient air temperature [K]

% -- Cable Geometry --
r_i = 2.5e-3;       % Conductor radius [m]
thickness = 1.0e-3; % Insulation thickness [m]
r_o = r_i + thickness; % Outer radius [m]
L = 1.0;            % Cable length [m]

% -- Material Properties --
resistivity_cu = 1.68e-8;
density_cu = 8960;
cp_cu = 385;
k_xlpe = 0.3;
density_xlpe = 920;
cp_xlpe = 2100;

%% 2. PRE-CALCULATIONS
time_vector = 0:dt:t_end;
n_steps = length(time_vector);
A_cu = pi * r_i^2;
R_ohm = (resistivity_cu * L) / A_cu;
Q_gen = I_applied^2 * R_ohm;
vol_cu = A_cu * L;
C_cu_only = density_cu * vol_cu * cp_cu;
vol_xlpe = pi * (r_o^2 - r_i^2) * L;
C_xlpe_total = density_xlpe * vol_xlpe * cp_xlpe;
C_node1 = C_cu_only + 0.5 * C_xlpe_total;
C_node2 = 0.5 * C_xlpe_total;
R_cond = log(r_o / r_i) / (2 * pi * k_xlpe * L);
T_conductor = ones(1, n_steps) * T_initial;
T_surface = ones(1, n_steps) * T_initial;

%% 3. TRANSIENT SIMULATION LOOP (RK4 Method)
fprintf('Starting robust transient simulation (RK4) for NATURAL convection...\n');
for i = 2:n_steps
    T_prev = [T_conductor(i-1); T_surface(i-1)];
    
    k1 = get_temp_derivatives(T_prev);
    k2 = get_temp_derivatives(T_prev + 0.5 * dt * k1);
    k3 = get_temp_derivatives(T_prev + 0.5 * dt * k2);
    k4 = get_temp_derivatives(T_prev + dt * k3);
    
    T_new = T_prev + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4);
    
    if any(isnan(T_new)) || any(isinf(T_new))
        fprintf('\nERROR: Simulation became unstable at t = %.2f s.\n', time_vector(i));
        fprintf('ACTION: Try reducing the time step (dt) and re-run.\n\n');
        T_conductor = T_conductor(1:i-1);
        T_surface = T_surface(1:i-1);
        time_vector = time_vector(1:i-1);
        break;
    end
    
    T_conductor(i) = T_new(1);
    T_surface(i) = T_new(2);
end
fprintf('Simulation complete.\n');

%% 4. PLOT RESULTS
if length(time_vector) > 1
    figure('Name', 'Transient Heating: Natural Convection');
    plot(time_vector / 3600, T_conductor - 273.15, 'r-', 'LineWidth', 2);
    hold on;
    plot(time_vector / 3600, T_surface - 273.15, 'b--', 'LineWidth', 2);
    yline(90, 'k:', 'LineWidth', 1.5, 'Label', 'Max Conductor Temp (90 °C)');
    grid on;
    title(sprintf('Cable Temperature vs. Time (Natural Convection, I = %.0f A)', I_applied));
    xlabel('Time (hours)');
    ylabel('Temperature (°C)');
    legend('Conductor Temperature', 'Insulation Surface Temp', 'Location', 'southeast');
    ylim([T_infinity-273.15-5, max(T_conductor-273.15)+10]);
end

%% 5. HELPER FUNCTIONS
    function dTdt = get_temp_derivatives(T_vector)
        T_cond_current = T_vector(1);
        T_surf_current = T_vector(2);
        Q_cond = (T_cond_current - T_surf_current) / R_cond;
        Q_conv = calculate_dissipated_heat(T_surf_current);
        dT_cu_dt = (Q_gen - Q_cond) / C_node1;
        dT_surf_dt = (Q_cond - Q_conv) / C_node2;
        dTdt = [dT_cu_dt; dT_surf_dt];
    end

    function Q_out = calculate_dissipated_heat(T_surf)
        if T_surf <= T_infinity
            Q_out = 0; return;
        end
        D_outer = 2 * r_o;
        A_surface = pi * D_outer * L;
        T_film = (T_surf + T_infinity) / 2;
        air = getAirProperties(T_film);
        g = 9.81;
        beta = 1 / T_film;
        Ra = (g * beta * (T_surf - T_infinity) * D_outer^3) / (air.nu * air.alpha);
        term1 = 0.60;
        term2 = 0.387 * Ra^(1/6);
        term3 = (1 + (0.559 / air.Pr)^(9/16))^(8/27);
        Nu = (term1 + term2 / term3)^2;
        hc = Nu * air.k / D_outer;
        Q_out = hc * A_surface * (T_surf - T_infinity);
    end

    function props = getAirProperties(T_K)
        air_data = [250 1.413 1.596e-5 0.0223 0.720; 300 1.177 1.849e-5 0.0263 0.707; 350 0.998 2.082e-5 0.0300 0.700; 400 0.883 2.286e-5 0.0338 0.690; 450 0.783 2.484e-5 0.0373 0.688];
        rho = interp1(air_data(:,1), air_data(:,2), T_K, 'linear', 'extrap');
        mu  = interp1(air_data(:,1), air_data(:,3), T_K, 'linear', 'extrap');
        k   = interp1(air_data(:,1), air_data(:,4), T_K, 'linear', 'extrap');
        Pr  = interp1(air_data(:,1), air_data(:,5), T_K, 'linear', 'extrap');
        cp  = 1007;
        props.rho = rho; props.mu = mu; props.k = k; props.Pr = Pr; props.nu = mu/rho; props.alpha = k/(rho*cp);
    end
end

