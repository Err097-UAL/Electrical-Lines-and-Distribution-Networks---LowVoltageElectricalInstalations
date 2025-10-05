
function [Q_eq, T_surf_eq, hc, Nu] = B2_solve_thermal_equilibrium_forced(r_i, r_o, L, k_xlpe, T_cond, T_inf, v_air)
    % =========================================================================
    % ROBUST SOLVER FOR FORCED CONVECTION EQUILIBRIUM (Using Bisection Method)
    % =========================================================================
    % Finds the equilibrium where heat conducted through insulation equals
    % heat removed by forced convection. It uses the Bisection Method for
    % guaranteed convergence and stability across a wide range of inputs.

    % -- Iteration Control
    tolerance = 1e-4;
    max_iter = 100;

    % -- Pre-calculate constants
    % Handle the case where r_i equals r_o (no insulation) to avoid log(1)=0
    if abs(r_o - r_i) < 1e-9
        R_cond_formula = 0;
    else
        R_cond_formula = log(r_o / r_i) / (2 * pi * k_xlpe * L);
    end
    
    D_outer = 2 * r_o;
    A_surface = pi * D_outer * L;

    % -- Bisection Method Setup --
    % The surface temperature must be between the ambient and conductor temps.
    T_low = T_inf;
    T_high = T_cond;

    % If there's no insulation, surface temp equals conductor temp.
    if R_cond_formula == 0
        T_surf_guess = T_cond;
        Q_eq = calculate_convection(T_surf_guess, T_inf, D_outer, A_surface, v_air);
        T_surf_eq = T_surf_guess;
        [~, hc, Nu] = calculate_convection(T_surf_guess, T_inf, D_outer, A_surface, v_air);
        return;
    end

    for i = 1:max_iter
        % 1. Guess the temperature at the midpoint of the current range
        T_surf_guess = (T_low + T_high) / 2;

        % 2. Calculate the two heat flows at this guessed temperature
        Q_cond = (T_cond - T_surf_guess) / R_cond_formula;
        Q_conv = calculate_convection(T_surf_guess, T_inf, D_outer, A_surface, v_air);

        % 3. Check for convergence
        error_func = Q_cond - Q_conv;
        if abs(error_func) < tolerance
            break;
        end

        % 4. Update the bounds of the temperature range
        % If error > 0, Q_cond > Q_conv, meaning not enough heat is being
        % removed. The true surface temp must be HIGHER.
        if error_func > 0
            T_low = T_surf_guess;
        % If error < 0, Q_cond < Q_conv, meaning too much heat is being
        % removed. The true surface temp must be LOWER.
        else
            T_high = T_surf_guess;
        end
    end

    if i == max_iter
        warning('Forced convection solver did not converge within max iterations.');
    end
    
    % Recalculate final values at the converged temperature
    [Q_eq, hc, Nu] = calculate_convection(T_surf_guess, T_inf, D_outer, A_surface, v_air);
    T_surf_eq = T_surf_guess;
end

function [Q_conv, hc, Nu] = calculate_convection(T_surf, T_inf, D_outer, A_surface, v_air)
    % Helper function to calculate all convection-related values for a given
    % surface temperature.
    
    if T_surf <= T_inf
        Q_conv = 0; hc = 0; Nu = 0;
        return;
    end

    % Get properties of the bulk air (which are constant)
    bulk_air = getAirProperties(T_inf);
    mu_air = bulk_air.mu; % mu for the (mu/mu_w) term
    
    % Calculate film temperature and get its properties
    T_film = (T_surf + T_inf) / 2;
    film_air = getAirProperties(T_film); % Air properties at film temp
    
    mu_w = film_air.mu; % mu_w at film temperature
    
    % Calculate Reynolds Number (Re) using film properties
    Re = (film_air.rho * v_air * D_outer) / film_air.mu;
    
    % Get Prandtl Number (Pr) at film temperature
    Pr = film_air.Pr;
    
    % Calculate Nusselt number using the SPECIFIED formula
    Nu = 0.03 + (Pr^(1/3)) * Re * (mu_air / mu_w)^0.14;

    % Calculate convection coefficient (hc)
    hc = Nu * film_air.k / D_outer;

    % Calculate heat flow via convection
    Q_conv = hc * A_surface * (T_surf - T_inf);
end

function props = getAirProperties(T_K)
    % Provides key physical properties of dry air at atmospheric pressure
    % by linearly interpolating from a table of known values.
    
    % Data Table: Temp(K), density(kg/m3), mu(Pa·s), k(W/m·K), Pr
    air_data = [
        250   1.413   1.596e-5   0.0223   0.720
        300   1.177   1.849e-5   0.0263   0.707
        350   0.998   2.082e-5   0.0300   0.700
        400   0.883   2.286e-5   0.0338   0.690
        450   0.783   2.484e-5   0.0373   0.688
    ];

    props.rho = interp1(air_data(:,1), air_data(:,2), T_K, 'linear', 'extrap');
    props.mu  = interp1(air_data(:,1), air_data(:,3), T_K, 'linear', 'extrap');
    props.k   = interp1(air_data(:,1), air_data(:,4), T_K, 'linear', 'extrap');
    props.Pr  = interp1(air_data(:,1), air_data(:,5), T_K, 'linear', 'extrap');
end








%%%%%%%%%%%Version Vieja
% function [Q_eq, T_surf_eq, hc, Nu] = B2_solve_thermal_equilibrium_forced(r_i, r_o, L, k_xlpe, T_cond, T_inf, v_air)
%     % =========================================================================
%     % ITERATIVE SOLVER FOR FORCED CONVECTION EQUILIBRIUM
%     % =========================================================================
%     % Finds the equilibrium where heat conducted through insulation equals
%     % heat removed by forced convection. It iterates on the surface temp.
%     %
%     % The user-specified Nusselt number correlation is used.
% 
%     % -- Iteration Control
%     tolerance = 1e-4;
%     max_iter = 100;
%     relaxation = 0.5;
% 
%     % -- Initial Guess
%     T_surf_guess = T_inf + (T_cond - T_inf) / 2;
% 
%     % -- Pre-calculate constants
%     R_cond_formula = log(r_o / r_i) / (2 * pi * k_xlpe * L);
%     D_outer = 2 * r_o;
%     A_surface = pi * D_outer * L;
% 
%     % Get properties of the bulk air (which are constant)
%     bulk_air = getAirProperties(T_inf);
%     mu_air = bulk_air.mu; % mu for the (mu/mu_w) term
% 
%     for i = 1:max_iter
%         % 1. Calculate heat flow via CONDUCTION based on current T_surf guess
%         Q_cond = (T_cond - T_surf_guess) / R_cond_formula;
% 
%         % 2. Calculate heat flow via FORCED CONVECTION
%         T_film = (T_surf_guess + T_inf) / 2;
%         film_air = getAirProperties(T_film); % Air properties at film temp
% 
%         mu_w = film_air.mu; % mu_w at film temperature
% 
%         % Calculate Reynolds Number (Re) using film properties
%         Re = (film_air.rho * v_air * D_outer) / film_air.mu;
% 
%         % Get Prandtl Number (Pr) at film temperature
%         Pr = film_air.Pr;
% 
%         % Calculate Nusselt number using the SPECIFIED formula
%         Nu = 0.03 + (Pr^(1/3)) * Re * (mu_air / mu_w)^0.14;
% 
%         % Calculate convection coefficient (hc)
%         hc = Nu * film_air.k / D_outer;
% 
%         % Calculate heat flow via convection
%         Q_conv = hc * A_surface * (T_surf_guess - T_inf);
% 
%         % 3. Check for convergence
%         error = abs(Q_cond - Q_conv);
%         if error < tolerance 
%             break;
%         end
% 
%         % 4. Update guess for next iteration
%         T_surf_new = T_cond - (Q_conv * R_cond_formula);
%         T_surf_guess = relaxation * T_surf_new + (1 - relaxation) * T_surf_guess;
% 
%         % *** FIX FOR INSTABILITY ***
%         % Prevent the surface temperature from dropping below the ambient
%         % temperature, which is physically impossible and causes the error.
%         if T_surf_guess < T_inf
%             T_surf_guess = T_inf;
%         end
%     end
% 
%     if i == max_iter
%         warning('Forced convection solver did not converge.');
%     end
% 
%     Q_eq = Q_conv;
%     T_surf_eq = T_surf_guess;
% end
% 
% function props = getAirProperties(T_K)
%     % Provides key physical properties of dry air at atmospheric pressure
%     % by linearly interpolating from a table of known values.
% 
%     % Data Table: Temp(K), density(kg/m3), mu(Pa·s), k(W/m·K), Pr
%     air_data = [
%         250   1.413   1.596e-5   0.0223   0.720
%         300   1.177   1.849e-5   0.0263   0.707
%         350   0.998   2.082e-5   0.0300   0.700
%         400   0.883   2.286e-5   0.0338   0.690
%         450   0.783   2.484e-5   0.0373   0.688
%     ];
% 
%     props.rho = interp1(air_data(:,1), air_data(:,2), T_K, 'linear', 'extrap');
%     props.mu  = interp1(air_data(:,1), air_data(:,3), T_K, 'linear', 'extrap');
%     props.k   = interp1(air_data(:,1), air_data(:,4), T_K, 'linear', 'extrap');
%     props.Pr  = interp1(air_data(:,1), air_data(:,5), T_K, 'linear', 'extrap');
% end
