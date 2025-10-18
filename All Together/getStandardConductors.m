function conductors = getStandardConductors(materialName)
% =========================================================================
% FUNCTION: Standard Conductor Database
% =========================================================================
% Description:
% This function acts as a database, providing a table of standard,
% commercially available conductor cross-sections for a given material.
% It includes the maximum admissible current (thermal limit) and an
% estimated cost per meter for each section.
%
% This data is essential for the optimization algorithm.
% =========================================================================

if strcmpi(materialName, 'Copper')
    % Data for Copper Conductors (Example values)
    sections_mm2 = [16; 25; 35; 50; 70; 95; 120; 150];
    I_adm_A      = [101; 132; 163; 198; 245; 292; 340; 385]; 
    cost_eur_m   = [1.8; 2.8; 3.9; 5.5; 7.7; 10.5; 13.0; 16.2];

elseif strcmpi(materialName, 'Aluminum')
    % Data for Aluminum Conductors (Example values)
    sections_mm2 = [16; 25; 35; 50; 70; 95; 120; 150];
    I_adm_A      = [78; 102; 125; 151; 187; 223; 260; 295];
    cost_eur_m   = [0.8; 1.3; 1.8; 2.5; 3.5; 4.8; 5.9; 7.4];
else
    error('Unknown material specified. Use "Copper" or "Aluminum".');
end

conductors = table(sections_mm2, I_adm_A, cost_eur_m, ...
    'VariableNames', {'CrossSection', 'MaxCurrent', 'CostPerMeter'});
end

