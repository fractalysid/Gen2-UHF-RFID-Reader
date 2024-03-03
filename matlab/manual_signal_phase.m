clc
clear all
close all

%f1 = fopen('../data/source','rb');
f1 = fopen('../data/decoder','rb');
x_inter_1 = fread(f1, 'float32');

% if data is complex
x1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

%A1 = x1(32255:33423);
%A2 = x1(47132:48295);
%A3 = x1(62200:63314);
%A4 = x1(77316:78437);

%x2 = vertcat(A1, A2, A3, A4);
x2 = x1;

x2r = real(x2);
x2i = imag(x2);

%figure
%hold on
%plot(x2r, "b");
%plot(x2i, "r");

%figure
%plot(x2r, x2i, "o");
%axis equal
%figure
%plot(abs(x2));
%figure
%plot(angle(x2))

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
       'Location','NE')
title 'Cluster Assignments and Centroids'
hold off

dV = C(1,:) - C(2,:);

rssi = 20*log(norm(dV))
phase = atan(dV(2) / dV(1));
degree = phase * 180/pi;
% Direction agnostic
if (degree < 0)
     degree = degree + 180;
end
degree
