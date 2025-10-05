function deltaU = B2_calculateExactVoltageDrop(lineType, d, I, r, xL, cos_phi)
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

% Apply the full Blondel formula
deltaU = phase_factor * d * I * (r * cos_phi + xL * sin_phi);

end
