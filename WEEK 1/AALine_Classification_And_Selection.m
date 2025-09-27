% Create a table to store line classifications
% Using a structure to organize line data
powerLines= struct();

% Student A
powerLines.IndustrialFacility.Proyect = 'Industrial Instalation';
powerLines.IndustrialFacility.Voltage = 20000; % Volts
powerLines.IndustrialFacility.VoltageLevel = 'MV';
powerLines.IndustrialFacility.Application = 'Distribution';
powerLines.IndustrialFacility.Topology = 'Mixed';
powerLines.IndustrialFacility.TypicalConductor = 'XLPE Insulated Copper';

%Student B
powerLines.ResidentialComplex.Proyect = 'Residential Complex';
powerLines.ResidentialComplex.Voltage = 400; % Volts
powerLines.ResidentialComplex.VoltageLevel = 'LV';
powerLines.ResidentialComplex.Application = 'Distribution';
powerLines.ResidentialComplex.Topology = 'Underground';
powerLines.ResidentialComplex.TypicalConductor = 'PVC Insulated Copper';

%Student C
    %Linea de Media Tension
powerLines.CommercialCentreMV.Proyect = 'Commercial Centre (MV)';
powerLines.CommercialCentreMV.Voltage = 20000; % Volts
powerLines.CommercialCentreMV.VoltageLevel = 'MV';
powerLines.CommercialCentreMV.Application = 'Distribution';
powerLines.CommercialCentreMV.Topology = 'Overhead';
powerLines.CommercialCentreMV.TypicalConductor = 'XLPE Insulated Aluminum';

    %Linea de Baja Tension
powerLines.CommercialCentreLV.Proyect = 'Commercial Centre (LV)';
powerLines.CommercialCentreLV.Voltage = 400; % Volts
powerLines.CommercialCentreLV.VoltageLevel = 'LV';
powerLines.CommercialCentreLV.Application = 'Service/Interior';
powerLines.CommercialCentreLV.Topology = 'Underground';
powerLines.CommercialCentreLV.TypicalConductor = 'XLPE Insulated Copper';

% Display the database in the command window
disp('Commercial Center Line Database:');
disp(powerLines.IndustrialFacility)
disp(powerLines.ResidentialComplex)
disp(powerLines.CommercialCentreMV)
disp(powerLines.CommercialCentreLV)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a visual comparison chart
figure; % Create a new window for the plot
voltages = [powerLines.IndustrialFacility.Voltage, powerLines.ResidentialComplex.Voltage, powerLines.CommercialCentreMV.Voltage, powerLines.CommercialCentreLV.Voltage];
labels = {'Industrial Facility', 'Residential Complex', 'Commercial Centre (Medium Voltage)', 'Commercial Centre (Low Voltage)'};
bar(voltages); % Create a bar chart
set(gca, 'xticklabel', labels);
title('Voltage Levels in the Different Electrical Instalacion Proyects');
ylabel('Voltage (V)');