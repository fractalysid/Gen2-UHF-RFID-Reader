clc
clear all
close all

fi_1 = fopen('../data/source','rb');
x_inter_1 = fread(fi_1, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

x_2 = x_1(31900:33020);

%plot(abs(x_1))
figure
plot(abs(x_2))

figure
plot(real(x_2), imag(x_2), "o");
axis equal

rssi = 10*log(real(x_2).^2 + imag(x_2).^2);

%[A] = scatterplot(x_2, 24)
X = [real(x_2), imag(x_2)];

figure
plot(X(:,1),X(:,2),'.');

opts = statset('Display','final');
[idx,C] = kmeans(X,2,'Distance','cityblock',...
    'Replicates',5,'Options',opts);

figure
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
hold off
q
dV = C(1,:) - C(2,:);

rssi = 20*log(norm(dV));
phase = atan(dV(2) / dV(1));
