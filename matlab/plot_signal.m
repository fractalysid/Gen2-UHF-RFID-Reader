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

% ------------------------------------------------
% Parametri del filtro
fs = 2e6; % Frequenza di campionamento (2 MHz)
fc1 = 300;
fc2 = 2600;
% Frequenze normalizzate
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);

N = fs/128; % Lunghezza del filtro (numero di coefficienti)

% Generazione della risposta impulsiva del filtro FIR
b = fir1(N, [Wn1 Wn2], "stop");

y_1 = filter(b, 1, x_1);

% Visualizza l'ampiezza dei segnali
figure;
hold on
plot(abs(x_1), "b", "DisplayName", "Unfiltered");
plot(abs(y_1), "r", "DisplayName", "400-2600Hz stopband");
title("Ampiezza del segnale");
xlabel('Campioni (2MHz sampling rate)');
ylabel('Ampiezza');
legend("Location", "northeast");
