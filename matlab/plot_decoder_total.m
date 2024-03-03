clc
clear all
close all

f1 = fopen('../data/decoder','rb');
x_inter_1 = fread(f1, 'float32');

% if data is complex
x1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

x2r = real(x1);
x2i = imag(x1);

%figure
%plot(x2r, x2i, "o");
%axis equal

rssi = 10*log(x2r.^2 + x2i.^2);

%[A] = scatterplot(x1, 24)
X = [x2r, x2i];

%figure
%plot(X(:,1),X(:,2),'.');

opts = statset('Display','final');
[idx,C] = kmeans(X,2,'Distance','cityblock',...
'Replicates',5,'Options',opts);

figure
grid on
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
hold off

dV = C(1,:) - C(2,:);

rssi = 20*log(norm(dV))
phase = atan(dV(2) / dV(1));
degree = phase * 180/pi
