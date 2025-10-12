function [I_max, R_Tmat, T_surface, P_diss_max] = E2_MaximumCurrent(R_20, alpha, T_mat, T_ref, envParams, lineLength, r_inner, r_outer)
% =========================================================================
% FUNCTION: E2_MaximumCurrent (V5 - Reporting)
% =========================================================================
% MODIFIED: Now returns key intermediate values for the final report.
% =========================================================================

% 1. Calculate the conductor's resistance at its maximum temperature
R_Tmat = E3_ResistanceTemperatureCorrection(R_20, alpha, T_mat, T_ref);

% 2. Find the cable's surface temperature when the conductor is at T_mat
options = optimset('Display','off');
% Thermal resistance of the insulation layer
if r_outer <= r_inner
    R_thermal_ins = inf;
else
    R_thermal_ins = log(r_outer / r_inner) / (2 * pi * envParams.k_insulator * lineLength);
end

% Balance equation: heat through insulation = heat dissipated from surface
balance_eq = @(T_s) (T_mat - T_s) / R_thermal_ins - E7_HeatDissipation(T_s, envParams, r_outer, lineLength);
try
    T_surface = fzero(balance_eq, T_mat, options);
catch
    T_surface = T_mat; % If solver fails, assume no temp drop across insulation
end

% 3. Calculate total heat dissipation from the surface at this temperature
P_diss_max = E7_HeatDissipation(T_surface, envParams, r_outer, lineLength);

% 4. Solve for I_max from the heat balance equation: P_gen = P_diss_max
if R_Tmat <= 0
    I_max = inf;
else
    I_max = sqrt(P_diss_max / R_Tmat);
end

end

