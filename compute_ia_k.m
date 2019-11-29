%% This code reads curvature and interfacial data computed in Avizo, post-process them and plot versus time

clear all
close all
clc

file_path = 'E:\Diamond19\processing\DK_WF1\1280x1284x1080\curv_ia';


%% Mean curvature between oil and water
% list of names data of mean curvatures (km)
% change folder
file_list = dir([file_path '\meank_ow']);
% read names in the folder
names = {file_list.name}';
% search for files of km
mean_ow = 'mean_curvature';
mean_ow_bool = regexp(names, mean_ow);
bool_ow = zeros(length(mean_ow),1);
for i = 1:length(mean_ow_bool)
    bool_ow(i) = isempty(mean_ow_bool{i})==0;
end
mean_curv_ow = names(find(bool_ow));

% list of names data of distances of km
% change folder
file_list = dir([file_path '\meank_dist_ow']);
% read names in the folder
names = {file_list.name}';
% search for files of curvature
% list of names data of distances
dist_ow = 'dist_mcurvature';
dist_ow_bool = regexp(names, dist_ow);
for i = 1:length(dist_ow_bool)
    bool_ow(i) = isempty(dist_ow_bool{i})==0;
end
dist_curv_ow = names(find(bool_ow));

% Load the data
% km
km_ow = cell(length(mean_curv_ow),1);
for i = 1:length(mean_curv_ow)
    km_ow{i} = load_files_ow(mean_curv_ow{i},0);
end
% distance
d_ow = cell(length(dist_curv_ow),1);
for i = 1:length(dist_curv_ow)
    d_ow{i} = load_files_ow(dist_curv_ow{i},1);
end

%% Interfacial area
% list of names data of ia ow
% change folder
file_list = dir([file_path '\area_csv_ow']);
% read names in the folder
names = {file_list.name}';
% search for files of ia ow
% list of names data of ia ow
ia_ow_name = 'interfacial_area_ow';
ia_ow_bool = regexp(names, ia_ow_name);
for i = 1:length(ia_ow_bool)
    bool_ow_ia(i) = isempty(ia_ow_bool{i})==0;
end
ia_ow = names(find(bool_ow_ia));

% Load the data
ia_ow_data = zeros(length(ia_ow),1);
for i = 1:length(ia_ow)
    ia_ow_data(i) = csvread([file_path '\area_csv_ow\' ia_ow{i}]);
end

%% Post-process
% Compute mean and std
for i = 1:length(km_ow)
    for j = 1:6
        km_ow_dist{i,j} = km_ow{i}(d_ow{i} > j-1);
        mean_km_ow(i,j) = mean(km_ow_dist{i,j});
        std_km_ow(i,j) = std(km_ow_dist{i,j});
    end
end

% normalize values
% dimensions of voxels
side_vx = 3.56e-3;
volume_vx = side_vx^3;
n_voxels = 1280 * 1284 * 1080;
mask = 0.53;
volume_tot = volume_vx * n_voxels * mask;

% normalize ia and km
ia_um2 = ia_ow_data .* side_vx.^2;
ia_ow_norm = ia_um2./ volume_tot;
km_si = mean_km_ow ./ side_vx;

load volumefraction
d = days(volumefraction.End_time(1:3:end));
mins = minutes(d);
min = mins - mins(1);

% plot curvature
figure(1)
for j = 1:length(std_km_ow(1,:))
    plot(min, mean_km_ow(:,j),'--', 'LineWidth', 1)
    hold on
end
legend('ow 0','ow 1', 'ow 2',  'ow 3', 'ow 4', 'ow 5')
xlabel('time [min]')
ylabel('average mean curvature')

% plot interfacial area
figure()
plot(min,ia_ow_norm,'LineWidth',1)
xlabel('Time [min]')
ylabel('Specific interfacial area [mm^{-1}]')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';

% plot selected curvature
figure()
plot(min, -km_si(:,1),'r', 'LineWidth', 1)
xlabel('Time [min]')
ylabel('Average mean curvature [mm^{-1}]')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';

% plot saturations
phi = 1-(volumefraction.fraction(3:3:end))./(volumefraction.fraction(1:3:end)+(volumefraction.fraction(2:3:end))+(volumefraction.fraction(3:3:end)));
figure()
plot(min, volumefraction.Si(2:3:end),'b','LineWidth',1)
hold on
plot(min, volumefraction.Si(1:3:end),'r','LineWidth',1)
ylabel('Saturations [-]')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';
xlabel('Time [min]')
ylabel('S_i')
legend('S_w','S_o')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';

% plot capillary pressure
Pc = -km_si(:,5)*47;
figure()
plot(min, Pc,'r', 'LineWidth', 1)
xlabel('Time [min]')
ylabel('Capillary pressure [Pa]')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';

save curv_ia_data