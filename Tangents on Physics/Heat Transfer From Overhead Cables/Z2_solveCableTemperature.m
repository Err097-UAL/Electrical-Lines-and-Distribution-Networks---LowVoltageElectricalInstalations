function results = Z2_solveCableTemperature(scenario, params, sim)
% -------------------------------------------------------------------------
% results = Z2_solveCableTemperature(scenario, params, sim)
% -------------------------------------------------------------------------
% This function calculates the complete thermal response of the cable.
%
% 1. Calls Z3_calculateEnvironmentalResistance to get R_total.
% 2. Solves the analytical 1st-order ODE for conductor temp T_A(t).
% 3. Calculates the outer surface temp T_B(t).
% 4. Calculates the radial temperature profiles at specific times (for 2D)
%    and for all times (for 3D).
% 5. Bundles all data into the 'results' struct.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% 1. Calculate Total Thermal Resistance
% -------------------------------------------------------------------------
disp('Calculating thermal resistances...');
% Updated to receive iteration_history
[R_total, R_env, iteration_history] = Z3_calculateEnvironmentalResistance(scenario, params);

disp(['Calculated R_env: ' num2str(R_env, '%.4f') ' K/W']);
disp(['Calculated R_ins: ' num2str(params.R_ins, '%.4f') ' K/W']);
disp(['Calculated R_total: ' num2str(R_total, '%.4f') ' K/W']);

% -------------------------------------------------------------------------
% 2. Solve for Conductor Temperature T_A(t)
% -------------------------------------------------------------------------
disp('Solving for T(t)...');

% Calculate Time Constant (tau)
tau = R_total * params.C_th_corrected; % (s)

% Calculate Final Steady-State Temperature (T_ss)
if params.P_gen > 0
    % Heating Scenario
    T_ss = scenario.T_ambient + (params.P_gen * R_total);
    T_A_t = T_ss + (scenario.T_initial - T_ss) * exp(-sim.t_vector / tau);
else
    % Cooling Scenario (P_gen = 0)
    T_ss = scenario.T_ambient;
    T_A_t = T_ss + (scenario.T_initial - T_ss) * exp(-sim.t_vector / tau);
end

disp(['Calculated Time Constant (tau): ' num2str(tau/60, '%.2f') ' minutes']);
disp(['Calculated Steady-State Temp (T_ss): ' num2str(T_ss, '%.2f') ' C']);

% -------------------------------------------------------------------------
% 3. Solve for Surface Temperature T_B(t)
% -------------------------------------------------------------------------
% T_B(t) = T_C + ( (T_A(t) - T_C) / R_total ) * R_env
T_B_t = scenario.T_ambient + ((T_A_t - scenario.T_ambient) / R_total) .* R_env;

% -------------------------------------------------------------------------
% 4. Calculate Radial Temperature Profiles
% -------------------------------------------------------------------------
disp('Calculating radial temperature profiles...');

% --- Insulation Profile T(r,t) ---
% We calculate the full profile for all time steps (for 3D plot)
% and then extract the specific time slices (for 2D plot).
r_ins_vector = linspace(params.conductor.r1, params.conductor.r2, sim.r_steps);
T_ins_profile_full = zeros(sim.t_steps, sim.r_steps);

% Pre-calculate log ratios for speed
log_denom = log(params.conductor.r2 / params.conductor.r1);
log_num = log(r_ins_vector / params.conductor.r1);

for i = 1:sim.t_steps
    T_A = T_A_t(i); % Conductor temp at this time
    T_B = T_B_t(i); % Surface temp at this time
    
    % T(r, t) = T_A(t) - [ (T_A(t) - T_B(t)) * ln(r/r1) / ln(r2/r1) ]
    T_ins_profile_full(i, :) = T_A - ((T_A - T_B) * log_num / log_denom);
end

% Extract the specific profiles for the 2D plot
T_ins_profile_2D = T_ins_profile_full(sim.profile_times_idx, :);


% --- Soil Profile T_soil(r,t) ---
% Only calculate if underground
T_soil_profile = []; % Initialize as empty
r_soil_vector = [];

if strcmp(scenario.location, 'underground')
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
results.T_ins_profile = T_ins_profile_2D; % For the 2D plot
results.T_ins_profile_full = T_ins_profile_full; % For the 3D plot
results.r_soil_vector = r_soil_vector;
results.T_soil_profile = T_soil_profile;

% Add iteration history to results
results.iteration_history = iteration_history;

end