function T_eq = E4_ThermalEquilibrium(I, R_20, alpha, T_ref, envParams, length, r_inner, r_outer)
% =========================================================================
% FUNCTION: E4_ThermalEquilibrium (V5 - CORRECTED)
% =========================================================================
% Description:
% Calculates the equilibrium conductor temperature (T_eq) for a given current.
%
% MODIFIED (V5):
% Fixed a critical bug where the dissipation function was incorrectly
% called with the *conductor temperature* instead of the *surface
% temperature*. This new version correctly models the temperature drop
% across the insulation.
% =========================================================================

% 1. Calculate the thermal resistance of the insulation layer
% (This logic is mirrored from E2_MaximumCurrent)
if r_outer <= r_inner
    R_thermal_ins = inf; % No insulation, effectively no temp drop
else
    R_thermal_ins = log(r_outer / r_inner) / (2 * pi * envParams.k_insulator * length);
end

% 2. Use a numerical solver to find the root of the heat balance equation.
% We search for the conductor temperature T_cond that satisfies the balance
try
    options = optimset('Display','off'); % Suppress solver output
    T_eq = fzero(@heat_balance_error, [envParams.T_env, envParams.T_env + 500], options);
catch
    T_eq = NaN; % Solver failed
    warning('E4_ThermalEquilibrium: Solver failed to find a solution.');
end

% --- Nested Function for Heat Balance ---
% fzero will find T_cond where heat_balance_error(T_cond) = 0
function error = heat_balance_error(T_cond)
    % 1. Calculate Heat Generation at the conductor temp (T_cond)
    R_T = E3_ResistanceTemperatureCorrection(R_20, alpha, T_cond, T_ref);
    P_gen = R_T * I^2;

    % 2. Calculate the corresponding Surface Temperature (T_surface)
    % We assume P_gen = P_conducted_through_insulation
    % P_gen = (T_cond - T_surface) / R_thermal_ins
    % So, T_surface = T_cond - (P_gen * R_thermal_ins)
    T_surface = T_cond - (P_gen * R_thermal_ins);

    % 3. Calculate Heat Dissipation from the surface temp (T_surface)
    P_diss = E7_HeatDissipation(T_surface, envParams, r_outer, length);

    % 4. The error is the difference. Solver finds where error = 0.
    error = P_gen - P_diss;
end
% --- End of Nested Function ---

end