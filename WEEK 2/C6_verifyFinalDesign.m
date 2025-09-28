function final_vd_percent = C6_verifyFinalDesign(lineType, d, I, cos_phi, sigma, s_final, U_source)
% =========================================================================
% FUNCTION: verifyFinalDesign
% =========================================================================
% Description:
% After a standard cross-section has been selected, this function performs
% a final calculation to verify the actual voltage drop using that section.
% It recalculates the voltage drop based on the chosen section's area.
% This is important because the standard section is usually larger than
% the theoretically required minimum.
%
% Inputs:
%   lineType - String: 'single-phase' or 'three-phase'
%   d        - Total line length [m]
%   I        - Load current [A]
%   cos_phi  - Power factor
%   sigma    - Material conductivity [S*m/mm^2]
%   s_final  - The final, standard cross-section to be verified [mm^2]
%   U_source - The source voltage [V]
%
% Output:
%   final_vd_percent - The final, actual voltage drop percentage [%]
% =========================================================================

% The formula for voltage drop is ∆U = (PhaseFactor * d * I * cos(φ)) / (σ * s)
% This is a rearrangement of the cross-section formula.

% Determine the phase factor
switch lineType
    case 'single-phase'
        phase_factor = 2;
    case 'three-phase'
        phase_factor = sqrt(3);
    otherwise
        error('Invalid lineType specified.');
end

% Calculate the voltage drop in Volts
numerator = phase_factor * d * I * cos_phi;
denominator = sigma * s_final;

if denominator == 0
    error('Cross-sectional area cannot be zero.');
end

final_vd_volts = numerator / denominator;

% Convert the voltage drop to a percentage of the source voltage
final_vd_percent = (final_vd_volts / U_source) * 100;

end
