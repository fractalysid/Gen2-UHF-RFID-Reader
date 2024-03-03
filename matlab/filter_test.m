clc
clear all
close all

% Definisci la frequenza di campionamento e la lunghezza del segnale
fs = 8000; % Frequenza di campionamento (Hz)
N = 1024; % Lunghezza del segnale

% Genera il segnale di prova (esempio)
t = (0:N-1) / fs; % Tempo (s)
f_signal = 200; % Frequenza del segnale (Hz)
signal = exp(1i * 2 * pi * f_signal * t); % Segnale puro
noise = 0.5 * (exp(1i * 2 * pi * 600 * t) + exp(1i * 2 * pi * 1200 * t)); % Componenti di disturbo
noisy_signal = signal + noise; % Segnale con disturbo

% Creazione del filtro
f_cutoff = [550 1250]; % Frequenze di taglio del filtro (Hz)
f_norm = f_cutoff / (fs/2); % Normalizzazione delle frequenze
filter_order = 50; % Ordine del filtro

% Progettazione del filtro
b = fir1(filter_order, f_norm, 'stop');

% Applica il filtro al segnale
filtered_signal = filter(b, 1, noisy_signal);

figure(1);
% Plot dei risultati
subplot(2,1,1);
plot(t, real(noisy_signal));
title('Segnale con disturbo');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, real(filtered_signal));
title('Segnale filtrato');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

figure(2);
freqz(b, 1, 1024, fs);
title('Risposta in frequenza del filtro');
