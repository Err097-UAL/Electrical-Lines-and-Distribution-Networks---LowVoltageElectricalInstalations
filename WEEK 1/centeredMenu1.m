function choice = centeredMenu1(title, varargin)
% =========================================================================
% FUNCTION: centeredMenu1 (V5 - Corrected and Aligned)
% =========================================================================
% Description:
% Creates a custom, modal dialog box that is always centered on the screen.
% This version has been corrected to match the filename `centeredMenu1.m`.
% =========================================================================

% --- Define Figure and Button Geometry ---
numButtons = length(varargin);
figHeight = 50 + numButtons * 40 + 20; % Top padding + buttons + bottom padding
figWidth = 450;
buttonHeight = 30;
buttonWidth = figWidth - 60;
buttonX = (figWidth - buttonWidth) / 2;

% --- Create a blank, invisible figure ---
fig = uifigure('Visible', 'off', 'Name', title, 'WindowStyle', 'modal', ...
               'Resize', 'off', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none');

% --- Center the Figure on the Screen ---
screenSize = get(0, 'ScreenSize');
fig.Position = [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight];

% --- Create Buttons for Each Option ---
for i = 1:numButtons
    buttonY = figHeight - 50 - ((i-1) * 40);
    uibutton(fig, 'Text', varargin{i}, ...
             'Position', [buttonX, buttonY, buttonWidth, buttonHeight], ...
             'ButtonPushedFcn', @(btn, event) buttonCallback(i));
end

fig.UserData.choice = 0; % Default to 0 if the window is closed

% --- Nested Function for GUI Button Clicks ---
% This function is defined inside the main function scope.
function buttonCallback(buttonIndex)
    % When a button is clicked, store its index and resume the UI flow.
    fig.UserData.choice = buttonIndex;
    uiresume(fig);
end

% --- Make the figure visible and wait for user interaction ---
fig.Visible = 'on';
uiwait(fig); % Pauses execution until uiresume is called or the figure is closed

% --- Return the choice and clean up ---
if isvalid(fig)
    % If the figure is still valid, it means a button was pressed.
    choice = fig.UserData.choice;
    delete(fig); % Close the figure window
else
    % If the figure is not valid, the user closed the window.
    choice = 0;
end

end % --- End of centeredMenu1 function ---
