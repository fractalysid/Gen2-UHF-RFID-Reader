clc
clear all
close all

fi_1 = fopen('../data/source','rb');
fi_2 = fopen('../data/source_filtered', 'rb');
fi_3 = fopen('../data/matched_filter', 'rb');


x_inter_1 = fread(fi_1, 'float32');
x_inter_2 = fread(fi_2, 'float32');
x_inter_3 = fread(fi_3, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);
x_2 = x_inter_2(1:2:end) + 1i*x_inter_2(2:2:end);
x_3 = x_inter_3(1:2:end) + 1i*x_inter_3(2:2:end);

plot(abs(x_1), "b");
hold on
plot(abs(x_2), "r");
plot(abs(x_3), "g");

% Parametri del filtro
fs = 1e6; % Frequenza di campionamento (1 MHz)
f_cutoff = 1000; % Frequenza di taglio del filtro passa-alto (1000 Hz)
N = 1000; % Lunghezza del filtro (numero di coefficienti)

% Calcolo della frequenza di taglio normalizzata
f_cutoff_norm = f_cutoff / (fs/2);

% Generazione della risposta impulsiva del filtro FIR
h = fir1(N, f_cutoff_norm, 'high');

% Visualizzazione della risposta in frequenza del filtro
%[freq_response, freq] = freqz(h, 1, 1024, fs);
%plot(freq, 20*log10(abs(freq_response)));
%title('Risposta in Frequenza del Filtro Passa-Alto');
%xlabel('Frequenza (Hz)');
%ylabel('Attenuazione (dB)');
%grid on;

%b = fir1(1000, [Wn1 Wn2], "stop");
%b = fir1(10, Wn2, "high");
%freqz(b, 1, 1024, Fs)

%x_2 = filter(h, 1, x_1);

%plot(abs(x_2), "r")

%hold on
%plot(abs(out), "g")
