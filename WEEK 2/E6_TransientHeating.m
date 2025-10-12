function [time, temp] = E6_TransientHeating(I, time_span, envParams, R_20, alpha, T_ref, length, r_inner, r_outer, mass, cp)
% =========================================================================
% FUNCTION: A6_TransientHeating (V5 - FIXED)
% =========================================================================
% Description:
% Models the temperature of a conductor over time.
% FIXED: The call to the heat dissipation function has been corrected from
% the erroneous 'A7_HeatGain' to the correct 'A7_HeatDissipation'.
%
% ODE: m*cp*(dT/dt) = P_generated(T) - P_dissipated(T)
% =========================================================================

    % Define the ODE as a nested function for the solver
    function dTdt = heat_balance_ode(~, T)
        % 1. Heat Generation at current temperature T
        R_T = E3_ResistanceTemperatureCorrection(R_20, alpha, T, T_ref);
        P_generated = R_T * I^2;

        % 2. Heat Dissipation at current temperature T
        % FIXED: Corrected function call from A7_HeatGain to A7_HeatDissipation
        P_dissipated = E7_HeatDissipation(T, envParams, r_outer, length);

        % 3. Rate of change of internal energy (dT/dt)
        dTdt = (P_generated - P_dissipated) / (mass * cp);
    end

% Use MATLAB's ODE solver (ode45)
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
% The initial temperature for the simulation is the ambient temperature
[time, temp] = ode45(@heat_balance_ode, time_span, envParams.T_env, options);

end

