function s = C2_calculateRequiredSection(lineType, d, I, cos_phi, sigma, deltaU_max)
% =========================================================================
% FUNCTION: calculateRequiredSection
% =========================================================================
% Description:
% Calculates the minimum theoretical cross-sectional area (s) of a conductor
% required to keep the voltage drop within a specified maximum limit.
%
% Formulas:
% Single-phase: s = (2 * d * I * cos(φ)) / (σ * ∆U_max)
% Three-phase:  s = (sqrt(3) * d * I * cos(φ)) / (σ * ∆U_max)
%
% Inputs:
%   lineType   - String: 'single-phase' or 'three-phase'
%   d          - Total line length [m]
%   I          - Load current [A]
%   cos_phi    - Power factor of the load
%   sigma      - Conductivity of the material [S*m/mm^2]
%   deltaU_max - Maximum allowable voltage drop [V]
%
% Output:
%   s          - Required cross-sectional area [mm^2]
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

% Calculate the required cross-section using the formula
numerator = phase_factor * d * I * cos_phi;
denominator = sigma * deltaU_max;

if denominator == 0
    error('Maximum allowable voltage drop cannot be zero.');
end

s = numerator / denominator;

end
