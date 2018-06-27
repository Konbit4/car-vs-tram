function [ output ] = plot_assignment( tram_params, car_params, general_params, drv_mission, pass_flow, tram_simulation_results, car_simulation_results, fleet_info_output, cost_estimation_output)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%%
figure('Name','Power profile tram')
subplot(211)
plot(tram_simulation_results.time{1}, (tram_simulation_results.P_traction_W{1}+tram_simulation_results.P_brake_W{1})/1000)
title('A to B')
ylabel('Power [kW]')
xlabel('Time [s]')
grid on

subplot(212)
plot(tram_simulation_results.time{2}, (tram_simulation_results.P_traction_W{2}+tram_simulation_results.P_brake_W{2})/1000)
title('B to A')
ylabel('Power [kW]')
xlabel('Time [s]')
grid on

%%
figure('Name','Power profile car')
subplot(211)
plot(car_simulation_results.time{1}, (car_simulation_results.P_traction_W{1}+car_simulation_results.P_brake_W{1})/1000)
title('A to B')
ylabel('Power [kW]')
xlabel('Time [s]')
grid on

subplot(212)
plot(car_simulation_results.time{2}, (car_simulation_results.P_traction_W{2}+car_simulation_results.P_brake_W{2})/1000)
title('B to A')
ylabel('Power [kW]')
xlabel('Time [s]')
grid on

%%
figure('Name','Speed profile tram')
subplot(211)
plot(tram_simulation_results.time{1}, tram_simulation_results.speed_kmh{1})
title('A to B')
ylabel('Speed [km/h]')
xlabel('Time [s]')
grid on

subplot(212)
plot(tram_simulation_results.time{2}, tram_simulation_results.speed_kmh{2})
title('B to A')
ylabel('Speed [km/h]')
xlabel('Time [s]')
grid on

%%
figure('Name','Speed profile car')
subplot(211)
plot(car_simulation_results.time{1}, car_simulation_results.speed_kmh{1})
title('A to B')
ylabel('Speed [km/h]')
xlabel('Time [s]')
grid on

subplot(212)
plot(car_simulation_results.time{2}, car_simulation_results.speed_kmh{2})
title('B to A')
ylabel('Speed [km/h]')
xlabel('Time [s]')
grid on


%%
dy = 0:365*80;
daily_cost_grid = cost_estimation_output.fleet_cost_dy * dy;
dy_size = size(dy);
n_size = size(cost_estimation_output.fleet_cost_dy);

tram_purchase_grid = ceil(ones(n_size) * dy / 365 ./ ((general_params.l_life_tram_yr * ones(n_size)) * ones(dy_size)));
car_purchase_grid = ceil(ones(n_size) * dy /365 ./ (cost_estimation_output.l_life_car_yr * ones(dy_size)));
car_purchase_grid(isnan(car_purchase_grid)) = 0; % When using only trams, no cars are purchased

Z = ((cost_estimation_output.trams_cost_purchase' * ones(dy_size)) .* tram_purchase_grid ...
	+ (cost_estimation_output.cars_cost_purchase' * ones(dy_size)) .* car_purchase_grid ...
	+ daily_cost_grid) *1e-6;

% Minimum cost
[ZM,I] = min(Z);
YM = nan(size(I));
for ii = 1:length(I)
	YM(ii) = fleet_info_output.num_trams(I(ii));
end

[XG,YG] = meshgrid(dy/365, fleet_info_output.num_trams);
figure('Name','Accumulated costs')
surf(XG, YG, Z, 'EdgeColor', 'None')
hold on
hnd=plot3(dy/365,YM,ZM,'r','LineWidth',1.5);
legend(hnd,'Cost minimizing mix','Location','best')
xlabel('Time [years]')
ylabel('Number of trams in mix')
zlabel('Cost [MSEK]')

%%
figure('Name','Isocost levels')
[Cp,hp] = contour(XG, YG, Z, 20, 'ShowText', 'on');
xlabel('Time [years]')
ylabel('Number of trams in mix')
clabel(Cp,hp,'LabelSpacing',1000)
title('Isocost levels [MSEK]')
grid on
hold on
hnd=plot(dy/365,YM,'r','LineWidth',1.5);
legend(hnd,'Cost minimizing mix','Location','northwest')

end

