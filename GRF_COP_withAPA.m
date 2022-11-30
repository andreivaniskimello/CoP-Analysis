%%     By André Ivaniski Mello 
% andreivaniskimello@gmail.com
 
% 01/set/22
% Routine to process GRF Data. Calculate COP responses during APA from Weight Transfer task (Bipedal to Unipedal)
 
% Input: 
    % .txt file array with GRF (x,y,z), Moments (x,y,z), and COP (x,y)
% Processing:
    % Low-pass filter 
 
% Variables:
 
    % COP Amplitude (x and y)
    % COP Peak Speed (x and y)

% Output:
    % Excel file with the File Name; Variables

clear
close all
clc

% X: AP
% Y: ML
% Z: Vertical

% COP X: AP
% COP Y: ML

%% 01: Import File Data and Prepare Input Data

File = ('Giuseppina_UP_OA_02.txt');

File_Path = ('C:\Users\andre\Documents\Andre\Pesquisa\Artigos para Publicar\TCC Vivian - Equilíbrio GRF CREM\Data\Data In Selected\');
Input_File = [File_Path File];

Export_File_Path = ('C:\Users\andre\Documents\Andre\Pesquisa\Artigos para Publicar\TCC Vivian - Equilíbrio GRF CREM\Data\Data Out\');

% Load kinematic data

Delimiter_Columns = '\t';
Header_Lines = 5;
Input_Data = importdata(Input_File, Delimiter_Columns, Header_Lines);
Data = Input_Data.data;

Data = Data(1: length(Data)- (length(Data)*0.2),:);

% Low Pass Filter curves

f_sample = 1000; % in Hertz (Hz)
f_cut = 50; % in Hertz (Hz)
order = 4;
dt = 1/f_sample;

[b,a] = butter(order,f_cut/(f_sample/2), 'low');
Data = filtfilt(b,a,Data);


% Label the Columns from the Input file
Force_X = Data(:,3);
Force_Y = Data(:,4);
Force_Z = Data(:,5);

Moment_X = Data(:,6);
Moment_Y = Data(:,7);
Moment_Z = Data(:,8);

COP_X = Data(:,9);
COP_Y = Data(:,10);

% Diferentiate COP Position curves

% Speed in mm/s
COP_X_Speed = diff(COP_X)/dt;
COP_Y_Speed = diff(COP_Y)/dt;

%Speed in m/s
COP_X_Speed = COP_X_Speed/1000;
COP_Y_Speed = COP_Y_Speed/1000;



% % Plot figures with the COP position
figure ('Name','Forces')
title ('Forces');
xlabel('Frame (n)');
ylabel ('Force (N)');
hold on
plot (Force_X , 'r', 'LineWidth', 2);
hold on
plot (Force_Y, 'b', 'LineWidth', 2);
hold on
plot (Force_Z, 'g', 'LineWidth', 2);
hold on
legend ('X AP', 'Y ML', 'Z Vertical')
% 

% figure ('Name','COP')
% title ('COP');
% xlabel('Frame (n)');
% ylabel ('Position (mm)');
% hold on
% plot (COP_X , 'r', 'LineWidth', 2);
% hold on
% plot (COP_Y, 'b', 'LineWidth', 2);
% hold on
% legend ('COP X AP', 'COP Y ML')
% 
% figure ('Name','COP Speed')
% title ('COP Speed');
% xlabel('Frame (n)');
% ylabel ('Speed (mm/s)');
% hold on
% plot (COP_X_Speed , 'r', 'LineWidth', 2);
% hold on
% plot (COP_Y_Speed, 'b', 'LineWidth', 2);
% hold on
% legend ('COP X AP')
% 


%% 04: Calculate Output Variables

% Calculate the Position Amplitude (Max - Min) and Peak Speed (Max) from the COP curves during APA Interval

Time_Vector = linspace(1,length(COP_Y),length(COP_Y))';
COP_Y_APA_Window = COP_Y(COP_Y_APA_Start:COP_Y_APA_End);
% Speed in mm/s
COP_Y_APA_Window_Speed = abs(diff(COP_Y_APA_Window)/dt);


%Output Variables
COP_Y_APA_Amplitude = max(COP_Y_APA_Window) - min(COP_Y_APA_Window);
COP_Y_APA_Speed_Peak = max(COP_Y_APA_Window_Speed);
COP_Y_APA_Window_Length = length(COP_Y_APA_Window)*dt;
% Foot_Unipedal
% APA_Start_Method:  1: MeanSD, 2: Speed



figure ('Name','COP Speed APA Window Recorted', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Y ML Speed APA Window Recorted');
xlabel('Frame (n)');
ylabel ('Speed (mm/s)');
hold on
plot (Time_Vector(1:COP_Y_APA_Start-1), COP_Y_Speed (1:COP_Y_APA_Start-1), 'g', 'LineWidth', 2);
hold on
plot (Time_Vector(COP_Y_APA_Start:COP_Y_APA_End), COP_Y_Speed (COP_Y_APA_Start:COP_Y_APA_End), 'r', 'LineWidth', 3);
hold on
plot (Time_Vector(COP_Y_APA_End+1:end-1), COP_Y_Speed (COP_Y_APA_End+1:end), 'g', 'LineWidth', 2);
legend('COP Y Speed', 'COP Y Speed APA Window')


figure ('Name','COP Y ML APA Window Recorted', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Médio-Lateral (ML)');
xlabel('Frame (n)');
ylabel ('Posição (mm)');
hold on
plot (Time_Vector(1:COP_Y_APA_Start-1), COP_Y(1:COP_Y_APA_Start-1), 'g', 'LineWidth', 2);
hold on
plot (Time_Vector(COP_Y_APA_Start:COP_Y_APA_End), COP_Y(COP_Y_APA_Start:COP_Y_APA_End), 'r', 'LineWidth', 3);
hold on
plot (Time_Vector(COP_Y_APA_End+1:end), COP_Y(COP_Y_APA_End+1:end), 'g', 'LineWidth', 2);
legend('COP ML', 'COP ML Fase de Transição')



%% 05: Export Output Data

Export_File_Path_Full = [Export_File_Path File '_OUTPUT_COP' '.xls'];

Output_Header = {'Unipedal Foot (1 Left, 2 Right)', 'APA t0 Method (1 MeanSD 2 Speed)','COP ML Amplitude (mm)','COP Peak Speed (mm/s)','APA Window Length (s)'};
Output_Variables = [Unipedal_Phase_Stable_Up_Down APA_Start_Method COP_Y_APA_Amplitude COP_Y_APA_Speed_Peak COP_Y_APA_Window_Length];
Output_Full = [Output_Header; num2cell(Output_Variables)];

xlswrite (Export_File_Path_Full, Output_Full); 

h = msgbox(sprintf('COP Amplitude is %.2f mm \n COP Speed is %.2f mm/s \n APA Duration is %.2f s', COP_Y_APA_Amplitude, COP_Y_APA_Speed_Peak, COP_Y_APA_Window_Length),'COP APA');
set(h,'Position',[100 300 200 80]);


