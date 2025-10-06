function T_eq = A4_ThermalEquilibrium(I, R_20, alpha, T_ref, envParams, length, r_inner, r_outer)
% =========================================================================
% FUNCTION: A4_ThermalEquilibrium (V4)
% =========================================================================
% Description:
% Calculates the equilibrium temperature (T_eq) of a conductor for a given
% current by iteratively finding the temperature at which heat generation
% equals heat dissipation.
% MODIFIED: This version now uses the A7_HeatDissipation module and an
%           iterative solver, which is more robust for complex non-linear
%           dissipation models (like radiation).
% =========================================================================

% Define an anonymous function for the heat balance error
% We want to find the temperature T where Error(T) = 0
% Error(T) = P_generated(T) - P_dissipated(T)
heat_balance_error = @(T) ...
    (A3_ResistanceTemperatureCorrection(R_20, alpha, T, T_ref) * I^2) - ...
    (A7_HeatDissipation(T, envParams, r_outer, length));

% Use a numerical solver to find the root of the heat balance equation.
% fzero is efficient for finding where a function is zero.
% We provide an initial guess [T_env, T_env + 200] to search for the root.
try
    options = optimset('Display','off'); % Suppress solver output
    T_eq = fzero(heat_balance_error, [envParams.T_env, envParams.T_env + 500], options);
catch
    % If the solver fails (e.g., current is too high to ever stabilize),
    % return a flag value like NaN (Not a Number).
    T_eq = NaN;
end

end
