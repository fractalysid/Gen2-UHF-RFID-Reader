clc
clear all
close all

% Numero di misure per ogni setup
measurements = 10;
% Numero di differenti setup
setups = 10;

path_prefix = "../../data/measurements";

% Set to true to use "decoder" file instead of "source" file
decoder = true;

if decoder
     file_prefix = "decoder";
else
     file_prefix = "source"
end

rssi = zeros(setups, measurements);
phase = zeros(setups, measurements);

% più o meno l'rn16 si è trovato in queste posizioni per tutte le misure fatte
rn16_idx = [32000]; %, 47000, 62000, 77200, 92200];
rn16len = 1150;
epc_idx = [36300];
epclen = 6750;
% True if we analyse the entire signal and not only the RN16
complete_analysis = false;
% else only use RN16 or EPC
% if true, use epc, otherwise use rn16
epc = true;

% Set to true to plot specific signals
plot_signals = false;
plot_rn16 = false;
plot_scatter = true;

% Avoids doing calculations, for debug purposes
calculate = true;

for s = 1:setups

     % Plot signals in time
     if plot_signals || plot_scatter
          figure(s);
     end
     for m = 1:measurements

          path = sprintf('%s/%d/%s%d_%d', path_prefix, s, file_prefix, s, m);
          fprintf('Reading file: %s\n', path);

          % Read file
          f1 = fopen(path,'rb');

          % Extract samples
          x_ = fread(f1, 'float32');

          % Create array of complex values
          x = x_(1:2:end) + 1i*x_(2:2:end);

          % Plot signals in time
          if plot_signals
               subplot(ceil(sqrt(measurements)), floor(sqrt(measurements)), m);
               plot(abs(x), "b");
               xlim([0, 260000]);
          end

          RN16 = zeros(rn16len * length(rn16_idx),1);
          EPC = zeros(epclen * length(epc_idx), 1);

          if ~complete_analysis && ~decoder
               % Extract rn16 samples...
               for i = 1:length(rn16_idx)
                    start = rn16_idx(i);
                    stop = start + rn16len;
                    part = x(start:stop);
                    RN16 = vertcat(RN16, part );
               end

               % Extract epc samples...
               for i = 1:length(epc_idx)
                    start = epc_idx(i);
                    stop = start + epclen;
                    part = x(start:stop);
                    EPC = vertcat(EPC, part );
               end
          end


          % ... and separate them in real and imaginary part for convenience
          if ~complete_analysis && ~decoder
               if epc
                    xr = real(EPC);
                    xi = imag(EPC);
               else
                    xi = imag(RN16);
                    xr = real(RN16);
               end
          else
               xr = real(x);
               xi = imag(x);
          end

          % Plot RN16
          %if plot_rn16 && ~complete_analysis
          %     figure
          %     hold on
          %     %plot(xr, "b");
          %     %plot(xi, "r");
          %     scatter(xr, xi);
          %end

          X = [xr, xi];

          if calculate
               opts = statset('Display','final');
               [idx,C] = kmeans(X,2, 'Distance','cityblock',...
               'Replicates',10, 'Start', 'uniform', 'Options',opts);
          end

          % Set to true to show scatter plots
          if calculate && plot_scatter
               %figure
               subplot(ceil(sqrt(measurements)), floor(sqrt(measurements)), m);
               grid on
               plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
               hold on
               plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
               plot(C(:,1),C(:,2),'kx',...
                    'MarkerSize',15,'LineWidth',3)
               %legend('Cluster 1','Cluster 2','Centroids',...
               %     'Location','NE')
               title 'Cluster Assignments and Centroids'
               hold off
          end

          if calculate
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

end

% only print if we calculated the values
if calculate
     % Print header
     fprintf('\nRSSI (dB)\t');
     for i = 1:measurements
          fprintf("%-5d\t", i);
     end
     fprintf("\n");

     % Print data
     for i = 1:setups
          % print header
          fprintf('%-10d\t', i);
          for k = 1:measurements
               fprintf("%-4.1f\t", rssi(i, k));
          end
          fprintf("\n");
     end

     figure
     hold on
     grid on
     for s = 1:setups
          row = rssi(s, :);
          plot(row);
     end
     title("RSSI(db)");

     %----------------------------------------------

     % Print header
     fprintf('\nPHASE (grad)\t');
     for i = 1:measurements
          fprintf("%-5d\t", i);
     end
     fprintf("\n");

     % Print data
     for i = 1:setups
          % print header
          fprintf('%-10d\t', i);
          for k = 1:measurements
               fprintf("%-4.1f°\t", phase(i, k));
          end
          fprintf("\n");
     end

     figure
     hold on
     grid on
     for s = 1:setups
          row = phase(s, :);
          plot(row);
     end
     title("Phase(deg)");

end
