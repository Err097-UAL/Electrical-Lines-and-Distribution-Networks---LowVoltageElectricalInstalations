function R_T = A3_ResistanceTemperatureCorrection(R_20, alpha, T, T_ref)
% =========================================================================
% FUNCTION: correctResistanceForTemp
% =========================================================================
% Description:
% Adjusts the electrical resistance of a conductor based on its operating
% temperature using the linear approximation formula.
%
% Formula:
%   R_T = R_20 * (1 + alpha * (T - T_ref))
%
% Inputs:
%   R_20  - Resistance at the reference temperature (T_ref) [Ohm]
%   alpha - Temperature coefficient of resistance [1/°C]
%   T     - The new operating temperature [°C]
%   T_ref - The reference temperature (typically 20°C) [°C]
%
% Output:
%   R_T   - The corrected resistance at temperature T [Ohm]
% =========================================================================

R_T = R_20 * (1 + alpha * (T - T_ref));

end
