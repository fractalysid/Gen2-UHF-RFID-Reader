clc
clear all
close all

fi_1 = fopen('../data/source','rb');

x_inter_1 = fread(fi_1, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

% Seleziono la parte che contiene solo il rumore
%x_1 = x_1(89751:106143);

% Seleziono la parte che contiene query, rn16, ack e epc
%x_1 = x_1(28563:44756);


%-----------------------------
% Parametri base dei filtri
fs = 2e6;       % Frequenza di campionamento (2MHz)
N = fs/128;     % Lunghezza del filtro (numero di coefficienti)
%-------------------------------

%--------------------------
% Filtro passa basso
fc = 4e4;
% Normalizzazione
Wn = fc / (fs/2);
Flow = fir1(N, Wn, "low");
%---------------------------

%-----------------------------------
% Filtro elimina banda 1
fc1 = 550;
fc2 = 650;
% Normalizzazione
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);
Fstop1 = fir1(N, [Wn1 Wn2], "stop");
%-----------------------------------

%-----------------------------------
% Filtro elimina banda 2
fc1 = 1150;
fc2 = 1250;
% Normalizzazione
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);
Fstop2 = fir1(N, [Wn1 Wn2], "stop");
%-----------------------------------

%-----------------------------------
% Filtro elimina banda 3, che elimina tutto
fc1 = 300;
fc2 = 3000;
% Normalizzazione
Wn1 = fc1 / (fs/2);
Wn2 = fc2 / (fs/2);
Fstop3 = fir1(N, [Wn1 Wn2], "stop");
%-----------------------------------

% Per prima cosa filtriamo con un passa basso...
%y_1 = filter(Flow, 1, x_1);
y_1 = filter(Fstop1, 1, x_1);
% ... e poi filtriamo con l'eliminabanda
y_2 = filter(Fstop3, 1, y_1);

y_4 = filter(Fstop1, 1, x_1);

y_5 = filter(Fstop2, 1, y_4);


% Calcola la risposta in frequenza dei filtri
[H, f] = freqz(Flow, 1, N, fs);
%[H, f] = freqz(b, 1, N, fs);
%[H, f] = freqz(b, 1, N, fs);
%[H, f] = freqz(b, 1, N, fs);
%[H, f] = freqz(b, 1, N, fs);


% Visualizza la risposta in ampiezza
figure;
subplot(2,1,1)
plot(f, abs(H));
title('Risposta in ampiezza del filtro');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
grid on;
xlim([0, 4000]);

% Visualizza la risposta in fase
subplot(2,1,2)
plot(f, angle(H));
title('Risposta in fase del filtro');
xlabel('Frequenza (Hz)');
ylabel('Fase (radians)');
grid on;
xlim([0, 4000]);

% Calcola la FFT del segnale
N1 = length(x_1);                    % Lunghezza del segnale
N2 = length(y_1);
N3 = length(y_2);
N4 = length(y_4);
N5 = length(y_5);

X1 = fft(x_1);                       % Calcola la FFT
X2 = fft(y_1);
X3 = fft(y_2);
X4 = fft(y_4);
X5 = fft(y_5);
freqs1 = (0:N1-1)*(fs/N1);       % Frequenze corrispondenti
freqs2 = (0:N2-1)*(fs/N2);       % Frequenze corrispondenti
freqs3 = (0:N3-1)*(fs/N3);       % Frequenze corrispondenti
freqs4 = (0:N4-1)*(fs/N4);       % Frequenze corrispondenti
freqs5 = (0:N5-1)*(fs/N5);       % Frequenze corrispondenti

amplitude_spectrum1 = abs(X1)/N1;     % Spettro di ampiezza
amplitude_spectrum2 = abs(X2)/N2;     % Spettro di ampiezza
amplitude_spectrum3 = abs(X3)/N3;     % Spettro di ampiezza
amplitude_spectrum4 = abs(X4)/N4;     % Spettro di ampiezza
amplitude_spectrum5 = abs(X5)/N5;     % Spettro di ampiezza

phase_spectrum1 = angle(X1)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum2 = angle(X2)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum3 = angle(X3)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum4 = angle(X4)*(180/pi); % Spettro di fase (in gradi)
phase_spectrum5 = angle(X5)*(180/pi); % Spettro di fase (in gradi)

% Visualizza la FFT
% Ampiezza
figure
%subplot(2,1,1);
hold on
plot(freqs1, amplitude_spectrum1, "b", "DisplayName", "Unfiltered");
plot(freqs2, amplitude_spectrum2, "r", "DisplayName", "Lowpass");
plot(freqs3, amplitude_spectrum3, "g", "DisplayName", "Bandstop 300-3000 Hz");
plot(freqs4, amplitude_spectrum4, "magenta", "DisplayName", "400-2600Hz stopband");
plot(freqs5, amplitude_spectrum5, "cyan", "DisplayName", "300-2600Hz stopband and 40KHz lowpass");
%plot(freqs1, 20*log10(amplitude_spectrum1), "b", "DisplayName", "Unfiltered");
%plot(freqs2, 20*log10(amplitude_spectrum2), "r", "DisplayName", "600Hz notch");
%plot(freqs3, 20*log10(amplitude_spectrum3), "g", "DisplayName", "1200Hz notch");
%plot(freqs4, 20*log10(amplitude_spectrum4), "magenta", "DisplayName", "400-2600Hz stopband");
%plot(freqs5, 20*log10(amplitude_spectrum5), "cyan", "DisplayName", "300-2600Hz stopband and 40KHz lowpass");

title('Spettro di Ampiezza');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza (dB)');
xlim([0, 5000]);
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
figure
hold on
plot(abs(x_1), "b", "DisplayName", "Unfiltered");
plot(abs(y_1), "r", "DisplayName", "Lowpass");
plot(abs(y_2), "g", "DisplayName", "Bandstop 300-3000 Hz");
plot(abs(y_4), "magenta", "DisplayName", "300-2600Hz stopband");
plot(abs(y_5), "cyan", "DisplayName", "300-2600Hz stopband and 40KHz lowpass");
title("Ampiezza del segnale");
xlabel('Campioni (2MHz sampling rate)');
ylabel('Ampiezza');
legend("Location", "northeast");
