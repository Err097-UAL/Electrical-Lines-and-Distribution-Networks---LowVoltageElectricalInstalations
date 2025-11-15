function [R_total, R_env] = calculateEnvironmentalResistance(scenario, params)
% -------------------------------------------------------------------------
% [R_total, R_env] = calculateEnvironmentalResistance(scenario, params)
% -------------------------------------------------------------------------
% This function calculates the environmental and total thermal resistance
% based on the defined scenario.
%
% Case 1: 'underground' -> Simple conduction formula.
% Case 2: 'overhead', v_wind = 0 -> Iterative solver for Natural Convection.
% Case 3: 'overhead', v_wind > 0 -> Iterative solver for Forced Convection.
% -------------------------------------------------------------------------

% Unpack necessary parameters
L = params.L;
D = params.D_outer;
A_s = params.A_s;
R_ins = params.R_ins;
P_gen = params.P_gen;
T_C = scenario.T_ambient;
k_ins = params.insulation.k_ins;

if strcmp(scenario.location, 'underground')
    % ---------------------------------------------------------------------
    % Case 1: Underground (Conduction)
    % ---------------------------------------------------------------------
    disp('Case: Underground (Conduction)');
    k_soil = params.soil.k_soil;
    z = scenario.burial_depth_z;
    
    % R_env = R_soil = ln(4z/D) / (2*pi*k_soil*L)
    R_env = log(4 * z / D) / (2 * pi * k_soil * L);
    R_total = R_ins + R_env;

else
    % ---------------------------------------------------------------------
    % Case 2 & 3: Overhead (Convection)
    % ---------------------------------------------------------------------
    % This requires an iterative solution to find the steady-state
    % R_env, as h_c depends on T_B (surface temp), which depends on R_env.
    
    % We need to find T_B such that:
    % P_gen = (T_B - T_C) / R_conv_ss  (Heat leaving surface)
    % R_conv_ss = 1 / (h_c * A_s)
    % h_c = f(T_B, T_C, v_wind)
    
    % Iteration parameters
    T_B_guess = T_C + 20; % Initial guess for surface temp (C)
    max_iter = 100;
    tolerance = 1e-4;
    
    if scenario.v_wind < 0.1 % Threshold for "still air"
        % --- Case 2: Natural Convection ---
        disp('Case: Overhead (Natural Convection)');
        
        for iter = 1:max_iter
            % 1. Get air properties at film temperature
            T_film = (T_B_guess + T_C) / 2;
            air = getAirProperties(T_film);
            
            % 2. Calculate Ra (Rayleigh Number)
            Gr = (9.81 * air.beta * abs(T_B_guess - T_C) * D^3) / (air.nu^2);
            Ra = Gr * air.Pr;
            
            % 3. Calculate Nu_nat (Nusselt Number) - Churchill-Chu
            term1 = 0.60;
            term2_num = 0.387 * Ra^(1/6);
            term2_den = (1 + (0.559 / air.Pr)^(9/16))^(8/27);
            Nu_nat = (term1 + term2_num / term2_den)^2;
            
            % 4. Calculate h_c
            h_c = (air.k / D) * Nu_nat;
            
            % 5. Calculate R_conv
            R_conv = 1 / (h_c * A_s);
            
            % 6. Calculate new T_B based on this R_conv
            % We use the quasi-steady state at the surface: P_loss = P_gen
            % P_gen = (T_B - T_C) / R_conv
            T_B_new = T_C + (P_gen * R_conv);
            
            % 7. Check for convergence
            if abs(T_B_new - T_B_guess) < tolerance
                break;
            end
            
            % 8. Update guess (use damping for stability)
            T_B_guess = (T_B_guess + T_B_new) / 2;
        end
        
    else
        % --- Case 3: Forced Convection ---
        disp('Case: Overhead (Forced Convection)');
        
         for iter = 1:max_iter
            % 1. Get air properties at film temperature
            T_film = (T_B_guess + T_C) / 2;
            air = getAirProperties(T_film);
            
            % 2. Calculate Re (Reynolds Number)
            Re = (scenario.v_wind * D) / air.nu;
            
            % 3. Calculate Nu_forced (Nusselt Number) - Churchill-Bernstein
            term1 = 0.3;
            term2_num = 0.62 * Re^(1/2) * air.Pr^(1/3);
            term2_den = (1 + (0.4 / air.Pr)^(2/3))^(1/4);
            term3 = (1 + (Re / 282000)^(5/8))^(4/5);
            Nu_forced = term1 + (term2_num / term2_den) * term3;
            
            % 4. Calculate h_c
            h_c = (air.k / D) * Nu_forced;
            
            % 5. Calculate R_conv
            R_conv = 1 / (h_c * A_s);
            
            % 6. Calculate new T_B based on this R_conv
            T_B_new = T_C + (P_gen * R_conv);
            
            % 7. Check for convergence
            if abs(T_B_new - T_B_guess) < tolerance
                break;
            end
            
            % 8. Update guess
            T_B_guess = (T_B_guess + T_B_new) / 2;
         end
    end
    
    if iter == max_iter
        warning('Iterative solver for R_env did not converge. Using last value.');
    else
        disp(['Iterative solver converged in ' num2str(iter) ' iterations.']);
    end
    
    % Set the final converged values
    R_env = R_conv;
    R_total = R_ins + R_env;
    
end % End of if/else 'underground'/'overhead'

end