function deltaU_simple = B3_calculateSimplifiedVoltageDrop(lineType, d, I, r, cos_phi)
% =========================================================================
% FUNCTION: calculateSimplifiedVoltageDrop
% =========================================================================
% Description:
% Computes the voltage drop using a simplified formula that only considers
% the resistive component of the line.
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
