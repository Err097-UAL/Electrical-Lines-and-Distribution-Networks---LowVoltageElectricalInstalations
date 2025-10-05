function P_diss = A7_HeatDissipation(T_conductor, envParams, r_outer, length)
% =========================================================================
% FUNCTION: A7_HeatDissipation (Module - Corrected)
% =========================================================================
% Description:
% This is the central module for calculating the net heat dissipation from
% the conductor surface to the environment. It calls the appropriate
% physical model based on the installation scenario defined in envParams.
%
% Inputs:
%   T_conductor - The temperature of the conductor surface [°C]
%   envParams   - A struct containing all environment-specific parameters
%   r_outer     - The outer radius of the cable (including insulation) [m]
%   length      - The length of the conductor [m]
%
% Output:
%   P_diss      - The net heat dissipated from the cable [W].
%                 (Positive for net cooling, negative for net heating)
% =========================================================================

% The main function acts as a router to the correct sub-function
switch envParams.scenario
    case 'underground'
        P_diss = dissipation_underground(T_conductor, envParams.T_env, envParams.rho_soil, envParams.burial_depth, r_outer, length);
    case 'overhead'
        P_diss = dissipation_overhead(T_conductor, envParams.T_env, envParams.wind_speed, envParams.solar_irradiance, envParams.emissivity, envParams.absorptivity, r_outer, length);
    case 'building'
        % For a building, we model it as overhead but with no wind/sun.
        % The grouping factor is applied separately in the functions that call this one.
        P_diss = dissipation_overhead(T_conductor, envParams.T_env, 0, 0, envParams.emissivity, envParams.absorptivity, r_outer, length);
end
end

% --- SUB-FUNCTIONS for each scenario ---

function P_diss = dissipation_underground(T_conductor, T_soil, rho_soil, H, r_outer, L)
% Model based on IEC 60287 for buried cables (simplified)
    if H <= r_outer
        P_diss = 0; % Cable is not buried, avoid log error
        return;
    end
    thermal_resistance = (rho_soil / (2 * pi)) * log(2 * H / r_outer);
    P_diss = (L * (T_conductor - T_soil)) / thermal_resistance;
end

function P_diss = dissipation_overhead(T_conductor, T_air, V_wind, Q_solar, epsilon, alpha, r_outer, L)
% Model based on IEEE 738 standard for overhead lines
    D_outer = r_outer * 2;
    P_conv = convection_overhead(T_conductor, T_air, V_wind, D_outer, L);
    P_rad = radiation_overhead(T_conductor, T_air, epsilon, D_outer, L);
    P_solar = solar_gain(Q_solar, alpha, D_outer, L);

    % Net dissipation is cooling (convection + radiation) minus heating (solar)
    P_diss = (P_conv + P_rad) - P_solar;
end

function P_conv = convection_overhead(T_conductor, T_air, V_wind, D_outer, L)
% Simplified convection model
    k_air = 0.026; % Thermal conductivity of air [W/(m*K)]
    
    % Nusselt number correlations (simplified)
    if V_wind > 0
        % Forced convection
        Re = V_wind * D_outer / 1.5e-5; % Reynolds number, kinematic viscosity of air ~1.5e-5
        Nu = 0.3 + (0.62 * Re^0.5 * 0.71^0.33) / (1 + (0.4/0.71)^0.66)^0.25; % Prandtl for air ~0.71
    else
        % Natural convection
        Gr = 9.81 * (1/(T_air+273.15)) * abs(T_conductor - T_air) * D_outer^3 / (1.5e-5)^2; % Grashof
        Nu = (0.6 + (0.387 * (Gr*0.71)^0.166) / (1 + (0.559/0.71)^0.562)^0.296)^2;
    end
    
    h = (k_air / D_outer) * Nu; % Convective heat transfer coefficient
    surface_area = pi * D_outer * L;
    P_conv = h * surface_area * (T_conductor - T_air);
end

function P_rad = radiation_overhead(T_conductor, T_air, epsilon, D_outer, L)
% Radiation based on Stefan-Boltzmann law
    sigma_sb = 5.67e-8; % Stefan-Boltzmann constant [W/(m^2*K^4)]
    surface_area = pi * D_outer * L;
    
    % Temperatures must be in Kelvin
    T_cond_K = T_conductor + 273.15;
    T_air_K = T_air + 273.15;
    
    P_rad = sigma_sb * epsilon * surface_area * (T_cond_K^4 - T_air_K^4);
end

function P_solar = solar_gain(Q_solar, alpha, D_outer, L)
% Solar heat gain on the projected area of the conductor
    projected_area = D_outer * L;
    P_solar = Q_solar * alpha * projected_area;
end

