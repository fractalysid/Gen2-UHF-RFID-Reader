clc
clear all
close all

fi_1 = fopen('../data/source','rb');

x_inter_1 = fread(fi_1, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

x_1 = x_1(89751:106143);

fs = 2e6; % Frequenza di campionamento (2 MHz)
fc1 = 500;
fc2 = 700;
% Frequenze normalizzate
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);

N = 50; % Lunghezza del filtro (numero di coefficienti)

% Generazione della risposta impulsiva del filtro FIR
b = fir1(N, [Wn1 Wn2], "stop");

% Applico il filtro sul segnale reale dell'ampiezza
%x_1 = abs(x_1);
y_1 = filter(b, 1, x_1);

% Applico un secondo filtro

fc1 = 1100;
fc2 = 1300;
% Frequenze normalizzate
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);

% Generazione della risposta impulsiva del filtro FIR
b = fir1(N, [Wn1 Wn2], "stop");

% Applico il filtro sul segnale reale dell'ampiezza
%y_1 = abs(y_1);
y_2 = filter(b, 1, y_1);

% Calcola la FFT del segnale
N1 = length(x_1);                    % Lunghezza del segnale
N2 = length(y_1);
N3 = length(y_2);

X1 = fft(x_1);                       % Calcola la FFT
X2 = fft(y_1);
X3 = fft(y_2);
freqs1 = (0:N1-1)*(fs/N1);       % Frequenze corrispondenti
freqs2 = (0:N2-1)*(fs/N2);       % Frequenze corrispondenti
freqs3 = (0:N3-1)*(fs/N3);       % Frequenze corrispondenti

amplitude_spectrum1 = abs(X1)/N1;     % Spettro di ampiezza
amplitude_spectrum2 = abs(X2)/N2;     % Spettro di ampiezza
amplitude_spectrum3 = abs(X3)/N3;     % Spettro di ampiezza

phase_spectrum1 = angle(X1)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum2 = angle(X2)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum3 = angle(X3)*(180/pi); % Spettro di fase (in gradi)

% Visualizza la FFT
% Ampiezza
figure(1);
%subplot(2,1,1);
hold on
plot(freqs1, 20*log10(amplitude_spectrum1), "b", "DisplayName", "Unfiltered");
plot(freqs2, 20*log10(amplitude_spectrum2), "r", "DisplayName", "600Hz notch");
plot(freqs3, 20*log10(amplitude_spectrum3), "g", "DisplayName", "1200Hz notch");

title('Spettro di Ampiezza');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza (dB)');
xlim([0, 40000]);
legend("Location", "northeast");

% Fase
%subplot(2,1,2);
%plot(freqs1, phase_spectrum1, "b");
%hold on
%plot(freqs2, phase_spectrum2, "r");
%title('Spettro di Fase');
%xlabel('Frequenza (Hz)');
%ylabel('Fase (gradi)');

%---------------------------------------

% Visualizza l'ampiezza dei segnali
figure(2)
hold on
plot(abs(x_1), "b", "DisplayName", "Unfiltered");
plot(abs(y_1), "r", "DisplayName", "600Hz notch");
plot(abs(y_2), "g", "DisplayName", "1200Hz notch");
title("Ampiezza del segnale");
xlabel('Campioni (2MHz sampling rate)');
ylabel('Ampiezza');
legend("Location", "northeast");


% Stop bands
stopbands = 0:100:2700;
stopbands = stopbands ./ (fs/2);

notches = [1 1 1 1 0 0 0 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 ];

% Filter order
N = 20;

% Compute normalized frequencies
normalized_stopbands = stopbands / (fs/2);

% Design filter using firgr
%filter_coeffs = firgr(N, normalized_stopbands, [0 0 0 0]);
b1 = firgr(N, stopbands, notches);

% Plot frequency response
%freqz(filter_coeffs, 1, 1024, Fs);
%title('Frequency Response of Multiband Stop Filter');
%xlabel('Frequency (Hz)');
%ylabel('Magnitude (dB)');

y_3 = filter(b1, 1, x_1);

%figure;
%hvft = fvtool(b,1,b1,1);

%figure;
%hold on
%plot(abs(x_1), "b");
%plot(abs(y_1), "r");
%plot(abs(y_2), "g");
%plot(abs(y_3), "magenta");
