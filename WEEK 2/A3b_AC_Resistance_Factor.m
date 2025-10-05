function [k_skin, k_proximity] = A3b_AC_Resistance_Factor(freq, diameter, sigma)
% =========================================================================
% FUNCTION: calculateACResistanceFactor (V2 - Corrected)
% =========================================================================
% Description:
% Calculates the skin effect (ys or k_skin) and proximity effect (yp or
% k_proximity) factors based on the IEC 60287 standard. These factors are
% used to determine AC resistance from DC resistance.
% R_AC = R_DC * (1 + k_skin + k_proximity)
%
% Inputs:
%   freq     - System frequency [Hz]
%   diameter - Conductor outer diameter [m]
%   sigma    - Electrical conductivity of the material [S*m/mm^2]
%
% Outputs:
%   k_skin      - Skin effect factor (dimensionless)
%   k_proximity - Proximity effect factor (dimensionless)
% =========================================================================

%https://elek.com/articles/skin-and-proximity-effects-on-ac-resistance-calculations/?srsltid=AfmBOooqsLXyq-RP8HYPW10aoOZp7M-i5KNrajposunww0TFV06Qz1iQ

% --- Skin Effect Calculation (Based on IEC 60287-1-1) ---

% 1. Calculate DC resistance per meter [Ohm/m]
cross_section_m2 = pi * (diameter/2)^2; % [m^2]
sigma_Sm = sigma * 1e6; % Convert [S*m/mm^2] to [S/m]
R_dc_per_meter = 1 / (sigma_Sm * cross_section_m2);

% 2. Calculate the skin effect parameter x_s^2
if R_dc_per_meter == 0
    x_s_sq = 0;
else
    x_s_sq = (8 * pi * freq / R_dc_per_meter) * 1e-7;
end

% 3. Calculate the skin effect factor k_skin (also called ys)
k_skin = (x_s_sq^2) / (192 + 0.8 * x_s_sq^2);


% --- Proximity Effect Calculation (Based on IEC 60287-1-1) ---

% 1. The proximity effect parameter x_p^2 is identical to x_s^2
x_p_sq = x_s_sq;

% 2. The proximity factor depends on cable arrangement. The following is a
%    well-established approximation for three single-core cables in trefoil
%    (touching) formation, where center-to-center spacing 's' equals 'diameter'.
%    For this arrangement, (diameter/spacing) = 1.
if x_p_sq == 0
    k_proximity = 0;
else
    k_proximity = (x_p_sq^2 / (192 + 0.8*x_p_sq^2)) * ...
                  ( 0.312 + (1.18 / ((x_p_sq^2 / (192 + 0.8*x_p_sq^2)) + 0.27)) );
end

end

