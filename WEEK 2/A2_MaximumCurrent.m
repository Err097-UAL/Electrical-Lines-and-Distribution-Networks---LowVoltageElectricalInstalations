function I_max = A2_MaximumCurrent(R_20, alpha, T_mat, envParams, length, r_inner, r_outer)
% =========================================================================
% FUNCTION: A2_MaximumCurrent (V4)
% =========================================================================
% Description:
% Calculates the maximum allowable current (ampacity) based on the steady-state
% heat balance at the maximum rated temperature of the conductor.
% MODIFIED: This version calls the A7_HeatDissipation module to handle
%           scenario-specific heat transfer physics.
% =========================================================================

% 1. Calculate the conductor's resistance at its maximum temperature
T_ref = 20; % Reference temperature is constant at 20°C
R_Tmat = A3_ResistanceTemperatureCorrection(R_20, alpha, T_mat, T_ref);

% 2. Calculate the total heat the cable can dissipate at T_mat
P_dissipated = A7_HeatDissipation(T_mat, envParams, r_outer, length);

% 3. From P_generated = P_dissipated, solve for I_max
% P_generated = R_Tmat * I_max^2
if R_Tmat <= 0
    I_max = inf; % Avoid division by zero if resistance is non-positive
else
    I_max = sqrt(P_dissipated / R_Tmat);
end

% 4. (Building Scenario) Apply the grouping factor directly to the current
if strcmp(envParams.scenario, 'building')
    I_max = I_max * envParams.grouping_factor;
end

end

