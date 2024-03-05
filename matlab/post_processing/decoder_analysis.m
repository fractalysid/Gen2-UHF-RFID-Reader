clc
clear all
close all

% Numero di misure per ogni setup
measurements = 4;
% Numero di differenti setup
setups = 4;

path_prefix = "../../data/measurements";
file_prefix = "decoder";

rssi = zeros(setups, measurements);
phase = zeros(setups, measurements);

% I file con i campioni misurati alla fine della catena sono disponibili solo per il setup 4
for s = 1:setups

     %figure(s);
     for m = 1:measurements

          path = sprintf('%s/%d/%s%d_%d', path_prefix, s, file_prefix, s, m);
          % Per i file catturati con i campioni alla fine della catena
          %path = sprintf('%s/%d/%s%d_%d_F', path_prefix, s, file_prefix, s, m);
          fprintf('Reading file: %s\n', path);

          % Read file
          f1 = fopen(path,'rb');

          % Extract samples
          x_ = fread(f1, 'float32');

          % Create array of complex values
          x = x_(1:2:end) + 1i*x_(2:2:end);

          % Separate them in real and imaginary part for convenience
          xr = real(x);
          xi = imag(x);

          X = [xr, xi];

          opts = statset('Display','final');
          [idx,C] = kmeans(X,2,'Distance','cityblock',...
          'Replicates',5,'Options',opts);

          figure
          %subplot(2, 2, m);
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

          rssi(s, m) = 20*log(norm(dV));
          rad = atan(dV(2) / dV(1));
          % Direction agnostic
          if (rad < 0)
               rad = rad + pi;
          end
          phase(s, m) = rad * 180/pi;

     end

end

% Definizione delle intestazioni delle colonne
intestazioni_colonne = {'Setup/Misura', '1', '2', '3', '4'};
% Definizione dei colori da usare nei grafici
colors = ["red", "blu", "green", "orange"];

fprintf('\nRSSI (dB)\n');

% Stampa delle intestazioni delle colonne
fprintf('%-10s\t%-5s\t%-5s\t%-5s\t%-5s\n', intestazioni_colonne{:});

% Stampa dei dati della tabella
for i = 1:size(rssi, 1)
    fprintf('%-10d\t%-2.1f\t%-2.1f\t%-2.1fs\t%-2.1f\n', i, rssi(i, :));
end

colors = ["red", "blu", "green", "magenta"];
figure
hold on
grid on
for s = 1:setups
     row = rssi(s, :);
     plot(row, colors(s));
end

%----------------------------------------------

fprintf('\nPHASE (grad)\n');

% Stampa delle intestazioni delle colonne
fprintf('%-10s\t%-5s\t%-5s\t%-5s\t%-5s\n', intestazioni_colonne{:});

% Stampa dei dati della tabella
for i = 1:size(phase, 1)
    fprintf('%-10d\t%-2.1f\t%-2.1f\t%-2.1f\t%-2.1f\n', i, phase(i, :));
end

figure
hold on
grid on
for s = 1:setups
     row = phase(s, :);
     plot(row, colors(s));
end
