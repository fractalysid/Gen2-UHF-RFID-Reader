clc
clear all
close all

f1 = fopen('../data/source','rb');
x_inter_1 = fread(f1, 'float32');

% if data is complex
x1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

x1 = x1(1:120000);

fs = 2e6;

% Calcolo la derivata
dx = x1(2) - x1(1);
dx1 = diff(x1) / (1/fs);
dx1_median = movmean(abs(dx1), 20);
%dx1_hilb = abs(hilbert(abs(dx1_median)));
[dx1_env, ~] = envelope(abs(dx1), 5, "peak");

x1_mean = mean(abs(x1));

% Filtro passa basso
N = 1000;
fc = 1200;
% Normalizzazione
Wn = fc / (fs/2);
Flow = fir1(N, Wn, "low");

y1 = filter(Flow, 1, dx1_env);

%------------------------------------
% Scorre i campioni e cerca gli RN16 e gli EPC

min_thr = 1e4;
max_thr = 2e4;

% Trova gli indici dove la derivata supera la soglia
%idx_over_thr = find(abs(dx1) > min_thr & abs(dx1) < max_thr);

% Inizializza una matrice per salvare le parti dell'array sopra la soglia
over_thr= [];

% Scansiona gli indici trovati e salva le parti dell'array sopra la soglia
%for i = 1:length(idx_over_thr)
%    index = idx_over_thr(i);
%    part = dx1();
%    over_thr = [over_thr; part];
%end

figure
hold on
plot(abs(x1), "b");
plot(abs(y1), "r");

return

A1 = x1(32079:33196);
A2 = x1(47066:48202);
A3 = x1(62215:63369);
A4 = x1(77267:78436);
A5 = x1(92160:93303);

x2 = vertcat(A1, A2, A3, A4, A5);

x2r = real(x2);
x2i = imag(x2);

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
       'Location','NE')
title 'Cluster Assignments and Centroids'
hold off

dV = C(1,:) - C(2,:);

rssi = 20*log(norm(dV))
phase = atan(dV(2) / dV(1));
degree = phase * 180/pi
