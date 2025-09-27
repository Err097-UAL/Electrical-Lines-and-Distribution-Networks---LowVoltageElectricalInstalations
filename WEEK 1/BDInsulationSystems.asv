% --- Comprehensive Analysis of PVC and XLPE Insulation Systems ---
%
% This script provides a technical and regulatory comparison of PVC
% (Polyvinyl Chloride) and XLPE (Cross-linked Polyethylene) insulation.
%
% It calculates and visualizes:
% 1. The relationship between operating temperature and insulation resistance.
% 2. The maximum power capacity of a standard cable based on insulation type.
%
% It also prints a detailed report to the command window covering:
% - Technical descriptions, strengths, and weaknesses.
% - Economic and ecological factors.
% - An application suitability analysis with references to Spain's REBT.

% --- Initial Setup ---
clear;          % Clear workspace variables
clc;            % Clear command window
close all;      % Close all figures

% --- Define Constants and Insulation Properties ---
% System and Conductor Parameters
V_v = 400;           % Line Voltage in Volts (Three-phase)
s_mm2 = 2.5;         % Conductor cross-sectional area in mm^2

% Insulation Properties
insulators = {'PVC', 'XLPE'};
max_temp_C = [70, 90]; % Max continuous operating temperature (°C)

% Max Admissible Current (I_max) for a 2.5 mm^2 Copper conductor
% Values are illustrative, based on REBT ITC-BT-19 (Table 1),
% assuming a common installation method (e.g., multicore cable in conduit).
i_max_insulation = [18, 24]; % [PVC, XLPE] in Amps

% --- Graph 1: Temperature vs. Insulation Resistance ---
% This is an illustrative model to show the concept that insulation
% resistance decreases exponentially as temperature rises. XLPE maintains
% higher resistance at higher temperatures.

temp_range_C = 20:5:120; % Temperature range from 20°C to 120°C
R0 = 1000; % Nominal insulation resistance at 20°C (in Giga-Ohms*km)

% Decay coefficients (alpha). A smaller alpha means slower decay.
alpha_pvc = 0.045;
alpha_xlpe = 0.035;

% Calculate resistance degradation
R_pvc = R0 * exp(-alpha_pvc * (temp_range_C - 20));
R_xlpe = R0 * exp(-alpha_xlpe * (temp_range_C - 20));

figure;
hold on;
plot(temp_range_C, R_pvc, 'LineWidth', 2, 'Color', '#D95319');
plot(temp_range_C, R_xlpe, 'LineWidth', 2, 'Color', '#0072BD');
plot([max_temp_C(1) max_temp_C(1)], [0 1200], 'r--', 'LineWidth', 1.5); % PVC Temp Limit
plot([max_temp_C(2) max_temp_C(2)], [0 1200], 'b--', 'LineWidth', 1.5); % XLPE Temp Limit
hold off;

title('Temperature Effect on Insulation Resistance', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Operating Temperature (°C)', 'FontSize', 12);
ylabel('Relative Insulation Resistance', 'FontSize', 12);
legend('PVC', 'XLPE', 'PVC Max Temp Limit (70°C)', 'XLPE Max Temp Limit (90°C)');
grid on;
ylim([0 R0*1.1]); % Set y-axis limit for clarity

% --- Graph 2: Maximum Power Capacity Comparison ---
% Calculate max power: P = sqrt(3) * V * I
P_max_kw_pvc = (sqrt(3) * V_v * i_max_insulation(1)) / 1000;
P_max_kw_xlpe = (sqrt(3) * V_v * i_max_insulation(2)) / 1000;

max_power_data = [P_max_kw_pvc, P_max_kw_xlpe];
insulator_labels = {'PVC Insulated Cable', 'XLPE Insulated Cable'};

figure;
bar(max_power_data, 'FaceColor', '#77AC30');
title(['Maximum Power Capacity (2.5 mm^2 Copper Conductor at ' num2str(V_v) 'V)'], ...
      'FontSize', 14, 'FontWeight', 'bold');
ylabel('Power (kW)', 'FontSize', 12);
set(gca, 'xticklabel', insulator_labels);
grid on;
text(1:length(max_power_data), max_power_data, num2str(max_power_data', '%.2f kW'), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 11);


% --- Display Detailed Analysis in Command Window ---
fprintf('====================================================================\n');
fprintf('        ANALYSIS OF INSULATION SYSTEMS: PVC vs. XLPE\n');
fprintf('====================================================================\n\n');

fprintf('--- 1. Technical Description ---\n');
fprintf('PVC (Polyvinyl Chloride): A thermoplastic polymer. It is made flexible for cable use\n');
fprintf('by adding plasticizers. It is a cost-effective and versatile insulator.\n\n');
fprintf('XLPE (Cross-linked Polyethylene): A thermosetting polymer. The polyethylene molecules\n');
fprintf('are permanently bonded ("cross-linked"), preventing them from melting or separating at\n');
fprintf('higher temperatures, giving it superior thermal and mechanical stability.\n\n');


fprintf('--- 2. Strengths and Weaknesses ---\n');
fprintf('STRENGTHS:\n');
fprintf('  - PVC:  Lower cost, high flexibility, good resistance to oils and chemicals.\n');
fprintf('  - XLPE: Higher operating temperature (90°C vs 70°C), higher current rating for the\n');
fprintf('          same conductor size, greater mechanical toughness and water resistance.\n');
fprintf('WEAKNESSES:\n');
fprintf('  - PVC:  Lower temperature rating, produces dense, corrosive smoke (HCl gas) when\n');
fprintf('          burned, becomes brittle at low temperatures.\n');
fprintf('  - XLPE: Higher material cost, less flexible than PVC which can make installation\n');
fprintf('          in tight spaces more difficult.\n\n');

fprintf('--- 3. Economic and Ecological Factors ---\n');
fprintf('ECONOMIC:\n');
fprintf('  - PVC is cheaper upfront. However, XLPE''s ability to carry more current can allow\n');
fprintf('    for smaller conductor sizes for the same load, potentially offsetting the cost\n');
fprintf('    (a concept known as "economic section").\n\n');
fprintf('ECOLOGICAL:\n');
fprintf('  - PVC: Contains chlorine and requires plasticizers (phthalates), which are environmental\n');
fprintf('    concerns. Its combustion byproducts are highly toxic.\n');
fprintf('  - XLPE: Is halogen-free, making it much safer in a fire (low smoke, zero halogen - LSZH).\n');
fprintf('    It is also more difficult to recycle due to its thermosetting nature.\n\n');

fprintf('--- 4. Application Suitability & REBT Compliance ---\n');
fprintf('The choice is heavily regulated by the REBT for safety.\n\n');
fprintf('SUITABLE FOR PVC (e.g., H07V-K, VV-K cables):\n');
fprintf('  - General indoor wiring in dry environments, domestic installations, and control circuits\n');
fprintf('    where thermal stress is low.\n');
fprintf('  - REBT Reference: ITC-BT-19 specifies max currents for PVC in its tables.\n');
fprintf('    The standard UNE-EN 50525 covers the characteristics of these cables.\n\n');
fprintf('SUITABLE FOR XLPE (e.g., RZ1-K (AS), DHZ1 cables):\n');
fprintf('  - High-power circuits (Líneas Generales de Alimentación, Derivaciones Individuales).\n');
fprintf('  - Installations with high operating temperatures or risk of overload.\n');
fprintf('  - Public premises (hospitals, schools, etc.) where low smoke and zero halogen (LSZH)\n');
fprintf('    properties are mandatory for fire safety.\n');
fprintf('  - Underground or outdoor installations due to its toughness and water resistance.\n');
fprintf('  - REBT References: ITC-BT-07 (Underground Networks) and ITC-BT-15 (Installations in\n');
fprintf('    public premises) strongly favor or mandate halogen-free cables like XLPE.\n');
fprintf('    The standard UNE 21123-2 defines the construction of these cables.\n\n');
fprintf('====================================================================\n');
