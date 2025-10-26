function [time, temp] = E6_TransientHeating(I, time_span, envParams, R_20, alpha, T_ref, length, r_inner, r_outer, mass, cp)
% =========================================================================
% FUNCTION: A6_TransientHeating (V6 - CORRECTED)
% =========================================================================
% Description:
% Models the temperature of a conductor over time.
%
% MODIFIED (V6):
% Fixed a critical bug where the dissipation function was incorrectly
% called with the *conductor temperature* instead of the *surface
% temperature*. This new version correctly models the temperature drop
% across the insulation.
%
% ODE: m*cp*(dT/dt) = P_generated(T_cond) - P_dissipated(T_surface)
% =========================================================================

% 1. Calculate the thermal resistance of the insulation layer
if r_outer <= r_inner
    R_thermal_ins = inf; % No insulation, effectively no temp drop
else
    R_thermal_ins = log(r_outer / r_inner) / (2 * pi * envParams.k_insulator * length);
end

% 2. Use MATLAB's ODE solver (ode45)
% Start the simulation at the ambient environment temperature
options = odeset('RelTol',1e-6, 'AbsTol',1e-6);
[time, temp] = ode45(@heat_balance_ode, time_span, envParams.T_env, options);

% --- Nested Function for the ODE Solver ---
% The solver provides 'T_cond' (the conductor temperature) at each time step
function dTdt = heat_balance_ode(~, T_cond)
    % 1. Heat Generation at current conductor temperature T_cond
    R_T = E3_ResistanceTemperatureCorrection(R_20, alpha, T_cond, T_ref);
    P_generated = R_T * I^2;

    % 2. Calculate the corresponding Surface Temperature (T_surface)
    % We assume P_generated = P_conducted_through_insulation
    % P_generated = (T_cond - T_surface) / R_thermal_ins
    % So, T_surface = T_cond - (P_generated * R_thermal_ins)
    T_surface = T_cond - (P_generated * R_thermal_ins);

    % 3. Heat Dissipation from the surface temp (T_surface)
    P_dissipated = E7_HeatDissipation(T_surface, envParams, r_outer, length);

    % 4. Rate of change of internal energy (dT/dt)
    dTdt = (P_generated - P_dissipated) / (mass * cp);
end
% --- End of Nested Function ---

end