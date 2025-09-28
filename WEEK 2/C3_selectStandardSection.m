function [selected_section, ampacity, standard_sections_data] = C3_selectStandardSection(s_required, material)
% =========================================================================
% FUNCTION: selectStandardSection
% =========================================================================
% Description:
% Takes a calculated (theoretical) cross-sectional area and selects the
% next largest standardized cable size from a predefined table. It also
% returns the current-carrying capacity (ampacity) for that section.
%
% Note: The ampacity and cost data below is illustrative. Real-world values
% depend on installation method, temperature, and manufacturer.
%
% Inputs:
%   s_required - The minimum required cross-sectional area [mm^2]
%   material   - String: 'Copper' or 'Aluminum'
%
% Outputs:
%   selected_section     - The chosen standard section [mm^2]
%   ampacity             - The ampacity of the chosen section [A]
%   standard_sections_data - The full data table used for the lookup
% =========================================================================

% Define standard sections, ampacities, and illustrative costs
% Data is structured as: [Section (mm^2), Ampacity (A), Cost per meter (currency/m)]
if strcmpi(material, 'Copper')
    % Section, Ampacity (PVC, buried), Cost/m
    data = [
        1.5,   24,    0.5;
        2.5,   32,    0.8;
        4,     42,    1.2;
        6,     54,    1.7;
        10,    73,    2.8;
        16,    98,    4.5;
        25,    129,   7.0;
        35,    158,   9.5;
        50,    188,   13.0;
        70,    232,   18.0;
        95,    275,   24.0;
        120,   315,   30.0;
    ];
else % Aluminum
    % Section, Ampacity (PVC, buried), Cost/m
    data = [
        16,    76,    3.0;
        25,    100,   4.5;
        35,    123,   6.0;
        50,    146,   8.0;
        70,    180,   11.5;
        95,    214,   15.5;
        120,   245,   19.5;
    ];
end

% Create a structure for easier data access
standard_sections_data = struct('section', num2cell(data(:,1)), ...
                                'ampacity', num2cell(data(:,2)), ...
                                'cost_per_meter', num2cell(data(:,3)));

% Find the first standard section that is >= the required section
idx = find([standard_sections_data.section] >= s_required, 1, 'first');

% Handle case where required section is larger than any standard size
if isempty(idx)
    error('Required section (%.2f mm^2) is larger than the largest available standard size.', s_required);
end

% Extract the details of the selected section
selected_section = standard_sections_data(idx).section;
ampacity = standard_sections_data(idx).ampacity;

end
