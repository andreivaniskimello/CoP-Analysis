%%     By André Ivaniski Mello & Vivian Muller
 
% andreivaniskimello@gmail.com
 
% 01/set/22
 
% Routine to process GRF Data. Calculate COP responses during APA from Weight Transfer task (Bipedal to Unipedal)
 
% Input:
 
% .txt file array with GRF (x,y,z), Moments (x,y,z), and COP (x,y)
% Processing:
 
% Low-pass filter 
 
% Detect basal time in COP curves
 
% Calculate Mean and SD from this basal time
 
% Diferentiate Position COP Curves to obtain Velocity curves
% Detect Weight transfer APA Start event (Bipedal to unipedal stance) with 2 methods based on COP curves:
 
%   **APA START**
%   Mean +- k*SD from COP position curve (k is a constant value)
%   COP velocity (x or y) above 1.5 mm/10 ms (Plate et al. (2016, DOI: 10.1007/s00221-016-4665-x)
 
%  **APA END**
%  End from weight transfer, i.e., unipedal stance stabilization.
%  Determine better quantitatively this APA end.
% Variables:
 
%     COP Amplitude (x and y)
%     COP Peak Speed (x and y)
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

File = ('AnaR_UP_OA_02.txt');

File_Path = ('C:\Users\andre\Documents\Andre\Pesquisa\Artigos para Publicar\TCC Vivian - Equilíbrio GRF CREM\Data\Data In Selected\');
Input_File = [File_Path File];

Export_File_Path = ('C:\Users\andre\Documents\Andre\Pesquisa\Artigos para Publicar\TCC Vivian - Equilíbrio GRF CREM\Data\Data Out\Data Out Matlab\');

% Load kinematic data

Delimiter_Columns = '\t';
Header_Lines = 5;
Input_Data = importdata(Input_File, Delimiter_Columns, Header_Lines);
Data = Input_Data.data;

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
% figure ('Name','Moments')
% title ('Moments');
% xlabel('Frame (n)');
% ylabel ('Moment (N.mm)');
% hold on
% plot (Moment_X , 'r', 'LineWidth', 2);
% hold on
% plot (Moment_Y, 'b', 'LineWidth', 2);
% hold on
% plot (Moment_Z, 'g', 'LineWidth', 2);
% hold on
% legend ('X AP', 'Y ML', 'Z Vertical')

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
% figure ('Name','COP Speed')
% title ('COP Speed');
% xlabel('Frame (n)');
% ylabel ('Speed (mm/s)');
% hold on
% plot (COP_X_Speed , 'r', 'LineWidth', 2);
% hold on
% plot (COP_Y_Speed, 'b', 'LineWidth', 2);
% hold on
% legend ('COP Y ML')


%% 02: APA Start
% Detect Weight transfer APA Start event (Bipedal to unipedal stance) with 2 methods based on COP curves:

%    1°) Mean +- k*SD from COP position curve (k is a constant value)


% Recort basal time from COP position curve
Length = length(COP_X);
Factor_Recort_Basal = 0.1;

COP_X_Basal = COP_X(1:(Length*Factor_Recort_Basal));
COP_Y_Basal = COP_Y(1:(Length*Factor_Recort_Basal));

% Calculate MEAN and SD from basal time from COP position curves 
COP_X_Basal_Mean = mean(COP_X_Basal);
COP_X_Basal_SD = std(COP_X_Basal);

COP_Y_Basal_Mean = mean(COP_Y_Basal);
COP_Y_Basal_SD = std(COP_Y_Basal);


% Determine Threshold values (Mean +- k*SD)

    % k factor
APA_Basal_Factor = 3;
    % COP X
COP_X_Threshold_Up = COP_X_Basal_Mean + (APA_Basal_Factor * COP_X_Basal_SD);
COP_X_Threshold_Low = COP_X_Basal_Mean - (APA_Basal_Factor * COP_X_Basal_SD);
    % COP Y
COP_Y_Threshold_Up = COP_Y_Basal_Mean + (APA_Basal_Factor * COP_Y_Basal_SD);
COP_Y_Threshold_Low = COP_Y_Basal_Mean - (APA_Basal_Factor * COP_Y_Basal_SD);

%Find the frame that passes the threshold (APA start), starting after the basal period
% COP_X_Index_MethodMeanSD = find(COP_X((Length*Factor_Recort_Basal):end) > COP_X_Threshold_Up  | COP_X((Length*Factor_Recort_Basal):end) < COP_X_Threshold_Low);
COP_Y_Index_MethodMeanSD = find(COP_Y((Length*Factor_Recort_Basal):end) > COP_Y_Threshold_Up | COP_Y((Length*Factor_Recort_Basal):end) > COP_Y_Threshold_Low);

% Adjust the APA start frame number for all the curve, includin basal period
% COP_X_Index_MethodMeanSD = COP_X_Index_MethodMeanSD + (Length*Factor_Recort_Basal);
COP_Y_Index_MethodMeanSD = COP_Y_Index_MethodMeanSD + (Length*Factor_Recort_Basal);

%Extract the frame from APA Start for each COP curve
% COP_X_APA_Start_MethodMeanSD = COP_X_Index_MethodMeanSD(1);
COP_Y_APA_Start_MethodMeanSD = COP_Y_Index_MethodMeanSD(1);


%    2°) COP velocity (x or y) above 1.5 mm/10 ms (0.15 m/s) (Plate et al. (2016, DOI: 10.1007/s00221-016-4665-x)

Speed_Threshold = 0.15;
Speed_Threshold_Negative = -1 * Speed_Threshold;

%Find the frame that passes the threshold (APA start), starting after the basal period
% COP_X_Index_MethodSpeed_Greater = find(COP_X_Speed > Speed_Threshold);
% COP_X_Index_MethodSpeed_Lower = find(COP_X_Speed < Speed_Threshold_Negative);
COP_Y_Index_MethodSpeed_Greater = find(COP_Y_Speed > Speed_Threshold);
COP_Y_Index_MethodSpeed_Lower = find(COP_Y_Speed < Speed_Threshold_Negative);

% COP_X_Index_MethodSpeed_Greater = COP_X_Index_MethodSpeed_Greater(1);
% COP_X_Index_MethodSpeed_Lower = COP_X_Index_MethodSpeed_Lower(1);

COP_Y_Index_MethodSpeed_Greater = COP_Y_Index_MethodSpeed_Greater(1);
COP_Y_Index_MethodSpeed_Lower = COP_Y_Index_MethodSpeed_Lower(1);


%Extract the frame from APA Start for each COP curve
% COP_X_APA_Start_MethodSpeed = min([COP_X_Index_MethodSpeed_Greater COP_X_Index_MethodSpeed_Lower]);
COP_Y_APA_Start_MethodSpeed = min([COP_Y_Index_MethodSpeed_Greater COP_Y_Index_MethodSpeed_Lower]);

figure ('Name','COP Marked', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Marked');
xlabel('Frame (n)');
ylabel ('Position (mm)');
hold on
plot (COP_Y, 'b', 'LineWidth', 2);
hold on
plot(COP_Y_APA_Start_MethodMeanSD, COP_Y(COP_Y_APA_Start_MethodMeanSD), 'dr', 'LineWidth', 2);
hold on
plot(COP_Y_APA_Start_MethodSpeed, COP_Y(COP_Y_APA_Start_MethodSpeed), 'dg', 'LineWidth', 2);
legend ('COP Y ML', 'Start Method MeanSD', 'Start Method Speed')


Prompt_APA_Start = {'Mean SD Method RED (1), COP Speed Method GREEN (2):'};
Dlgtitle_APA_Start = 'APA Start Method (INSERT THE METHOD NUMBER)';
Answer_APA_Start = inputdlg(Prompt_APA_Start,Dlgtitle_APA_Start,[1 100]);

APA_Start_Method = str2double(Answer_APA_Start{1});

if APA_Start_Method == 1
    COP_Y_APA_Start = COP_Y_APA_Start_MethodMeanSD;
elseif APA_Start_Method == 2
    COP_Y_APA_Start = COP_Y_APA_Start_MethodSpeed;
end


%% Section 03: APA End 

    % Detect APA End event in COP (x and y) curves
    % Recort the APA Interval in the COP (position and speed) (x and y) curves


% APA End Determination

%First I determine the Start from unipedal stable phase and consider this
%as the APA end. Then I visually verify if this is OK. If this APA End is
%not OK, then I manually determine the APA end.



fcut = 3;
order = 4;
COP_Y_Filtered_3 = matfiltfilt(dt, 3, order, COP_Y);

figure ('Name','COP Y ML APA Window', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Y ML APA Window');
xlabel('Frame (n)');
ylabel ('Position (mm)');
hold on
plot (COP_Y, 'g', 'LineWidth', 2);
hold on
plot (COP_Y_Filtered_3, 'k', 'LineWidth', 2);
hold on
plot(COP_Y_APA_Start, COP_Y(COP_Y_APA_Start), 'db', 'LineWidth', 5);
hold on
plot(COP_Y_APA_Start + 500, COP_Y(COP_Y_APA_Start + 500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 1000, COP_Y(COP_Y_APA_Start + 1000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 1500, COP_Y(COP_Y_APA_Start + 1500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 2000, COP_Y(COP_Y_APA_Start + 2000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 2500, COP_Y(COP_Y_APA_Start + 2500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 3000, COP_Y(COP_Y_APA_Start + 3000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 3500, COP_Y(COP_Y_APA_Start + 3500), '*r', 'LineWidth', 3);
hold on
% plot(COP_Y_APA_Start + 4000, COP_Y(COP_Y_APA_Start + 4000), '*r', 'LineWidth', 3);
legend('COP Y Raw', 'COP Y Butterworth 3Hz', 'APA Start')


% Dialog box to insert the points from the Unipedal Stable Phase
Prompt_Unipedal = {'Stable Unipedal: Enter the START Point Number (RED) (n):', 'COP Unipedal goes UP (1) or DOWN (2)?'};
Dlgtitle_Unipedal = 'Unipedal Stable Phase (INSERT THE STARTING POINT NUMBER)';
Answer_Unipedal = inputdlg(Prompt_Unipedal,Dlgtitle_Unipedal,[1 100]);

Unipedal_Phase_Stable_Point_Start = str2double(Answer_Unipedal{1});
Unipedal_Phase_Stable_Up_Down = str2double(Answer_Unipedal{2});

Unipedal_Phase_Stable_Start = COP_Y_APA_Start + (Unipedal_Phase_Stable_Point_Start * 500);
Unipedal_Phase_Stable_End = COP_Y_APA_Start + ((Unipedal_Phase_Stable_Point_Start+1) * 500);

COP_Y_Unipedal_Stable_Phase = COP_Y(Unipedal_Phase_Stable_Start:Unipedal_Phase_Stable_End);
COP_Y_Unipedal_Stable_Phase_Mean = mean(COP_Y_Unipedal_Stable_Phase);


%Find the frame that passes the threshold (APA END), starting after the basal period
if Unipedal_Phase_Stable_Up_Down == 1 % Up (Left Foot Unipedal)
    COP_Y_Index_Unipedal_Phase = find(COP_Y > COP_Y_Unipedal_Stable_Phase_Mean);
    Foot_Unipedal = ('Left');
elseif Unipedal_Phase_Stable_Up_Down == 2 % Down (Right Foot Unipedal)
    COP_Y_Index_Unipedal_Phase = find(COP_Y < COP_Y_Unipedal_Stable_Phase_Mean);
    Foot_Unipedal = ('Right');
end

COP_Y_Index_Unipedal_Phase_Start = COP_Y_Index_Unipedal_Phase(1);

figure ('Name','COP Y ML APA Window', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Y ML APA Window');
xlabel('Frame (n)');
ylabel ('Position (mm)');
hold on
plot (COP_Y, 'g', 'LineWidth', 2);
hold on
plot (COP_Y_Filtered_3, 'k', 'LineWidth', 2);
hold on
plot(COP_Y_APA_Start, COP_Y(COP_Y_APA_Start), 'db', 'LineWidth', 5);
hold on
plot(COP_Y_APA_Start + 500, COP_Y(COP_Y_APA_Start + 500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 1000, COP_Y(COP_Y_APA_Start + 1000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 1500, COP_Y(COP_Y_APA_Start + 1500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 2000, COP_Y(COP_Y_APA_Start + 2000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 2500, COP_Y(COP_Y_APA_Start + 2500), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 3000, COP_Y(COP_Y_APA_Start + 3000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_APA_Start + 3500, COP_Y(COP_Y_APA_Start + 3500), '*r', 'LineWidth', 3);
hold on
% plot(COP_Y_APA_Start + 4000, COP_Y(COP_Y_APA_Start + 4000), '*r', 'LineWidth', 3);
hold on
plot(COP_Y_Index_Unipedal_Phase_Start, COP_Y(COP_Y_Index_Unipedal_Phase_Start), 'dm', 'LineWidth', 5);
legend('COP Y Raw', 'COP Y Butterworth 3Hz', 'APA Start', '1', '2', '3', '4','5','6','7','8', 'APA End')




% Dialog box to verify if it is ok the APA window
Prompt_APA_Window_Verification = {'It is OK the APA window recort? (1: YES, 2: NO)'};
Dlgtitle_APA_Window_Verification = 'APA Window Verification';
Answer_APA_Window_Verification = inputdlg(Prompt_APA_Window_Verification,Dlgtitle_APA_Window_Verification,[1 100]);

APA_Window_Verification_Answer = str2double(Answer_APA_Window_Verification{1});

if APA_Window_Verification_Answer == 1 %The window is OK
    
    COP_Y_APA_End = COP_Y_Index_Unipedal_Phase_Start;

elseif APA_Window_Verification_Answer == 2 %The window is NOT OK
   
        figure ('Name','COP Y ML APA Window Confirmation Manual', 'units','normalized','outerposition',[0 0 1 1])
    title ('COP Y ML APA Window Confirmation Manual');
    xlabel('Frame (n)');
    ylabel ('Position (mm)');
    hold on
    plot (COP_Y, 'g', 'LineWidth', 2);
    hold on
    plot (COP_Y_Filtered_3, 'k', 'LineWidth', 2);
    hold on
    plot(COP_Y_APA_Start, COP_Y(COP_Y_APA_Start), 'db', 'LineWidth', 5);
    hold on
    plot(COP_Y_APA_Start + 500, COP_Y(COP_Y_APA_Start + 500), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 1000, COP_Y(COP_Y_APA_Start + 1000), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 1500, COP_Y(COP_Y_APA_Start + 1500), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 2000, COP_Y(COP_Y_APA_Start + 2000), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 2500, COP_Y(COP_Y_APA_Start + 2500), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 3000, COP_Y(COP_Y_APA_Start + 3000), '*r', 'LineWidth', 3);
    hold on
    plot(COP_Y_APA_Start + 3500, COP_Y(COP_Y_APA_Start + 3500), '*r', 'LineWidth', 3);
    hold on
    % plot(COP_Y_APA_Start + 4000, COP_Y(COP_Y_APA_Start + 4000), '*r', 'LineWidth', 3);
    legend('COP Y Raw', 'COP Y Butterworth 3Hz', 'APA Start')
    
    Prompt_APA_Windpow_End_Manual_Determination = {'APA Window End: Enter the APA END Point Number (RED) (n):'};
    Dlgtitle_APA_Windpow_End_Manual_Determination = 'APA Window End(INSERT THE END POINT NUMBER)';
    Answer_APA_Windpow_End_Manual_Determination = inputdlg(Prompt_APA_Windpow_End_Manual_Determination,Dlgtitle_APA_Windpow_End_Manual_Determination,[1 100]);

    APA_Window_End_Manual_Determination = str2double(Answer_APA_Windpow_End_Manual_Determination{1});
    
    COP_Y_APA_End = COP_Y_APA_Start + (APA_Window_End_Manual_Determination * 500);

end


%% 04: Calculate Output Variables

% Calculate the Position Amplitude (Max - Min) and Peak Speed (Max) from the COP curves during APA Interval

Time_Vector = linspace(1,length(COP_Y),length(COP_Y))';
COP_Y_APA_Window = COP_Y(COP_Y_APA_Start:COP_Y_APA_End);
% Speed in mm/s
COP_Y_APA_Window_Speed = abs(diff(COP_Y_APA_Window)/dt);


figure ('Name','COP Y ML APA Window Recorted', 'units','normalized','outerposition',[0 0 1 1])
title ('COP Y ML APA Window Recorted');
xlabel('Frame (n)');
ylabel ('Position (mm)');
hold on
plot (Time_Vector(1:COP_Y_APA_Start-1), COP_Y(1:COP_Y_APA_Start-1), 'g', 'LineWidth', 2);
hold on
plot (Time_Vector(COP_Y_APA_Start:COP_Y_APA_End), COP_Y(COP_Y_APA_Start:COP_Y_APA_End), 'r', 'LineWidth', 3);
hold on
plot (Time_Vector(COP_Y_APA_End+1:end), COP_Y(COP_Y_APA_End+1:end), 'g', 'LineWidth', 2);
legend('COP Y', 'COP Y APA Window')


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

%Output Variables
COP_Y_APA_Amplitude = max(COP_Y_APA_Window) - min(COP_Y_APA_Window);
COP_Y_APA_Speed_Peak = max(COP_Y_APA_Window_Speed);
COP_Y_APA_Window_Length = length(COP_Y_APA_Window)*dt;
% Foot_Unipedal
% APA_Start_Method:  1: MeanSD, 2: Speed

%% 05: Export Output Data

Export_File_Path_Full = [Export_File_Path File '_OUTPUT_COP' '.xls'];

Output_Header = {'Unipedal Foot (1 Left, 2 Right)', 'APA t0 Method (1 MeanSD 2 Speed)','COP ML Amplitude (mm)','COP Peak Speed (mm/s)','APA Window Length (s)'};
Output_Variables = [Unipedal_Phase_Stable_Up_Down APA_Start_Method COP_Y_APA_Amplitude COP_Y_APA_Speed_Peak COP_Y_APA_Window_Length];
Output_Full = [Output_Header; num2cell(Output_Variables)];

xlswrite (Export_File_Path_Full, Output_Full); 


