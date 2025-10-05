function T_eq = A4_ThermalEquilibrium(I, R_20, alpha, T_ref, T_env, k, length, r_inner, r_outer)
% =========================================================================
% FUNCTION: solveThermalEquilibrium (V3)
% =========================================================================
% Description:
% Calculates the steady-state equilibrium temperature of a conductor.
% UPDATED: Now uses the precise logarithmic conduction model.
%
% Inputs:
%   ... (standard inputs) ...
%   r_inner  - Conductor (inner) radius [m]
%   r_outer  - Outer insulation radius [m]
% =========================================================================

% UPDATED: Effective thermal conductance using logarithmic formula
if r_outer <= r_inner
    error('Outer radius must be greater than inner radius.');
end
K_eff = (2 * pi * k * length) / log(r_outer / r_inner); % [W/°C]

% Rearrange the heat balance equation to solve for T_eq:
% R_T * I^2 = K_eff * (T_eq - T_env)
numerator = R_20 * I^2 * (1 - alpha * T_ref) + K_eff * T_env;
denominator = K_eff - R_20 * I^2 * alpha;

if denominator <= 0
    % Thermal runaway condition
    T_eq = inf;
else
    T_eq = numerator / denominator;
end

end

