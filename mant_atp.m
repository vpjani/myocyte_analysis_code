% mant_atp.m

close all; 
clear;
clc; 

%% Load the Data 
[file,path] = uigetfile("*.dat",'Select Data File.'); 


fid = fopen([path,file]); 
dat = textscan(fid,'%[^\n]');
fclose(fid); 
dat = dat{1,1}; 

%% Running the Analysis 

x = find(dat == "*** Force and Length Signals vs Time ***"); % The data starts from x + 2 

fl_data_all = dat(x+2:end,1); % Gets the numbers 
fl_data_all = cellfun(@(x) strsplit(x," "),fl_data_all, 'UniformOutput', false); 
fl_data_all = vertcat(fl_data_all{:}); 
fl_data_all = cellfun(@str2num,fl_data_all); 




%% Finding the start time 


close all; 

t_all = fl_data_all(:,1); 
fluor_all = fl_data_all(:,7);

fluor_all = smoothdata(fluor_all,'sgolay',100); 
t_all = t_all - min(t_all);

plot(t_all(1:100000),fluor_all(1:100000),'b--')
ylabel('Fluorescence Intensity (AU)','FontSize',18)
xlabel('Time (s)','FontSize',18)
title('Select Analysis start point')

[xpt,ypt] = ginput; 

close all; 

max_ind = find(t_all < xpt(1)); 
max_ind = max(max_ind); 
fluor_scaled = fluor_all(max_ind:end); 
t_all = t_all(max_ind:end); 

min_scale = 0.9.*mean(fluor_scaled(end-1000:end)); % 0.9 prevents things from going negative  
t_all = t_all./1000; 
fluor_scaled = (fluor_scaled - min_scale); 
max_scale = mean(fluor_scaled(1:500)); 
fluor_scaled = fluor_scaled./max_scale; 

t_all = t_all - min(t_all);

It = @(parms,tdata)  1-parms(1).*(1-exp(-tdata./parms(2))) - parms(3).*(1-exp(-tdata./parms(4)));
x0 = [0.6,30,0.1,200];



my_fit = lsqcurvefit(It,x0,t_all,fluor_scaled,[0,0,0,0],[0.5,Inf,0.5,Inf]); 

y = It(my_fit,t_all); 


% Rescale based on fit 
new_min = min(y); 
newy = y - new_min; 
new_max = max(newy);
newy = newy./new_max; 

new_raw = (fluor_scaled - new_min)./new_max; 

hold on; 
plot(t_all,new_raw,'b--')
plot(t_all,newy,'r--','LineWidth',4); 
ylabel('Fluorescence Intensity (AU)','FontSize',18)
xlabel('Time (s)','FontSize',18)
hold off; 






