%% This code reads data for computing thermodynamic contact angle, computes and plots versus time

clear all
close all
clc

load data_theta_t

d = days(volumefraction.End_time(1:3:end));
mins = minutes(d);
min = mins - mins(1);

km_dist1 = -km_si(:,6);
phi = 1-(volumefraction.fraction(3:3:end))./(volumefraction.fraction(1:3:end)+(volumefraction.fraction(2:3:end))+(volumefraction.fraction(3:3:end)));
Sw = volumefraction.Si(2:3:end);
So = volumefraction.Si(1:3:end);

for i = 1:length(ia_os_norm)-1
    km_mean(i) = mean([km_dist1(i+1),km_dist1(i)]);
    phi_mean(i) = mean([phi(i+1),phi(i)]);
    DSw(i) = Sw(i+1) - Sw(i);
    DSo(i) = So(i+1) - So(i);
    Da_sw(i) = ia_sw_norm(i+1) - ia_sw_norm(i);
    Da_so(i) = ia_os_norm(i+1) - ia_os_norm(i);
    Da_ow(i) = ia_ow_norm(i+1) - ia_ow_norm(i);
    cos_theta_t_w(i) = (km_mean(i)*phi(i)*DSw(i) + Da_ow(i))./Da_sw(i);
    cos_theta_t_o(i) = (km_mean(i)*phi(i)*DSo(i) + Da_ow(i))./Da_so(i);
end

theta_t_w = acosd(cos_theta_t_w);
theta_t_o = acosd(cos_theta_t_o);
Da_sw = Da_sw';
Da_ow = Da_ow';

figure()
plot(min(1:end-2),Da_sw(1:end-1),'k','Linewidth',1)
hold on
plot(min(1:end-2),Da_ow(1:end-1),'b','Linewidth',1)
legend('\Delta a_{1s}','\Delta a_{12}')
xlabel('Time [min]')
ylabel('\Delta a [mm^{-1}]')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';
ax.XLim = [0 80]

figure()
theta_t_movav = movmean(theta_t_w, 5);
plot(min(1:20),theta_t_w(1:20),'LineWidth',1)
hold on
plot(min(1:20),theta_t_movav(1:20),'--','LineWidth',1)
xlabel('Time [min]')
ylabel('Thermodynamic contact angle [\circ]')
legend('Data','Moving average','Location','Northwest')
ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';
