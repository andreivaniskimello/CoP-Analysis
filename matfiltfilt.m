% Rotina para filtro Butterworth
%
% comando: matfiltfilt(dt, fcut, order, dados);
%
% Atenção: Em caso de matriz de dados com algumas linhas 'NaN', após a aplicação deste filtro,
% 			  todas as linhas correspondentes à coluna que continha valores 'NaN', tornam-se 'NaN'.
%
% Perform double nth order butterworth filter on several columns of data
% the double filter should have 1/sqrt(2) transfer at fcut, so we
% need correction for filter order:

function [result] = matfiltfilt(dt, fcut, order, data);

fcut = fcut/(sqrt(2)-1)^(0.5/order);
[b,a] = butter(order, 2*fcut*dt);
[n,m] = size(data);
for i=1:m
  result(:,i) = filtfilt(b,a,data(:,i));
end


