% -------------------------------------------------------------------------
% Z1_Iterative_Heat_Transfer_Main.m
% -------------------------------------------------------------------------
% This is the main driver script for the power cable thermal model.
%
% 1. Gathers all parameters from the user via interactive prompts.
% 2. Sets material properties based on user selection.
% 3. Calculates derived parameters (including electrical resistance).
% 4. Calls the core solver function.
% 5. Calls the plotting function to visualize results.
% -------------------------------------------------------------------------

clear; close all; clc;

disp('Starting Power Cable Thermal Simulation...');
disp('Please provide the following parameters:');
disp('------------------------------------------');

% -------------------------------------------------------------------------
% 1. USER INPUTS (Gathering Data)
% -------------------------------------------------------------------------

% --- Scenario Inputs ---
location_choice = '';
while ~strcmpi(location_choice, 'overhead') && ~strcmpi(location_choice, 'underground')
    location_choice = input('Enter case scenario (overhead/underground): ', 's');
end
scenario.location = lower(location_choice);

scenario.T_ambient = input('Enter ambient temperature (e.g., 20 C): ');

% --- Environmental Inputs (Conditional) ---
if strcmpi(scenario.location, 'overhead')
    scenario.v_wind = input('Enter wind speed (m/s) (0 for natural convection): ');
    % Set dummy values for non-applicable parameters
    scenario.burial_depth_z = 1.0; % (m) - Not used
    params.soil.k_soil = 1.0; % (W/m-K) - Not used
else % underground
    scenario.burial_depth_z = input('Enter burial depth (m): ');
    rho_soil = input('Enter soil thermal resistivity (K-m/W) (e.g., 1.5): ');
    params.soil.k_soil = 1 / rho_soil; % Convert resistivity to conductivity
    % Set dummy values for non-applicable parameters
    scenario.v_wind = 0; % (m/s) - Not used
end

% --- Simulation & Line Inputs ---
t_end_minutes = input('Enter simulation time (minutes): ');
sim.t_end = t_end_minutes * 60; % (s)
params.L = input('Enter line length (m) (1.0 for per-unit-length analysis): ');

% --- Material & Geometry Inputs ---
conductor_choice = '';
while ~strcmpi(conductor_choice, 'copper') && ~strcmpi(conductor_choice, 'aluminum') && ~strcmpi(conductor_choice, 'acsr')
    conductor_choice = input('Enter conductor material (copper/aluminum/acsr): ', 's');
end

insulation_choice = '';
while ~strcmpi(insulation_choice, 'pvc') && ~strcmpi(insulation_choice, 'xlpe')
    insulation_choice = input('Enter insulation material (pvc/xlpe): ', 's');
end

conductor_diameter_mm = input('Enter conductor diameter (mm): ');
insulation_thickness_mm = input('Enter insulation thickness (mm): ');

% --- Electrical Inputs ---
scenario.T_initial = input('Enter initial cable temperature (e.g., ambient temp): ');

current_choice = '';
while ~strcmpi(current_choice, 'current') && ~strcmpi(current_choice, 'load')
    current_choice = input('Calculate from (current) or (load)? ', 's');
end

if strcmpi(current_choice, 'current')
    scenario.I_rms = input('Enter RMS current (A): ');
else % load
    disp('Assuming single-phase, Line-to-Neutral voltage.');
    P_load = input('Enter power load (W): ');
    V_line = input('Enter line voltage (V): ');
    pf = input('Enter power factor (e.g., 0.9): ');
    scenario.I_rms = P_load / (V_line * pf);
    disp(['Calculated RMS Current: ' num2str(scenario.I_rms, '%.2f') ' A']);
end

disp('------------------------------------------');

% -------------------------------------------------------------------------
% 2. SET MATERIAL PROPERTIES
% (Based on user selection)
% -------------------------------------------------------------------------
disp('Setting material properties...');

% --- Conductor ---
switch lower(conductor_choice)
    case 'copper'
        params.conductor.rho_c = 8960;    % Density (kg/m^3)
        params.conductor.cp_c = 385;      % Specific heat (J/kg-K)
        conductor_sigma = 56.0;           % Conductivity (m/(Ohm*mm^2))
        params.conductor.alpha_T = 0.00393; % Temp. coefficient (1/K)
    case 'aluminum'
        params.conductor.rho_c = 2700;    % Density (kg/m^3)
        params.conductor.cp_c = 900;      % Specific heat (J/kg-K)
        conductor_sigma = 36.0;           % Conductivity (m/(Ohm*mm^2))
        params.conductor.alpha_T = 0.00403; % Temp. coefficient (1/K)
    case 'acsr'
        params.conductor.rho_c = 3980;    % Density (kg/m^3)
        params.conductor.cp_c = 880;      % Specific heat (J/kg-K)
        conductor_sigma = 34.0;           % Conductivity (m/(Ohm*mm^2))
        params.conductor.alpha_T = 0.00403; % Temp. coefficient (1/K) (Using Aluminum's)
        disp('Note: Using Aluminum temperature coefficient for ACSR.');
end

% --- Insulation ---
switch lower(insulation_choice)
    case 'pvc'
        params.insulation.rho_ins = 1400;   % Density (kg/m^3)
        params.insulation.cp_ins = 1000;   % Specific heat (J/kg-K)
        params.insulation.k_ins = 0.17;   % Thermal conductivity (W/m-K)
    case 'xlpe'
        params.insulation.rho_ins = 920;    % Density (kg/m^3)
        params.insulation.cp_ins = 2300;   % Specific heat (J/kg-K)
        params.insulation.k_ins = 0.28;   % Thermal conductivity (W/m-K)
end

% --- Fixed Simulation Parameters ---
sim.t_start = 0;       % (s)
sim.t_steps = 500;     % Number of time steps
sim.r_steps = 50;      % Number of radial points in insulation
sim.r_soil_steps = 100; % Number of radial points in soil
params.conductor.T_ref = 20; % Reference temperature for resistance (deg C)

% -------------------------------------------------------------------------
% 3. DERIVED GEOMETRIC & THERMAL PARAMETERS
% (Calculated from user inputs)
% -------------------------------------------------------------------------

% --- Time Vector ---
sim.t_vector = linspace(sim.t_start, sim.t_end, sim.t_steps);
sim.profile_times_idx = [1, round(sim.t_steps/2), sim.t_steps];
sim.profile_times_sec = sim.t_vector(sim.profile_times_idx);

% --- Geometry ---
params.conductor.r1 = (conductor_diameter_mm / 1000) / 2; % Conductor radius (m)
params.conductor.r2 = params.conductor.r1 + (insulation_thickness_mm / 1000); % Outer insulation radius (m)
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

% --- Electrical Resistance & Heat Generation (P_gen) ---
% Calculate res_ref (Ohm/m at 20 C) from conductivity
A_mm2 = pi * (conductor_diameter_mm / 2)^2; % Cross-sectional area in mm^2
rho_elec = 1 / conductor_sigma; % Electrical Resistivity (Ohm*mm^2 / m)
params.conductor.res_ref = rho_elec / A_mm2; % (Ohm/m)

% Note: R_elec is per-unit-length. We multiply by L for total resistance.
R_elec_per_meter = params.conductor.res_ref * (1 + params.conductor.alpha_T * (scenario.T_ambient - params.conductor.T_ref));
params.R_elec_total = R_elec_per_meter * params.L;
params.P_gen = scenario.I_rms^2 * params.R_elec_total; % (W)

disp(['Calculated resistance at 20 C (res_ref): ' num2str(params.conductor.res_ref) ' Ohm/m']);

% Check for cooling scenario
if scenario.I_rms == 0
    params.P_gen = 0;
    disp('Current is 0. Running a COOLING simulation.');
else
    disp(['Current is ' num2str(scenario.I_rms, '%.2f') ' A. Running a HEATING simulation.']);
end

% -------------------------------------------------------------------------
% 4. SOLVE & PLOT
% (Was section 5)
% -------------------------------------------------------------------------
disp('Starting solver...');

% Call the core solver
try
    results = Z2_solveCableTemperature(scenario, params, sim);
    
    % If solver is successful, plot the results
    disp('Simulation complete. Generating plots...');
    Z5_plotResults(results);
    disp('Plots generated successfully.');
    
catch ME
    % Catch and display any errors from the solver
    disp('------------------------------------');
    disp('ERROR during simulation:');
    disp(ME.message);
S   disp('------------------------------------');
end