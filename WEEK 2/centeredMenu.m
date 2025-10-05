function choice = centeredMenu(title, varargin)
% =========================================================================
% FUNCTION: centeredMenu (V2 - Robust UI Figure)
% =========================================================================
% Description:
% Creates a custom, modal dialog box that is always centered on the screen.
% This version uses uifigure for robust control over position and behavior,
% avoiding issues with the legacy 'menu' function.
%
% Inputs:
%   title    - The string for the title of the menu box.
%   varargin - A variable number of strings for the menu options.
%
% Output:
%   choice   - The index of the selected option (1, 2, 3...), or 0 if
%              the user closes the window.
% =========================================================================

% --- Define Figure and Button Geometry ---
numButtons = length(varargin);
figHeight = 50 + numButtons * 40 + 20; % Top padding + buttons + bottom padding
figWidth = 350;
buttonHeight = 30;
buttonWidth = figWidth - 60; % With padding on each side
buttonX = (figWidth - buttonWidth) / 2;

% --- Create a blank, invisible figure ---
fig = uifigure('Visible', 'off', ...
               'Name', title, ...
               'WindowStyle', 'modal', ... % Blocks interaction with other windows
               'Resize', 'off', ...
               'NumberTitle', 'off', ...
               'MenuBar', 'none', ...
               'ToolBar', 'none');

% --- Center the Figure on the Screen ---
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);
figX = (screenWidth - figWidth) / 2;
figY = (screenHeight - figHeight) / 2;
fig.Position = [figX, figY, figWidth, figHeight];

% --- Create Buttons for Each Option ---
for i = 1:numButtons
    % Position buttons from the top of the figure down
    buttonY = figHeight - 50 - ((i-1) * 40);
    
    uibutton(fig, 'Text', varargin{i}, ...
             'Position', [buttonX, buttonY, buttonWidth, buttonHeight], ...
             'ButtonPushedFcn', @(btn, event) buttonCallback(i));
end

% --- Store the choice in the figure's app data (safer than global) ---
fig.UserData.choice = 0; % Default to 0 (if window is closed)

% --- Define the Nested Callback Function ---
    function buttonCallback(buttonIndex)
        % When a button is pushed, store its index and resume the script
        fig.UserData.choice = buttonIndex;
        uiresume(fig);
    end

% --- Make the figure visible and wait for user input ---
fig.Visible = 'on';
uiwait(fig); % Pauses execution until uiresume is called or fig is closed

% --- Retrieve the choice and delete the figure to clean up ---
if isvalid(fig)
    choice = fig.UserData.choice;
    delete(fig);
else
    % This handles the case where the user closes the window with the 'X'
    choice = 0;
end

end

