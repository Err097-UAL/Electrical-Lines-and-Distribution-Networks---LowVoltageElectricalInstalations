function I_max = A2_MaximumCurrent(R_20, alpha, T_mat, T_ref, T_env, k, length, r_inner, r_outer)
% =========================================================================
% FUNCTION: calculateMaxCurrent (V3)
% =========================================================================
% Description:
% Calculates the maximum allowable current by solving the heat balance equation.
% UPDATED: Now uses the precise logarithmic conduction formula for a hollow cylinder.
%
% Heat Balance: P_generated = P_dissipated
% R_Tmat*I_max^2 = (2*pi*k*L*(T_mat-T_env)) / log(r_outer/r_inner)
%
% Inputs:
%   ... (standard inputs) ...
%   r_inner  - Conductor (inner) radius [m]
%   r_outer  - Outer insulation radius [m]
% =========================================================================

% 1. Calculate resistance at maximum temperature
R_Tmat = A3_ResistanceTemperatureCorrection(R_20, alpha, T_mat, T_ref);

% 2. Calculate heat dissipation using the logarithmic formula for a cylinder
% UPDATED: Replaced linear approximation with precise formula.
if r_outer <= r_inner
    error('Outer radius must be greater than inner radius.');
end
P_dissipated = (2 * pi * k * length * (T_mat - T_env)) / log(r_outer / r_inner);

% 3. Solve for I_max from the heat balance equation
if R_Tmat <= 0
    error('Resistance at max temperature must be positive.');
end
I_max = sqrt(P_dissipated / R_Tmat);

end

