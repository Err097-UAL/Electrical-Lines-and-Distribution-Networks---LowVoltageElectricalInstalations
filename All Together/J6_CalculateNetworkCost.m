function [total_cost, cable_cost, loss_cost] = J6_CalculateNetworkCost(type, L_total, Ia, Ib, loads, conductivity, s, cost_per_meter)
% =========================================================================
% FUNCTION: Calculate Network Lifecycle Cost (V4 - Sigma Fix)
% =========================================================================
% MODIFIED:
% - Replaced the argument 'sigma' with 'conductivity' to match the corrected
%   calling functions and avoid MATLAB built-in function conflicts.
% =========================================================================
% --- Economic Constants ---
LCC_years = 20;
hours_per_year = 4000;
cost_per_kWh = 0.15;

% --- 1. Calculate Initial Cable Cost ---
if strcmp(type, 'ring')
    cable_length = L_total;
else % radial
    cable_length = loads(end).distance;
end
cable_cost = cable_length * cost_per_meter;

% --- 2. Calculate Cost of Energy Losses ---
total_power_loss_watts = 0;
if strcmp(type, 'ring')
    % Path A (clockwise)
    I_seg_A = Ia;
    nodes_A = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_A)
        seg_len = nodes_A(i).distance - nodes_A(i-1).distance;
        R_seg = (1/(conductivity*s)) * seg_len;
        total_power_loss_watts = total_power_loss_watts + I_seg_A^2 * R_seg;
        I_seg_A = I_seg_A - nodes_A(i).current;
    end
    % Path B (anti-clockwise)
    I_seg_B = Ib;
    loads_rev = sortrows(struct2table(loads), 'distance', 'descend');
    nodes_B = [struct('distance', L_total, 'current', 0); table2struct(loads_rev)];
     for i = 2:length(nodes_B)
        seg_len = nodes_B(i-1).distance - nodes_B(i).distance;
        R_seg = (1/(conductivity*s)) * seg_len;
        total_power_loss_watts = total_power_loss_watts + I_seg_B^2 * R_seg;
        I_seg_B = I_seg_B - nodes_B(i).current;
    end
else % radial
    I_seg = Ia; % Ia is total current for radial
    nodes_rad = [struct('distance', 0, 'current', 0); loads];
    for i = 2:length(nodes_rad)
        seg_len = nodes_rad(i).distance - nodes_rad(i-1).distance;
        R_seg = (1/(conductivity*s)) * seg_len;
        total_power_loss_watts = total_power_loss_watts + I_seg^2 * R_seg;
        I_seg = I_seg - nodes_rad(i).current;
    end
end

total_loss_kWh_lifecycle = (total_power_loss_watts / 1000) * hours_per_year * LCC_years;
loss_cost = total_loss_kWh_lifecycle * cost_per_kWh;

% --- 3. Calculate Total Lifecycle Cost ---
total_cost = cable_cost + loss_cost;
end

