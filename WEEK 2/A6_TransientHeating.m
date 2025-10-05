function [time, temp] = A6_TransientHeating(I, time_span, T_initial, R_20, alpha, T_ref, k, length, r_inner, r_outer, mass, cp)
% =========================================================================
% FUNCTION: solveTransientHeating (V3)
% =========================================================================
% Description:
% Models the temperature of a conductor over time by solving the ODE.
% UPDATED: Now uses the precise logarithmic conduction formula.
%
% ODE: m*cp*(dT/dt) = P_generated(T) - P_dissipated(T)
%
% Inputs:
%   ... (standard inputs) ...
%   r_inner - Conductor (inner) radius [m]
%   r_outer - Outer insulation radius [m]
% =========================================================================

% Define the ODE as a nested function
    function dTdt = heat_balance_ode(~, T)
        % 1. Heat Generation at current temperature T
        R_T = A3_ResistanceTemperatureCorrection(R_20, alpha, T, T_ref);
        P_generated = R_T * I^2;

        % 2. Heat Dissipation at current temperature T
        % UPDATED: Switched to logarithmic formula for cylinder
        if r_outer <= r_inner
            P_dissipated = 0; % Avoid log of non-positive number
        else
            P_dissipated = (2 * pi * k * length * (T - T_initial)) / log(r_outer / r_inner);
        end

        % 3. Rate of change of internal energy
        dTdt = (P_generated - P_dissipated) / (mass * cp);
    end

% Use MATLAB's ODE solver
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[time, temp] = ode45(@heat_balance_ode, time_span, T_initial, options);

end

