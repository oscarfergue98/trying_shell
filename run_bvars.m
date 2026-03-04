%% Code to run BEAR

% Housekeeping

clear all; clc; close all; 
rng(14091998)
set(0,'defaultTextInterpreter','latex');
set(groot, 'defaultaxesticklabelinterpreter', 'latex')
set(0,'defaultfigurecolor',[1 1 1])
set(groot, 'defaultLegendInterpreter','latex');
set(0, 'DefaultFigureRenderer', 'painters');

%% Read data

TAG = getenv('TAG');
if isempty(TAG), TAG = "test"; end

disp("Using TAG: " + TAG);

BASE_PATH =  yaml.loadFile("config.yaml").data_path;
MODEL_RUN_PATH    = fullfile(BASE_PATH, "model_runs", TAG);
INTERMEDIARY_DATA = fullfile(MODEL_RUN_PATH, "intermediary_data");
OUTPUT_DATA       = fullfile(MODEL_RUN_PATH, "output_data");
FINAL_PLOTS_PATH  = fullfile(MODEL_RUN_PATH, "plots");

% Example: read CSV
data_file = fullfile(INTERMEDIARY_DATA, "final_developing.xlsx");
data = readtable(data_file);

%% Create BEAR file

s = BEARsettings('Panel', 'ExcelFile', data_file);

% Modify specifications

s.startdate = '2004q1'; 
s.enddate = '2019q4'; 
s.varendo = 'gdp consumption gfcf nx real_rate'; 
s.varexo = 'oil_price'; 
s.panel = 'Random_hierarchical'; 
s.plot = 0; 
s.unitnames = 'argentina brazil ecuador southafrica mexico'; 
s.It = 10000; 
s.Bu = 5000; 
s.FEVD = 0; 
s.F = 0; 
s.results_path = OUTPUT_DATA; 
s.workspace = 1; 
s.IRFperiods = 21; 
s.IRFt = 'Cholesky'; 

%% Run the model 
tStart = tic;
BEARmain(s)
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds/n', floor(tEnd/60), rem(tEnd,60));

%% Load the results 

load(fullfile(OUTPUT_DATA, 'results.mat'))
 

%% Code to plot IRFs from BEAR

argentina = irf_estimates(:,:,find(Units=="argentina")); 
brazil = irf_estimates(:,:,find(Units=="brazil")); 
ecuador = irf_estimates(:,:,find(Units=="ecuador")); 
mexico = irf_estimates(:,:,find(Units=="mexico")); 
southafrica = irf_estimates(:,:,find(Units=="southafrica")); 

mark1 = '-k'; 
mark2 = '--r'; 


%% Plot mean shock to own rate + country-specific responses 

shock_id = 5; 
titles = {'GDP', 'Consumption','GFCF', 'NX', 'Real Rate'}; 

figure

for jj = 1:4

subplot(2,2,jj)
hold on

patch([0:IRFperiods-1 fliplr(0:IRFperiods-1)], [ mean([argentina{jj, shock_id}(3,:);brazil{jj, shock_id}(3,:);ecuador{jj, shock_id}(3,:);...
    mexico{jj, shock_id}(3,:);southafrica{jj, shock_id}(3,:)]) ...
        fliplr( mean([argentina{jj, shock_id}(1,:);brazil{jj, shock_id}(1,:);ecuador{jj, shock_id}(1,:);...
    mexico{jj, shock_id}(1,:);southafrica{jj, shock_id}(1,:)]))], [.7 .7 .7], 'EdgeColor','none', 'FaceAlpha', 0.5)

plot(0:IRFperiods-1,  mean([argentina{jj, shock_id}(2,:);brazil{jj, shock_id}(2,:);ecuador{jj, shock_id}(2,:);...
    mexico{jj, shock_id}(2,:);southafrica{jj, shock_id}(2,:)]), '-ok', 'markersize',3, 'LineWidth',1.5)
plot(0:IRFperiods-1, argentina{jj, shock_id}(2,:), '--', 'LineWidth',1.5)
plot(0:IRFperiods-1, brazil{jj, shock_id}(2,:), '-', 'LineWidth',1.5)
plot(0:IRFperiods-1, ecuador{jj, shock_id}(2,:), '-.', 'LineWidth',1.5)
plot(0:IRFperiods-1, mexico{jj, shock_id}(2,:), ':', 'LineWidth',1.5)
plot(0:IRFperiods-1, southafrica{jj, shock_id}(2,:), 'LineWidth',1.5)


title(titles(jj), 'FontSize',12)
yline(0,'-k', 'LineWidth',1.5)
ylabel('\%')

legend('', 'Mean', 'AR', 'BR', 'EC', 'MX', 'ZA', ...
    'Location','Best', 'fontsize',6)
legend boxoff
grid on

end

print('-dpdf', fullfile(FINAL_PLOTS_PATH, 'irfs.pdf'))
