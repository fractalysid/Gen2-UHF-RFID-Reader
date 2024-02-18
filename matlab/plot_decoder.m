clc
clear all
close all

f1 = fopen('../data/decoder','rb');
x_inter_1 = fread(f1, 'float32');

% if data is complex
x1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

% We have groups of 32 samples for every inventory round
% Let's calc the arithmetic mean of rssi and phase
rounds = round(length(x1)/32) - 1;
rssi = zeros(1, rounds);
phase = zeros(1, rounds);
degree = zeros(1, rounds);

for i = 1:rounds

    x2 = x1((i*32-32+1):(32*i));

    %plot(abs(x_1))
    %figure
    %plot(abs(x2))

    x2r = real(x2);
    x2i = imag(x2);

    %figure
    %plot(x2r, x2i, "o");
    %axis equal

    rssi = 10*log(x2r.^2 + x2i.^2);

    %[A] = scatterplot(x2, 24)
    X = [x2r, x2i];

    %figure
    %plot(X(:,1),X(:,2),'.');

    opts = statset('Display','final');
    [idx,C] = kmeans(X,2,'Distance','cityblock',...
        'Replicates',5,'Options',opts);

    %figure
    %plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
    %hold on
    %plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
    %plot(C(:,1),C(:,2),'kx',...
    %     'MarkerSize',15,'LineWidth',3)
    %legend('Cluster 1','Cluster 2','Centroids',...
    %       'Location','NW')
    %title 'Cluster Assignments and Centroids'
    %hold off

    dV = C(1,:) - C(2,:);

    rssi(i) = 20*log(norm(dV));
    phase(i) = atan(dV(2) / dV(1));
    degree(i) = phase(i) * 360/(2*pi);
end

rssi_mean = mean(rssi)
phase_mean = mean(phase);
phase_degree = phase_mean * 360/(2*pi)
