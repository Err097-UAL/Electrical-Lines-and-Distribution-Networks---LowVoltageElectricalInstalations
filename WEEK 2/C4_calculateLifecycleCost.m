function [total_cost, cable_cost, loss_cost] = C4_calculateLifecycleCost(section_data, lineType, d, I, cos_phi, sigma, years, hours_per_year, cost_per_kWh)
% =========================================================================
% FUNCTION: calculateLifecycleCost
% =========================================================================
% Description:
% Calculates the total lifecycle cost of using a specific conductor size.
% This cost is the sum of the initial purchase cost of the cable and the
% cumulative cost of energy lost due to its resistance over a period.
%
% Inputs:
%   section_data   - A struct containing .section, .cost_per_meter
%   lineType       - 'single-phase' or 'three-phase'
%   d              - Line length [m]
%   I              - Load current [A]
%   cos_phi        - Power factor
%   sigma          - Material conductivity [S*m/mm^2]
%   years          - Number of years for the analysis
%   hours_per_year - Operating hours per year
%   cost_per_kWh   - Cost of electricity [currency/kWh]
%
% Outputs:
%   total_cost     - Total lifecycle cost
%   cable_cost     - Initial purchase cost of the cable
%   loss_cost      - Total cost of energy losses over the period
% =========================================================================

s = section_data.section;
cost_per_meter = section_data.cost_per_meter;

% --- 1. Calculate Initial Cable Cost ---
% For 3-phase, we need 3 conductors; for single-phase, 2 (phase + neutral)
if strcmp(lineType, 'three-phase')
    num_conductors = 3;
else
    num_conductors = 2;
end
cable_cost = d * cost_per_meter * num_conductors;


% --- 2. Calculate Cost of Energy Losses ---
% Resistance R = (1/sigma) * L/s
% Note: The formula for power loss is N * I^2 * R, where N is the number
% of current-carrying conductors.
total_resistance = (1/sigma) * d / s;
power_loss_watts = num_conductors * (I^2) * total_resistance;

% Convert power loss to kWh over the entire period
total_energy_loss_kWh = (power_loss_watts / 1000) * hours_per_year * years;

% Calculate the total cost of these losses
loss_cost = total_energy_loss_kWh * cost_per_kWh;


% --- 3. Calculate Total Lifecycle Cost ---
total_cost = cable_cost + loss_cost;

end
