function I3_PlotLoadingDiagram(results)
% =========================================================================
% FUNCTION: I3_PlotLoadingDiagram (Corrected)
% =========================================================================
% MODIFIED: Renamed function from 'I3_PlotLoadingDiagramResults' for
% consistency.
% =========================================================================
figure;
hold on;
box on;
grid on;

% --- Prepare data for plotting ---
% Start with the current from source A
distances = [0];
currents = [results.Ia];

% Add points for each load, showing the current before and after the drop
current_in_segment = results.Ia;
for i = 1:length(results.loads)
    % Point just before the load
    distances(end+1) = results.loads(i).distance;
    currents(end+1) = current_in_segment;
    
    % Update the current after serving the load
    current_in_segment = current_in_segment - results.loads(i).current;
    
    % Point just after the load to create the vertical drop
    distances(end+1) = results.loads(i).distance;
    currents(end+1) = current_in_segment;
end

% Add the final point at Source B
distances(end+1) = results.L_total;
% The remaining current should be equal to -Ib
currents(end+1) = -results.Ib; 

% --- Create the Plot ---
plot(distances, currents, '-r', 'LineWidth', 2);

% Add a horizontal line at y=0 to show the current division point
line([0, results.L_total], [0, 0], 'Color', 'c', 'LineStyle', '--');

% Annotate start and end currents
text(0, results.Ia, sprintf('  Ia = %.1f A', results.Ia), 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
text(results.L_total, -results.Ib, sprintf('  Ib = %.1f A  ', -results.Ib), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontWeight', 'bold');

% --- Formatting ---
title('Network Loading Diagram');
xlabel('Distance from Source A (m)');
ylabel('Current (A)');
ylim_max = max(abs(currents)) * 1.2;
if ylim_max == 0, ylim_max = 1; end
ylim([-ylim_max, ylim_max]);
hold off;

end
