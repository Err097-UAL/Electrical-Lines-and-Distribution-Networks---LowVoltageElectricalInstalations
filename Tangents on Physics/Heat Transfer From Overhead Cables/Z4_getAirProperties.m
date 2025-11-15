function air = Z4_getAirProperties(T_celsius)
% -------------------------------------------------------------------------
% air = Z4_getAirProperties(T_celsius)
% -------------------------------------------------------------------------
% Returns a struct 'air' with properties of air at 1 atm.
% Properties are a function of the film temperature T_celsius (in deg C).
% Data is interpolated from standard tables (e.g., Incropera & DeWitt).
%
% T_K = Temperature in Kelvin
% k   = Thermal conductivity (W/m-K)
% nu  = Kinematic viscosity (m^2/s)
% Pr  = Prandtl number (dimensionless)
% beta= Volumetric thermal expansion (1/K)
% -------------------------------------------------------------------------

% Convert to Kelvin
T_K = T_celsius + 273.15;

% Temperatures for interpolation (deg C)
T_table_C = [  0,   20,   40,   60,   80,  100];
% Kinematic Viscosity (nu * 10^6)
nu_table =  [13.28, 15.11, 16.97, 18.90, 20.92, 23.03];
% Thermal Conductivity (k * 10^3)
k_table =   [24.3,  25.8,  27.4,  28.9,  30.4,  31.9];
% Prandtl Number (Pr)
Pr_table =  [0.713, 0.709, 0.705, 0.701, 0.697, 0.693];

% Use linear interpolation (or extrapolation if out of range)
% 'pchip' is a good shape-preserving interpolant
air.nu = interp1(T_table_C, nu_table, T_celsius, 'pchip', 'extrap') * 1e-6; % (m^2/s)
air.k = interp1(T_table_C, k_table, T_celsius, 'pchip', 'extrap') * 1e-3; % (W/m-K)
air.Pr = interp1(T_table_C, Pr_table, T_celsius, 'pchip', 'extrap'); % (dimless)

% Volumetric thermal expansion (beta = 1/T_film in Kelvin for ideal gas)
air.beta = 1 / T_K; % (1/K)

end