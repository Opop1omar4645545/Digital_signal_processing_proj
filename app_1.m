clear all;
clc;

fig = uifigure("Name", "Detect Heart Block", "Position", [138 135 800 411], 'Color', [.7 .7 .7]);
pnl = uipanel(fig, "Position", [20 70 250 250], 'BackgroundColor', [0.3 0.3 0.3]);
labl = uilabel(pnl, "Text", "Enter file name", "Position", [40 220 200 20], 'FontSize', 15, 'FontColor', [0 0 1]); 
input = uieditfield(pnl, "Position", [60 180 120 20]);
axes = uiaxes(fig, "Position", [270 30 500 300], "GridLineStyle", "-", 'Color', [0.3 0.3 0.3]); 
grid(axes, "on");
res = uilabel(pnl, "Position", [70 20 250 20], "Visible", "off", 'FontSize', 12, 'FontColor', "red"); 
btn2 = uibutton(pnl, "Text", "Browse", "Position", [70 140 100 20], "ButtonPushedFcn", @(btn2, event) brow(input), 'BackgroundColor', [0.2 0.8 0.2], 'FontColor', [1 1 1]); % Green button
btn = uibutton(pnl, "push", "Text", "Check", "Position", [70 50 100 40], 'ButtonPushedFcn', @(btn, event) plotButtonPushed(axes, input, res), 'FontSize', 15, 'BackgroundColor', [1 0.5 0.2], 'FontColor', [1 1 1]); % Orange button

function brow(input)
    [file, path] = uigetfile('*.mat');
    input.Value = file;
end

function plotButtonPushed(ax, input, res)
    try
        str = input.Value;
        s = load(str);
    catch
        msgbox("Choose a file first", 'Error', 'error');
        return;
    end

    try
        z = s.x;
    catch
        z = s.val;
    end
    detrendedECG = detrend(z, 5);
    ismax = islocalmax(detrendedECG, 'MinProminence', 150);
    
    % Check for Heart Block pattern
    heartBlock = any(detrendedECG(ismax) > 0.1);  % Adjust the threshold as needed
    
    if length(find(ismax)) > 35
        ismax = islocalmax(detrendedECG, 'MinProminence', 950);
        maxIndices = find(ismax);
        msPerBeat = mean(diff(maxIndices));
        heartRate = 60 * (1000 / msPerBeat);
    else
        maxIndices = find(ismax);
        msPerBeat = mean(diff(maxIndices));
        heartRate = 60 * (250 / msPerBeat);
    end
   
    plot(ax, detrendedECG, 'Color', [109 185 226] / 255, 'DisplayName', 'Input data')
    hold(ax, 'on')
    hold(ax, 'off')
    xlabel(ax, 'milliseconds', 'Color', [0 0 0]) % Black axis labels
    ylabel(ax, 'millivolts', 'Color', [0 0 0]) % Black axis labels

    % Output result with Heart Block indication
    if heartBlock
        res.Text = "Heart Block detected! 🎉"; % Exciting emoji
    else
        res.Text = "No evidence of Heart Block";
    end
    res.Visible = "on";
    
    % Add heart rate text with red color
    text(ax, 0.5, 1.1, sprintf('Heart Rate: %.2f bpm', heartRate), ...
        'Units', 'Normalized', 'Color', 'red', 'HorizontalAlignment', 'center','FontSize',15);
end
