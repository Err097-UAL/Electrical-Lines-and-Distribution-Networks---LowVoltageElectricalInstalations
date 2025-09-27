% --- Mechanical Properties Data Definition ---
% Define the names of the materials in a cell array.
material_names = {'Aluminum (AAC)', 'Copper', 'ACSR'};

% Define the tensile strength ranges [min, max] in MPa.
% The order corresponds to material_names.
tensile_strength_mpa = [
    160, 200;  % Aluminum (AAC)
    300, 450;  % Copper
    500, 1500  % ACSR
];

% Define the Young's Modulus ranges [min, max] in GPa.
% The order corresponds to material_names.
youngs_modulus_gpa = [
    60, 70;    % Aluminum (AAC)
    115, 125;  % Copper
    75, 110    % ACSR
];

% --- Graph 1: Tensile Strength ---

% 1. Sort the data based on minimum tensile strength (from least to greatest).
min_strength = tensile_strength_mpa(:, 1);
[sorted_min_strength, sort_order] = sort(min_strength);

% 2. Reorder all tensile strength data and names according to the sort order.
sorted_names_ts = material_names(sort_order);
sorted_tensile_strength = tensile_strength_mpa(sort_order, :);

% 3. Create the first figure window.
figure;

% 4. Create a grouped bar chart with the sorted data.
b1 = bar(sorted_tensile_strength);
title('Tensile Strength of Conductor Materials', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Tensile Strength (MPa)', 'FontSize', 12);
xlabel('Conductor Material', 'FontSize', 12);

% 5. Set the x-axis labels to the sorted material names.
set(gca, 'xticklabel', sorted_names_ts);

% 6. Add a legend to explain the bars.
legend({'Minimum Strength', 'Maximum Strength'}, 'Location', 'northwest');
grid on; % Add a grid for better readability.

% --- Graph 2: Young's Modulus ---

% 1. Sort the data based on the average Young's Modulus.
avg_modulus = mean(youngs_modulus_gpa, 2);
[~, sort_order_ym] = sort(avg_modulus);

% 2. Reorder all Young's Modulus data and names according to the sort order.
sorted_names_ym = material_names(sort_order_ym);
sorted_youngs_modulus = youngs_modulus_gpa(sort_order_ym, :);

% 3. Create the second figure window.
figure;

% 4. Create a grouped bar chart with the sorted min/max data.
b2 = bar(sorted_youngs_modulus);
title("Young's Modulus of Conductor Materials", 'FontSize', 14, 'FontWeight', 'bold');
ylabel("Young's Modulus (GPa)", 'FontSize', 12);
xlabel('Conductor Material', 'FontSize', 12);

% 5. Set the x-axis labels to the sorted material names.
set(gca, 'xticklabel', sorted_names_ym);

% 6. Add a legend to explain the bars.
legend({'Minimum Modulus', 'Maximum Modulus'}, 'Location', 'northwest');
grid on; % Add a grid.

