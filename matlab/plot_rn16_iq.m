clc
clear all
close all

fi_1 = fopen('../data/decoder','rb');
x_inter_1 = fread(fi_1, 'float32');

% if data is complex
x_1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

%plot(abs(x_1))
figure
plot(abs(x_1))
figure
plot(angle(x_1))

figure
scatter(angle(x_1), abs(x_1), "filled")

figure
scatter(real(x_1), imag(x_1), 'o')
grid on

%figure(5)
%plot(real(x_1), imag(x_1), 'x')
figure
plot(20*log(abs(x_1)))
title("RSSI (dB)");
grid on

