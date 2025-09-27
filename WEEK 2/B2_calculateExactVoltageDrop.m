function deltaU = calculateExactVoltageDrop(lineType, d, I, r, xL, cos_phi)
% =========================================================================
% FUNCTION: calculateExactVoltageDrop
% =========================================================================
% Description:
% Computes the voltage drop using the full Blondel formula, which accounts
% for both resistive and reactive components of the line impedance.
%
% Formulas:
% Single-phase: ∆U = 2 * d * I * (r * cos(φ) + xL * sin(φ))
% Three-phase:  ∆U = sqrt(3) * d * I * (r * cos(φ) + xL * sin(φ))
%
% Inputs:
%   lineType - String: 'single-phase' or 'three-phase'
%   d        - Total line length [m]
%   I        - Load current [A]
%   r        - Resistance per unit length [Ohm/m]
%   xL       - Reactance per unit length [Ohm/m]
%   cos_phi  - Power factor of the load
%
% Output:
%   deltaU   - The total voltage drop along the line [V]
% =========================================================================

% Calculate sin(φ) from cos(φ). Assuming a lagging power factor.
sin_phi = sqrt(1 - cos_phi^2);

% Determine the phase factor based on the line type
switch lineType
    case 'single-phase'
        phase_factor = 2;
    case 'three-phase'
        phase_factor = sqrt(3);
    otherwise
        error('Invalid lineType specified. Use ''single-phase'' or ''three-phase''.');
end

% Apply the Blondel formula
deltaU = phase_factor * d * I * (r * cos_phi + xL * sin_phi);

end
