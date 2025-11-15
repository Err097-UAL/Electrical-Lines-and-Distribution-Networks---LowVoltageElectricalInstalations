function results = solveCableTemperature(scenario, params, sim)
% -------------------------------------------------------------------------
% results = solveCableTemperature(scenario, params, sim)
% -------------------------------------------------------------------------
% This function calculates the complete thermal response of the cable.
%
% 1. Calls calculateEnvironmentalResistance to get R_total.
% 2. Solves the analytical 1st-order ODE for conductor temp T_A(t).
% 3. Calculates the outer surface temp T_B(t).
% 4. Calculates the radial temperature profiles at specific times.
% 5. Bundles all data into the 'results' struct.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% 1. Calculate Total Thermal Resistance
% -------------------------------------------------------------------------
% This function handles all 3 cases (underground, natural, forced)
% and includes the iterative solver for overhead cases.
disp('Calculating thermal resistances...');
[R_total, R_env] = calculateEnvironmentalResistance(scenario, params);

disp(['Calculated R_env: ' num2str(R_env, '%.4f') ' K/W']);
disp(['Calculated R_ins: ' num2str(params.R_ins, '%.4f') ' K/W']);
disp(['Calculated R_total: ' num2str(R_total, '%.4f') ' K/W']);

% -------------------------------------------------------------------------
% 2. Solve for Conductor Temperature T_A(t)
% -------------------------------------------------------------------------
% Based on the analytical solution to the 1st-order ODE.

% Calculate Time Constant (tau)
tau = R_total * params.C_th_corrected; % (s)

% Calculate Final Steady-State Temperature (T_ss)
if params.P_gen > 0
    % Heating Scenario
    T_ss = scenario.T_ambient + (params.P_gen * R_total);
    
    % Equation: T_A(t) = T_ss + (T_i - T_ss) * exp(-t/tau)
    T_A_t = T_ss + (scenario.T_initial - T_ss) * exp(-sim.t_vector / tau);
else
    % Cooling Scenario (P_gen = 0)
    T_ss = scenario.T_ambient;
    
    % Equation: T_A(t) = T_C + (T_i - T_C) * exp(-t/tau)
    T_A_t = T_ss + (scenario.T_initial - T_ss) * exp(-sim.t_vector / tau);
end

disp(['Calculated Time Constant (tau): ' num2str(tau/60, '%.2f') ' minutes']);
disp(['Calculated Steady-State Temp (T_ss): ' num2str(T_ss, '%.2f') ' C']);

% -------------------------------------------------------------------------
% 3. Solve for Surface Temperature T_B(t)
% -------------------------------------------------------------------------
% Use the quasi-steady-state assumption:
% P_loss = (T_A(t) - T_C) / R_total = (T_B(t) - T_C) / R_env
% T_B(t) = T_C + ( (T_A(t) - T_C) / R_total ) * R_env

T_B_t = scenario.T_ambient + ((T_A_t - scenario.T_ambient) / R_total) .* R_env;

% -------------------------------------------------------------------------
% 4. Calculate Radial Temperature Profiles (at specific times)
% -------------------------------------------------------------------------
disp('Calculating radial temperature profiles...');

% --- Insulation Profile T(r,t) ---
% r is between r1 and r2
r_ins_vector = linspace(params.conductor.r1, params.conductor.r2, sim.r_steps);
T_ins_profile = zeros(length(sim.profile_times_idx), sim.r_steps);

for i = 1:length(sim.profile_times_idx)
    idx = sim.profile_times_idx(i);
    T_A = T_A_t(idx); % Conductor temp at this time
    T_B = T_B_t(idx); % Surface temp at this time
    
    % T(r, t) = T_A(t) - [ (T_A(t) - T_B(t)) * ln(r/r1) / ln(r2/r1) ]
    T_ins_profile(i, :) = T_A - ((T_A - T_B) * log(r_ins_vector / params.conductor.r1) / log(params.conductor.r2 / params.conductor.r1));
end


% --- Soil Profile T_soil(r,t) ---
% Only calculate if underground
T_soil_profile = []; % Initialize as empty
r_soil_vector = [];

if strcmp(scenario.location, 'underground')
    % r is from r2 outwards (e.g., to burial_depth)
    % We plot from r2 to a distance of z, as ln(4z/r) is undefined at r=4z
    % Let's plot from r2 to z
    r_soil_vector = linspace(params.conductor.r2, scenario.burial_depth_z, sim.r_soil_steps);
    T_soil_profile = zeros(length(sim.profile_times_idx), sim.r_soil_steps);
    
    z = scenario.burial_depth_z;
    D = params.D_outer;
    
    for i = 1:length(sim.profile_times_idx)
        idx = sim.profile_times_idx(i);
        T_B = T_B_t(idx); % Surface temp at this time
        T_C = scenario.T_ambient;
        
        % T_soil(r, t) = T_C + (T_B(t) - T_C) * ln(4z/r) / ln(4z/D)
        T_soil_profile(i, :) = T_C + (T_B - T_C) * log(4*z ./ r_soil_vector) / log(4*z / D);
    end
end

% -------------------------------------------------------------------------
% 5. Bundle Results
% -------------------------------------------------------------------------
results.scenario = scenario;
results.params = params;
results.sim = sim;
results.R_total = R_total;
results.R_env = R_env;
results.tau = tau;
results.T_ss = T_ss;
results.t_vector = sim.t_vector;
results.T_A_t = T_A_t;
results.T_B_t = T_B_t;

% Profiles
results.r_ins_vector = r_ins_vector;
results.T_ins_profile = T_ins_profile;
results.r_soil_vector = r_soil_vector;
results.T_soil_profile = T_soil_profile;

end