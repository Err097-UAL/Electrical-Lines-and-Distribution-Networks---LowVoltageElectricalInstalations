function results = J8_Meshed_Analysis()
% =========================================================================
% FUNCTION: Meshed Network Nodal Analysis (NEW)
% =========================================================================
% Description:
% This function performs a load flow analysis on a predefined 4-bus meshed
% network using the nodal analysis (Y_bus) method. It calculates bus
% voltages, line currents, and power losses.
% =========================================================================
results = [];
disp('--- Meshed Network Nodal Analysis ---');
disp('Analyzing a predefined 4-bus test network.');

% --- 1. Define Network Parameters ---
% Network Topology:
% G1 --(L1)-- B2 --(L3)-- B4 --(L5)-- G2
% |           |           |           |
% (L2)        (L4)        (L6)       (L7)
% |___________B3__________|___________|

num_buses = 4;
slack_bus = 1;

% Line data: [from, to, Resistance (R), Reactance (X)]
% Note: Impedances are in Ohms. We will convert to admittance.
lines = [
    1, 2, 0.1, 0.2;  % Line 1
    1, 3, 0.05, 0.1; % Line 2
    2, 4, 0.08, 0.15;% Line 3
    2, 3, 0.12, 0.25;% Line 4
    4, 1, 0.1, 0.2;  % Line 5 (example of another generator) - let's simplify for now
    3, 4, 0.07, 0.14 % Line 6
];
Z_lines = lines(:,3) + 1i * lines(:,4);
Y_lines = 1 ./ Z_lines;

% Bus data: [Bus No, P_load (W), Q_load (VAr)]
bus_loads = [
    1, 0, 0;         % Slack bus, no load
    2, 80000, 40000; % Load at Bus 2
    3, 60000, 30000; % Load at Bus 3
    4, 90000, 45000; % Load at Bus 4
];
S_loads = (bus_loads(:,2) + 1i * bus_loads(:,3));

% Generator data: [Bus No, Voltage (V)]
U_gen = 230; % Line-to-neutral voltage

% ========================================================================
% TOOL IMPLEMENTATION: NODAL ANALYSIS METHOD
% ========================================================================
% --- 2. Build the Bus Admittance Matrix (Y_bus) ---
Y_bus = zeros(num_buses, num_buses);
for k = 1:size(lines, 1)
    from = lines(k, 1);
    to = lines(k, 2);
    y_kl = Y_lines(k);
    
    % Off-diagonal elements
    Y_bus(from, to) = Y_bus(from, to) - y_kl;
    Y_bus(to, from) = Y_bus(to, from) - y_kl;
    
    % Diagonal elements
    Y_bus(from, from) = Y_bus(from, from) + y_kl;
    Y_bus(to, to) = Y_bus(to, to) + y_kl;
end

% --- 3. Perform Load Flow Calculation ---
% Simple Gauss-Seidel Iteration
V_bus = ones(num_buses, 1) * U_gen; % Flat start
V_bus(slack_bus) = U_gen; % Fix slack bus voltage
tolerance = 1e-5;
max_iter = 100;

for iter = 1:max_iter
    V_prev = V_bus;
    for i = 2:num_buses % Iterate through non-slack buses
        sigma_YV = Y_bus(i,:) * V_bus - Y_bus(i,i) * V_bus(i);
        I_inj = -conj(S_loads(i) / V_bus(i));
        V_bus(i) = (1/Y_bus(i,i)) * (I_inj - sigma_YV);
    end
    if max(abs(abs(V_bus) - abs(V_prev))) < tolerance
        fprintf('Gauss-Seidel converged in %d iterations.\n', iter);
        break;
    end
end
if iter == max_iter, warning('Gauss-Seidel did not converge!'); end

% ========================================================================
% TOOL IMPLEMENTATION: ANALYZE LOAD FLOW AND LOSSES
% ========================================================================
% --- 4. Calculate Line Currents and Losses ---
line_currents = zeros(size(lines, 1), 1);
line_losses_S = zeros(size(lines, 1), 1);
for k = 1:size(lines, 1)
    from = lines(k, 1);
    to = lines(k, 2);
    y_kl = Y_lines(k);
    V_diff = V_bus(from) - V_bus(to);
    line_currents(k) = V_diff * y_kl;
    line_losses_S(k) = V_diff * conj(line_currents(k));
end

% --- 5. Finalize Results ---
results.num_buses = num_buses;
results.V_bus = V_bus;
results.lines = lines;
results.line_currents = line_currents;
results.line_losses_S = line_losses_S;
results.line_losses_P = real(line_losses_S);
end
