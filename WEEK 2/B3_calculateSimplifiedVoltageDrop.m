function deltaU_simple = B3_calculateSimplifiedVoltageDrop(lineType, d, I, r, cos_phi)
% =========================================================================
% FUNCTION: calculateSimplifiedVoltageDrop
% =========================================================================
% Description:
% Computes the voltage drop using a simplified formula that only considers
% the resistive component of the line. This is a common approximation for
% circuits with high power factors or where reactance is negligible.
%
% Formulas:
% Single-phase: ∆U ≈ 2 * d * I * r * cos(φ)
% Three-phase:  ∆U ≈ sqrt(3) * d * I * r * cos(φ)
%
% Inputs:
%   lineType - String: 'single-phase' or 'three-phase'
%   d        - Total line length [m]
%   I        - Load current [A]
%   r        - Resistance per unit length [Ohm/m]
%   cos_phi  - Power factor of the load
%
% Output:
%   deltaU_simple - The simplified voltage drop [V]
% =========================================================================

% Determine the phase factor based on the line type
switch lineType
    case 'single-phase'
        phase_factor = 2;
    case 'three-phase'
        phase_factor = sqrt(3);
    otherwise
        error('Invalid lineType specified. Use ''single-phase'' or ''three-phase''.');
end

% Apply the simplified (resistive only) formula
deltaU_simple = phase_factor * d * I * r * cos_phi;

end
