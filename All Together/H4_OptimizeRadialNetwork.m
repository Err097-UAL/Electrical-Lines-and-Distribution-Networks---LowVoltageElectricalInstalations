function optimal_results = H4_OptimizeRadialNetwork(base_results)
% =========================================================================
% FUNCTION: Optimize Radial Network Design
% =========================================================================
% Description:
% This function finds the most economical standard conductor cross-section
% that meets both the maximum voltage drop and thermal limit constraints.
% =========================================================================

fprintf('\n\n--- Starting Network Optimization ---\n');
max_drop_percent = input('Enter the maximum allowed voltage drop percentage (e.g., 5): ');
max_drop_V = base_results.U_source * (max_drop_percent / 100);

% Get standard conductor data
conductors = getStandardConductors(base_results.materialName);
optimal_results = [];

% Iterate through standard conductors, from smallest to largest
for i = 1:height(conductors)
    s_test = conductors.CrossSection(i);
    I_adm_test = conductors.MaxCurrent(i);
    
    fprintf('\nTesting standard section: %d mm^2 (I_adm = %.1f A)...\n', s_test, I_adm_test);
    
    % --- CHECK 1: Thermal Limit Constraint ---
    max_current_in_line = sum([base_results.loads.current]);
    if max_current_in_line > I_adm_test
        fprintf(' -> FAIL: Thermal limit exceeded (%.1f A > %.1f A).\n', max_current_in_line, I_adm_test);
        continue; % Skip to next larger size
    else
        fprintf(' -> PASS: Thermal limit is met.\n');
    end
    
    % --- CHECK 2: Voltage Drop Constraint ---
    total_drop = 0;
    current_in_segment = max_current_in_line;
    
    for j = 1:length(base_results.loads)
        drop_segment = (base_results.phase_factor / (base_results.conductivity * s_test)) * current_in_segment * base_results.loads(j).length;
        total_drop = total_drop + drop_segment;
        current_in_segment = current_in_segment - base_results.loads(j).current;
    end
    
    if total_drop > max_drop_V
        fprintf(' -> FAIL: Voltage drop exceeded (%.2f V > %.2f V).\n', total_drop, max_drop_V);
        continue; % Skip to next larger size
    else
        fprintf(' -> PASS: Voltage drop is within limits.\n');
        
        % This is the first section that passes both tests, so it's the optimal one
        fprintf('\n--- OPTIMIZATION COMPLETE ---\n');
        fprintf('Optimal Cross-Section Found: %d mm^2\n', s_test);
        
        optimal_results = base_results;
        optimal_results.crossSection = s_test;
        optimal_results.max_drop_V = total_drop;
        optimal_results.max_drop_percent = (total_drop / base_results.U_source) * 100;
        
        % Recalculate final voltage profile with the optimal section
        voltage_at_node = base_results.U_source;
        current_in_segment = max_current_in_line;
        for k = 1:length(optimal_results.loads)
             drop_segment = (optimal_results.phase_factor / (optimal_results.conductivity * s_test)) * current_in_segment * optimal_results.loads(k).length;
             voltage_at_node = voltage_at_node - drop_segment;
             optimal_results.loads(k).voltage = voltage_at_node;
             current_in_segment = current_in_segment - optimal_results.loads(k).current;
        end
        
        % Calculate total cost
        total_length = sum([optimal_results.loads.distance]); % Sum of all segment lengths
        cost_per_meter = conductors.CostPerMeter(i);
        optimal_results.total_cost = total_length * cost_per_meter;
        fprintf('Total Conductor Cost for this design: %.2f EUR\n', optimal_results.total_cost);

        return; % Exit the function once the optimal solution is found
    end
end

% If the loop finishes, no suitable conductor was found
fprintf('\n--- OPTIMIZATION FAILED ---\n');
fprintf('No standard conductor could satisfy the specified constraints.\n');
end

