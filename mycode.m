% mycode.m

% Check if TAG variable already exists (passed from -batch)
if ~exist('TAG', 'var') || isempty(TAG)
    TAG = "test";   % default
end

disp("Using TAG: " + TAG);

% Base paths
BASE_PATH = "C:/Users/cjgue/Documents/trying_shell_files";
MODEL_RUN_PATH    = fullfile(BASE_PATH, "model_runs", TAG);
INTERMEDIARY_DATA = fullfile(MODEL_RUN_PATH, "intermediary_data");
OUTPUT_DATA       = fullfile(MODEL_RUN_PATH, "output_data");
FINAL_PLOTS_PATH  = fullfile(MODEL_RUN_PATH, "plots");

% Example: read CSV
data_file = fullfile(INTERMEDIARY_DATA, "cpi_gdp_df.csv");
data = readmatrix(data_file);

% Example: save plot headless
f = figure('Visible','off');
subplot(2,1,1)
plot(data(:,2)); axis tight
subplot(2,1,2)
plot(data(:,3)); axis tight
exportgraphics(f, fullfile(FINAL_PLOTS_PATH, "example_plot.png"), 'Resolution',300);
close(f);

disp("MATLAB pipeline finished for TAG: " + TAG);