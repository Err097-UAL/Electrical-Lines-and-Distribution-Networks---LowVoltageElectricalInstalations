function [Q_eq, T_surf_eq, hc, Nu] = A2_solve_thermal_equilibrium(r_i, r_o, L, k_xlpe, T_cond, T_inf)
    % =========================================================================
    % ITERATIVE SOLVER FOR CABLE THERMAL EQUILIBRIUM
    % =========================================================================
    % This function finds the equilibrium state where the heat conducted
    % through the insulation equals the heat convected to the air.
    % It iterates on the insulation's outer surface temperature (T_surf).
    %
    % Inputs:
    %   r_i, r_o, L, k_xlpe, T_cond, T_inf - System parameters
    % Outputs:
    %   Q_eq - Equilibrium heat flow rate [W]
    %   T_surf_eq - Equilibrium surface temperature [K]
    %   hc, Nu - Resulting convection coefficient and Nusselt number

    % -- Iteration Control
    tolerance = 1e-4;
    max_iter = 100;
    relaxation = 0.5; % Relaxation factor to aid convergence

    % -- Initial Guess for surface temperature
    T_surf_guess = T_inf + (T_cond - T_inf) / 2;

    % -- Pre-calculate constants
    R_cond_formula = log(r_o / r_i) / (2 * pi * k_xlpe * L);
    D_outer = 2 * r_o;
    A_surface = pi * D_outer * L;
    g = 9.81; % Gravitational acceleration [m/s^2]

    for i = 1:max_iter
        % 1. Calculate heat flow via CONDUCTION based on current T_surf guess
        Q_cond = (T_cond - T_surf_guess) / R_cond_formula;

        % 2. Calculate heat flow via CONVECTION based on current T_surf guess
        % This requires calculating hc, which depends on air properties at the
        % film temperature.
        T_film = (T_surf_guess + T_inf) / 2;
        
        % Get air properties at film temperature
        air = getAirProperties(T_film);
        
        % Calculate Rayleigh number (for natural convection)
        beta = 1 / T_film; % Volumetric thermal expansion for ideal gas
        Ra = (g * beta * abs(T_surf_guess - T_inf) * D_outer^3) / (air.nu * air.alpha);

        % Calculate Nusselt number using Churchill and Chu correlation
        term1 = 0.60;
        term2 = 0.387 * Ra^(1/6);
        term3 = (1 + (0.559 / air.Pr)^(9/16))^(8/27);
        Nu = (term1 + term2 / term3)^2;

        % Calculate convection coefficient (hc)
        hc = Nu * air.k / D_outer;

        % Calculate heat flow via convection
        Q_conv = hc * A_surface * (T_surf_guess - T_inf);

        % 3. Check for convergence
        error = abs(Q_cond - Q_conv);
        if error < tolerance
            break;
        end

        % 4. Update guess for next iteration
        % We update the guess by calculating what T_surf would be if Q_conv
        % were the true heat flow. A relaxation factor is used to prevent
        % oscillations.
        T_surf_new = T_cond - (Q_conv * R_cond_formula);
        T_surf_guess = relaxation * T_surf_new + (1 - relaxation) * T_surf_guess;
    end

    if i == max_iter
        warning('Solver did not converge within max iterations.');
    end
    
    % Return converged values
    Q_eq = Q_conv;
    T_surf_eq = T_surf_guess;
end

function props = getAirProperties(T_K)
    % Provides key physical properties of dry air at atmospheric pressure
    % by linearly interpolating from a table of known values.
    % Also calculates diffusivity properties nu and alpha.
    
    % Data Table: Temp(K), density(kg/m3), mu(Pa·s), k(W/m·K), Pr
    air_data = [
        250   1.413   1.596e-5   0.0223   0.720
        300   1.177   1.849e-5   0.0263   0.707
        350   0.998   2.082e-5   0.0300   0.700
        400   0.883   2.286e-5   0.0338   0.690
    ];

    % Interpolate primary properties
    rho = interp1(air_data(:,1), air_data(:,2), T_K, 'linear', 'extrap');
    mu  = interp1(air_data(:,1), air_data(:,3), T_K, 'linear', 'extrap');
    k   = interp1(air_data(:,1), air_data(:,4), T_K, 'linear', 'extrap');
    Pr  = interp1(air_data(:,1), air_data(:,5), T_K, 'linear', 'extrap');
    cp  = 1007; % J/kg·K (relatively constant over this range)

    % Calculate derived properties
    props.k = k;
    props.Pr = Pr;
    props.nu = mu / rho; % Kinematic viscosity (m^2/s)
    props.alpha = k / (rho * cp); % Thermal diffusivity (m^2/s)
end
