clc
clear all
close all

%load("notch_500.mat");
load("Hnotch600.mat");
load("Hnotch1200.mat");
%load("Hnotch600_2.mat");
%load("Hnotch1200_2.mat");

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

realx1 = real(x_1);
imagx1 = imag(x_1);
realx2 = real(x_2);
imagx2 = imag(x_2);

%figure(1);
%subplot(2,1,1);
%plot(abs(x_1), "b");
%hold on
%plot(abs(x_2), "m");
%subplot(2,1,2);
%plot(angle(x_1), "r");
%hold on
%plot(angle(x_2), "g");

% Grafici I/Q
%figure(1)
%hold on
%plot(real(x_1), "blue");
%plot(imag(x_1), "magenta");

%plot(real(x_2), "red");
%plot(imag(x_2), "green");
%hold off

%legend("real X", "imag X", "real Y", "imag Y");

%figure(1);
%hold on;
%scatter(realx1, imagx1, 'filled', 'MarkerFaceColor', 'blue');
%figure(2);
%scatter(realx2, imagx2, "+", 'MarkerFaceColor', 'red');
%legend("X", "Y");
%hold off;

% Parametri del filtro
fs = 2e6; % Frequenza di campionamento (2 MHz)
f_cutoff = 100; % Frequenza di taglio del filtro passa-alto (200 Hz)
N = 1000; % Lunghezza del filtro (numero di coefficienti)

% Calcolo della frequenza di taglio normalizzata
f_cutoff_norm = f_cutoff / (fs/2);

% Generazione della risposta impulsiva del filtro FIR
h = fir1(N, f_cutoff_norm, 'high');

% Visualizzazione della risposta in frequenza del filtro
[freq_response, freq] = freqz(h, 1, 1024, fs);
plot(freq, 20*log10(abs(freq_response)));
title('Risposta in Frequenza del Filtro Passa-Alto');
xlabel('Frequenza (Hz)');
ylabel('Attenuazione (dB)');
grid on;

%b = fir1(1000, [Wn1 Wn2], "stop");
%b = fir1(10, Wn2, "high");
%freqz(b, 1, 1024, Fs)

y_1 = filter(h, 1, x_1);

plot(abs(x_1), "blue", "DisplayName", "Unfiltered")
hold on
%plot(abs(y_1), "r")

y_2 = filter(Hnotch600, x_1);
%y_3 = filter(Hnotch600_2, x_1);
y_3 = filter(Hnotch1200, x_1);
y_4 = filter(Hnotch600, x_1);
y_4 = filter(Hnotch1200, y_4);

plot(abs(y_2), "red", "DisplayName", "Notch 600 Hz");
plot(abs(y_3), "green", "DisplayName", "Notch 1200 Hz");
plot(abs(y_4), "cyan", "DisplayName", "Notches 600 and 1200 H");

legend("Location", "northeast");
