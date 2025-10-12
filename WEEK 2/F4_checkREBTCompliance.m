function [isCompliant, percentDrop, limit] = F4_checkREBTCompliance(deltaU, U_source, circuitType)
% =========================================================================
% FUNCTION: checkREBTCompliance
% =========================================================================
% Description:
% Checks if the calculated voltage drop complies with the Spanish Low
% Voltage Electrotechnical Regulation (REBT) limits.
%
% REBT Limits: Lighting Circuits: 4.5%, Power (Other Uses): 6.5%
% =========================================================================

% Determine the REBT limit based on the circuit type
switch circuitType
    case 'lighting'
        limit = 4.5;
    case 'power'
        limit = 6.5;
    otherwise
        error('Invalid circuitType. Use ''lighting'' or ''power''.');
end

% Calculate the percentage voltage drop
percentDrop = (deltaU / U_source) * 100;

% Check for compliance
if percentDrop <= limit
    isCompliant = true;
else
    isCompliant = false;
end

end
