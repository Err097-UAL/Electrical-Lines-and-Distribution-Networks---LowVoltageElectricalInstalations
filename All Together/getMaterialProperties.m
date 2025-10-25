function props = getMaterialProperties(materialName)
% =========================================================================
% FUNCTION: getMaterialProperties
% =========================================================================
% Description:
% Acts as a central database for material properties. Given a material
% name, it returns a struct containing its physical constants.
%
% Input:
%   materialName - String ('Copper', 'Aluminum', etc.)
%
% Output:
%   props        - A struct with fields like .name, .conductivity, .resistivity
% =========================================================================
switch lower(materialName)
    case 'copper'
        props.name = 'Copper';
        props.conductivity = 56; % Conductivity [S*m/mm^2]
        props.resistivity = 1/props.conductivity; % Resistivity [Ohm*mm^2/m]
        
    case 'aluminum'
        props.name = 'Aluminum';
        props.conductivity = 36; % Conductivity [S*m/mm^2]
        props.resistivity = 1/props.conductivity; % Resistivity [Ohm*mm^2/m]
        
    otherwise
        error('Unknown material specified: %s. Please check getMaterialProperties.m', materialName);
end
end