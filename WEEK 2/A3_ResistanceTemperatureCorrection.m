function R_T = A3_ResistanceTemperatureCorrection(R_20, alpha, T, T_ref)
% =========================================================================
% FUNCTION: correctResistanceForTemp
% =========================================================================
% Description:
% Adjusts the electrical resistance of a conductor based on its operating
% temperature using the linear approximation formula. This function is used
% for both the DC and AC base resistances.
%
% (This function requires no changes)
% =========================================================================

R_T = R_20 * (1 + alpha * (T - T_ref));

end

