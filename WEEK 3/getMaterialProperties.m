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
%   props        - A struct with fields like .name, .sigma, .resistivity
% =========================================================================

switch lower(materialName)
    case 'copper'
        props.name = 'Copper';
        props.sigma = 56; % Conductivity [S*m/mm^2]
        props.resistivity = 1/props.sigma; % Resistivity [Ohm*mm^2/m]
        % Other properties like density could be added here in the future
        
    case 'aluminum'
        props.name = 'Aluminum';
        props.sigma = 36; % Conductivity [S*m/mm^2]
        props.resistivity = 1/props.sigma; % Resistivity [Ohm*mm^2/m]
        
    otherwise
        error('Unknown material specified: %s. Please check getMaterialProperties.m', materialName);
end

end
