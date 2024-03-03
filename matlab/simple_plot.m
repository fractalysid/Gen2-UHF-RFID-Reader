clc
clear all
close all

fi_1 = fopen('../data/source','rb');
x_inter_1 = fread(fi_1, 'float32');
x1 = x_inter_1(1:2:end) + 1i*x_inter_1(2:2:end);

figure;
hold on
plot(abs(x1), "b");
title("Amiezza del segnale");
xlabel('Campioni (2MHz sampling rate)');
ylabel('Ampiezza');
%legend("Location", "northeast");
xlim([16000, 200000]);
