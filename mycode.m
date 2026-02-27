% Housekeeping

clear all; clc; close all; 
set(0,'defaultTextInterpreter','latex');
set(groot, 'defaultaxesticklabelinterpreter', 'latex')
set(0,'defaultfigurecolor',[1 1 1])
set(groot, 'defaultLegendInterpreter','latex');
set(0, 'DefaultFigureRenderer', 'painters');

TAG = getenv('TAG');

if isempty(TAG)
    TAG = "test";
    disp("No TAG provided, using default: " + TAG);
else
    disp("Using TAG: " + TAG);
end

% Base path
BASE_PATH = "C:/Users/cjgue/Documents/trying_shell_files";
MODEL_RUN_PATH    = fullfile(BASE_PATH, "model_runs", TAG);
INTERMEDIARY_DATA = fullfile(MODEL_RUN_PATH, "intermediary_data");
OUTPUT_DATA       = fullfile(MODEL_RUN_PATH, "output_data");
FINAL_PLOTS_PATH  = fullfile(MODEL_RUN_PATH, "plots");

% Example: save some data
data = readmatrix(fullfile(INTERMEDIARY_DATA, "cpi_gdp_df.csv"));


% Example: save a plot
f = figure('Visible', 'off');
subplot(2,1,1)
plot(data(:,2));
axis tight
subplot(2,1,2)
plot(data(:,3));
axis tight
exportgraphics(f, fullfile(FINAL_PLOTS_PATH, "example_plot.png"), 'Resolution',300);
close(f);

