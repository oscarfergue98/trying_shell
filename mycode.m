% mycode.m

clear all; clc; close all; 
set(0,'defaultTextInterpreter','latex');
set(groot, 'defaultaxesticklabelinterpreter', 'latex')
set(0,'defaultfigurecolor',[1 1 1])
set(groot, 'defaultLegendInterpreter','latex');
set(0, 'DefaultFigureRenderer', 'painters'); 


TAG = getenv('TAG');

if isempty(TAG), TAG = "test"; end

disp("Using TAG: " + TAG);

black_pattern = '-k'; 
red_pattern = '--r';

% Base paths
BASE_PATH = "C:/Users/cjgue/Documents/trying_shell_files";
MODEL_RUN_PATH    = fullfile(BASE_PATH, "model_runs", TAG);
INTERMEDIARY_DATA = fullfile(MODEL_RUN_PATH, "intermediary_data");
OUTPUT_DATA       = fullfile(MODEL_RUN_PATH, "output_data");
FINAL_PLOTS_PATH  = fullfile(MODEL_RUN_PATH, "plots");

% Example: read CSV
data_file = fullfile(INTERMEDIARY_DATA, "plots_data.xlsx");
data = readtable(data_file);


countries     = {"Argentina", "Brazil", "Ecuador", "Mexico", "South Africa"};
titles        = {"Argentina", "Brazil", "Ecuador", "Mexico", "South Africa"};
subplot_pos   = {1, 2, 3, 4, 5.5};

f = figure;
for i = 1:numel(countries)
    current_dat = data(strcmp(data.country, countries{i}), :);
    
    subplot(3, 2, subplot_pos{i})
    title(titles{i})
    hold on
    plot(current_dat.date, current_dat.gdp, black_pattern, 'LineWidth', 1.5)
    yyaxis right
    plot(current_dat.date, current_dat.real_rate, red_pattern, 'LineWidth', 1.5)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'r';
    grid on; grid minor
end

exportgraphics(f, fullfile(FINAL_PLOTS_PATH, "example_plot.png"), 'Resolution',300);

disp("MATLAB pipeline finished for TAG: " + TAG);