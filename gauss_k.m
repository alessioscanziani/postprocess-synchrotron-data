clear all
close all
clc

file_path = 'E:\Diamond19\processing\DK_WF1\1280x1284x1080\curv_ia';


%% Gauss curvature go
% list of names data of mean curvatures (km)
% change folder
file_list = dir([file_path '\gauss_ow']);
% read names in the folder
names = {file_list.name}';
% search for files of km
mean_ow = 'gauss_curvature';
mean_ow_bool = regexp(names, mean_ow);
bool_ow = zeros(length(mean_ow),1);
for i = 1:length(mean_ow_bool)
    bool_ow(i) = isempty(mean_ow_bool{i})==0;
end
gauss_curv_ow = names(find(bool_ow));
% list of names data of distances of km
% change folder
file_list = dir([file_path '\gauss_dist_ow']);
% read names in the folder
names = {file_list.name}';
% search for files of curvature
% list of names data of distances
dist_ow = 'dist_gcurvature';
dist_ow_bool = regexp(names, dist_ow);
for i = 1:length(dist_ow_bool)
    bool_ow(i) = isempty(dist_ow_bool{i})==0;
end
dist_curv_ow = names(find(bool_ow));

% Load the data
% km
gk_ow = cell(length(gauss_curv_ow),1);
for i = 1:length(gauss_curv_ow)
    gk_ow{i} = load_files_ow_g(gauss_curv_ow{i},0);
end
% distance
d_ow = cell(length(dist_curv_ow),1);
for i = 1:length(dist_curv_ow)
    d_ow{i} = load_files_ow_g(dist_curv_ow{i},1);
end

%% Post-process
% Compute mean and std
for i = 1:length(gk_ow)
    for j = 1:6
        gk_ow_dist{i,j} = gk_ow{i}(d_ow{i} > j-1);
        mean_gk_ow(i,j) = mean(gk_ow_dist{i,j});
        std_gk_ow(i,j) = std(gk_ow_dist{i,j});
    end
end

% normalize values
% dimensions of voxels
side_vx = 3.56e-3;
volume_vx = side_vx^3;
n_voxels = 1280 * 1284 * 1080;
mask = 0.53;
volume_tot = volume_vx * n_voxels * mask;

% normalize
gk_si = mean_gk_ow ./ side_vx^2;


load volumefraction
d = days(volumefraction.End_time(1:3:end));
mins = minutes(d);
min = mins - mins(1);

% plot curvature
figure(1)
for j = 1:length(std_gk_ow(1,:))
    plot(min, gk_si(:,j),'--', 'LineWidth', 1)
    hold on
end
legend('ow 0','ow 1', 'ow 2',  'ow 3', 'ow 4', 'ow 5')
xlabel('time [min]')
ylabel('average gauss curvature')

% plot selected curvature
figure()
plot(min, -gk_si(:,6),'r', 'LineWidth', 1)
xlabel('Time [min]')
ylabel('Average Gaussian curvature [mm^{-2}]')
ax = gca;
ax.FontSize = 18;
ax.FontName = 'Times New Roman';

gk_si_end = gk_ow_dist{end-1,6}./side_vx^2;
figure()
histogram(gk_si_end,'Normalization','Probability')
xlabel('Gaussian curvature [mm^{-2}]')
ylabel('Normalized frequency')
ax = gca;
ax.FontSize = 18;
ax.FontName = 'Times New Roman';
ax.XLim = [-5000 5000];

