
%in the main project (week 2), current is calculated as a function
%of the temperature that was imposed by the insulations limits

%we dont clown like that in this mf this the beta release

%here we calculate the temperature as a function of current (power)


% -------------------------------------------------------------------------
% main_cable_simulator.m
% -------------------------------------------------------------------------
% This is the main driver script for the power cable thermal model.
%
% 1. Define all simulation, geometry, and material parameters.
% 2. Define the simulation scenario (current, location, environment).
% 3. Call the core solver function.
% 4. Call the plotting function to visualize results.
% -------------------------------------------------------------------------

clear; close all; clc;

disp('Starting Power Cable Thermal Simulation...');

% -------------------------------------------------------------------------
% 1. USER-DEFINED SCENARIO
% -------------------------------------------------------------------------
% Choose 'underground' or 'overhead'
scenario.location = 'overhead'; % 'underground' or 'overhead'

% Current (Amperes). Set to 0 for a cooling simulation.
scenario.I_rms = 450; % (A)

% Wind Speed (m/s). Used only for 'overhead'.
% v_wind = 0 corresponds to Natural Convection.
% v_wind > 0 corresponds to Forced Convection.
scenario.v_wind = 5.0; % (m/s)

% Ambient Temperature (e.g., air or far-field soil)
scenario.T_ambient = 20; % (deg C)

% Initial Cable Temperature (e.g., ambient or a previous steady-state)
scenario.T_initial = 20; % (deg C)

% Burial Depth (m). Used only for 'underground'.
scenario.burial_depth_z = 1.5; % (m)

% -------------------------------------------------------------------------
% 2. SIMULATION PARAMETERS
% -------------------------------------------------------------------------
% Time vector
sim.t_start = 0;       % (s)
sim.t_end = 5 * 3600;  % (s) - e.g., 5 hours
sim.t_steps = 500;     % Number of time steps
sim.t_vector = linspace(sim.t_start, sim.t_end, sim.t_steps);

% Radial vectors for profile plotting
sim.r_steps = 50;      % Number of radial points in insulation
sim.r_soil_steps = 100; % Number of radial points in soil

% Time points of interest for plotting profiles (e.g., start, mid, end)
sim.profile_times_idx = [1, round(sim.t_steps/2), sim.t_steps];
sim.profile_times_sec = sim.t_vector(sim.profile_times_idx);

% -------------------------------------------------------------------------
% 3. CABLE GEOMETRY & MATERIAL PROPERTIES
% -------------------------------------------------------------------------
% --- Geometry ---
% Conductor (e.g., 500 kcmil Copper)
params.conductor.r1 = 0.0115; % Conductor radius (m)

% Insulation (e.g., XLPE)
params.conductor.r2 = 0.0178; % Outer insulation radius (m)

% Cable Length (for resistance calculation)
params.L = 1.0; % (m) - Model is per-unit-length

% --- Material Properties ---
% Conductor (Copper)
params.conductor.rho_c = 8960;    % Density (kg/m^3)
params.conductor.cp_c = 385;      % Specific heat (J/kg-K)
params.conductor.res_ref = 3.6e-5;% Electrical resistance at T_ref (Ohm/m)
params.conductor.T_ref = 20;      % Reference temperature for resistance (deg C)
params.conductor.alpha_T = 0.0039;% Temp. coefficient of resistance (1/K)

% Insulation (XLPE)
params.insulation.rho_ins = 920;    % Density (kg/m^3)
params.insulation.cp_ins = 2300;   % Specific heat (J/kg-K)
params.insulation.k_ins = 0.28;   % Thermal conductivity (W/m-K)

% Environment (Soil) - Used only if scenario.location = 'underground'
params.soil.k_soil = 0.9; % Thermal conductivity (W/m-K)

% -------------------------------------------------------------------------
% 4. DERIVED GEOMETRIC & THERMAL PARAMETERS
% -------------------------------------------------------------------------
% --- Geometry ---
params.D_outer = 2 * params.conductor.r2; % Cable outer diameter (m)
params.A_s = params.D_outer * pi * params.L; % Cable surface area (m^2)

% --- Mass & Corrected Thermal Capacitance ---
vol_c = pi * params.conductor.r1^2 * params.L;
vol_ins = pi * (params.conductor.r2^2 - params.conductor.r1^2) * params.L;

m_c = params.conductor.rho_c * vol_c;
m_ins = params.insulation.rho_ins * vol_ins;

% Corrected Thermal Capacitance (C_th,corrected)
params.C_th_corrected = (m_c * params.conductor.cp_c) + 0.5 * (m_ins * params.insulation.cp_ins); % (J/K)

% --- Fixed Thermal Resistance (Insulation) ---
params.R_ins = log(params.conductor.r2 / params.conductor.r1) / (2 * pi * params.insulation.k_ins * params.L); % (K/W)

% --- Heat Generation (P_gen) ---
% NOTE: We calculate P_gen based on T_ref.
% A more complex model would solve a non-linear ODE where R_elec changes
% with T_A(t). We are following the provided model which assumes a
% constant P_gen, leading to a simple first-order analytical solution.
params.R_elec = params.conductor.res_ref * (1 + params.conductor.alpha_T * (scenario.T_ambient - params.conductor.T_ref));
params.P_gen = scenario.I_rms^2 * params.R_elec; % (W)

% Check for cooling scenario
if scenario.I_rms == 0
    params.P_gen = 0;
    disp('Current is 0. Running a COOLING simulation.');
else
    disp(['Current is ' num2str(scenario.I_rms) ' A. Running a HEATING simulation.']);
end

% -------------------------------------------------------------------------
% 5. SOLVE & PLOT
% -------------------------------------------------------------------------

% Call the core solver
try
    results = solveCableTemperature(scenario, params, sim);
    
    % If solver is successful, plot the results
    disp('Simulation complete. Generating plots...');
    plotResults(results);
    disp('Plots generated successfully.');
    
catch ME
    % Catch and display any errors from the solver
    disp('------------------------------------');
    disp('ERROR during simulation:');
    disp(ME.message);
    disp('------------------------------------');
end