clc
clear all
close all

Fs = 2e6

fi_1 = fopen('../data/source','rb');
fi_2 = fopen('../data/source_filtered', 'rb');

x_inter_1 = fread(fi_1, 'float32');
x_inter_2 = fread(fi_2, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);
x_2 = x_inter_2(1:2:end) + 1i*x_inter_2(2:2:end);

%x_1 = abs(x_1);
%x_2 = abs(x_2);

% Calcola la FFT del segnale
N1 = length(x_1);                    % Lunghezza del segnale
N2 = length(x_2);
X1 = fft(x_1);                       % Calcola la FFT
X2 = fft(x_2);
freqs1 = (0:N1-1)*(Fs/N1);       % Frequenze corrispondenti
freqs2 = (0:N2-1)*(Fs/N2);       % Frequenze corrispondenti
amplitude_spectrum1 = abs(X1)/N1;     % Spettro di ampiezza
amplitude_spectrum2 = abs(X2)/N2;     % Spettro di ampiezza
phase_spectrum1 = angle(X1)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum2 = angle(X2)*(180/pi); % Spettro di fase (in gradi)

% Visualizza la FFT
figure;
%subplot(2,1,1);
plot(freqs1, amplitude_spectrum1, "b");
hold on
plot(freqs2, amplitude_spectrum2, "r");
title('Spettro di Ampiezza');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
xlim([0, 40000]);

%subplot(2,1,2);
%plot(freqs1, phase_spectrum1, "b");
%hold on
%plot(freqs2, phase_spectrum2, "r");
%title('Spettro di Fase');
%xlabel('Frequenza (Hz)');
%ylabel('Fase (gradi)');
