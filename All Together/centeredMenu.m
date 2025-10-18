function choice = centeredMenu(title, varargin)
% =========================================================================
% FUNCTION: centeredMenu
% =========================================================================
% Description:
% Creates a standard MATLAB menu dialog box but positions it in the
% center of the screen for a better user experience.
% =========================================================================

% Create a temporary, invisible figure to get screen dimensions
fig = figure('Name', title, 'NumberTitle', 'off', 'MenuBar', 'none', ...
             'Units', 'pixels', 'Position', [0 0 400 150], 'Visible', 'off');
             
% Move the figure to the center of the screen
movegui(fig, 'center');

% Make the figure visible just before the menu is called
set(fig, 'Visible', 'on');

% Call the standard menu function
choice = menu(title, varargin{:});

% Close the temporary figure
close(fig);
end
