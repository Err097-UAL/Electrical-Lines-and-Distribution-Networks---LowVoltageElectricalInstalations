function k_g = E8_GroupingFactor(num_cables)
% =========================================================================
% FUNCTION: A8_GroupingFactor (NEW)
% =========================================================================
% Description:
% Provides a simplified derating factor for grouped cables in a building
% installation. These values are illustrative and based on tables found
% in standards like the NEC or IEC for multicore cables or groups of
% single-core cables in a tray, touching.
%
% Input:
%   num_cables - The total number of current-carrying conductors in the group.
%
% Output:
%   k_g        - The derating factor (0 to 1).
% =========================================================================

if num_cables <= 1
    k_g = 1.0;
elseif num_cables <= 3
    k_g = 0.80; % Common value for a 3-phase circuit in conduit
elseif num_cables <= 6
    k_g = 0.70;
elseif num_cables <= 9
    k_g = 0.60;
elseif num_cables <= 20
    k_g = 0.50;
else % for more than 20 cables
    k_g = 0.45;
end

end
