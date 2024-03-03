% Studio dello spettro del segnale, distinguendo rumore e dati

clc
clear all
close all

fi_1 = fopen('../data/source','rb');

x_inter_1 = fread(fi_1, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

% Seleziono la parte che contiene solo il rumore
x_noise = x_1(89751:106143);

% Seleziono la parte che contiene query, rn16, ack e epc
x_data = x_1(28563:44756);

%-----------------------------
% Parametri base
fs = 2e6;       % Frequenza di campionamento (2MHz)
N = fs/128;     % Lunghezza del filtro (numero di coefficienti)
%-------------------------------

% Calcola la FFT del segnale
N1 = length(x_data);
N2 = length(x_noise);

X1 = fft(x_data);
X2 = fft(x_noise);

freqs1 = (0:N1-1)*(fs/N1);       % Frequenze corrispondenti
freqs2 = (0:N2-1)*(fs/N2);       % Frequenze corrispondenti

amplitude_spectrum1 = abs(X1)/N1;     % Spettro di ampiezza
amplitude_spectrum2 = abs(X2)/N2;     % Spettro di ampiezza

phase_spectrum1 = angle(X1)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum2 = angle(X2)*(180/pi); % Spettro di fase (in gradi)

% Visualizza la FFT
% Ampiezza
figure

subplot(2,1,1);
hold on
plot(freqs1, amplitude_spectrum1, "b", "DisplayName", "Data");
plot(freqs2, amplitude_spectrum2, "r", "DisplayName", "Noise");
title('Spettro di Ampiezza');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza (dB)');
xlim([0, 40000]);
legend("Location", "northeast");

subplot(2,1,2);
hold on
plot(freqs1, 20*log10(amplitude_spectrum1), "b", "DisplayName", "Data");
plot(freqs2, 20*log10(amplitude_spectrum2), "r", "DisplayName", "Noise");
title('Spettro di Ampiezza (dB)');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza (dB)');
xlim([0, 40000]);
legend("Location", "northeast");

% Fase
%figure
%plot(freqs1, phase_spectrum1, "b");
%hold on
%plot(freqs2, phase_spectrum2, "r");
%title('Spettro di Fase');
%xlabel('Frequenza (Hz)');
%ylabel('Fase (gradi)');

%---------------------------------------

%figure
%hold on
%plot(abs(x_data), "b", "DisplayName", "Data");
%plot(abs(x_noise), "r", "DisplayName", "Noise");
%legend("Location", "northeast");
