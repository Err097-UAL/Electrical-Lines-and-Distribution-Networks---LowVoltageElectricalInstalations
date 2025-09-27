% Create a structure for conductor properties
Conductors = struct();

%data for Copper
Conductors.Copper.name = 'Copper';
Conductors.Copper.conductivity = 56; % in m/(Ohm*mm^2)
Conductors.Copper.cost_per_km = 1200; % Example cost in Euros
Conductors.Copper.temp_coeff = 0.0039; % Alpha coefficient for resistance
Conductors.Copper.tensileStrenghtMax = 450; 
Conductors.Copper.tensileStrenghtMin= 300;
Conductors.Copper.youngModuleMax = 125;
Conductors.Copper.youngModuleMin = 115;

%data for Aluminum
Conductors.Aluminum.name = 'Aluminum';
Conductors.Aluminum.conductivity = 36;
Conductors.Aluminum.cost_per_km = 700; % Example cost
Conductors.Aluminum.temp_coeff = 0.0040;
Conductors.Aluminum.tensileStrenghtMax = 160;
Conductors.Aluminum.tensileStrenghtMin = 200;
Conductors.Aluminum.youngModuleMax = 70;
Conductors.Aluminum.youngModuleMin = 60;


%data for Aluminum-Steel Composite
Conductors.ACSR.name = 'Aluminum-Steel (ACSR)';
Conductors.ACSR.conductivity = 34; % Effective conductivity is slightly lower
Conductors.ACSR.cost_per_km = 850; % More expensive than plain aluminum
Conductors.ACSR.temp_coeff = 0.0040;
Conductors.ACSR.tensileStrengthMax = 1500;
Conductors.ACSR.tensileStrengthMin = 500;
Conductors.ACSR.youngModuleMax = 75;
Conductors.ACSR.youngModuleMin = 115;
 

% Display the data
disp('Conductor Database:');
disp(Conductors.Copper);
disp(Conductors.Aluminum);
disp(Conductors.ACSR);


