% creep.m 


% Keep as is 

close all; 
clear; 
clc; 

%% First Load the data file. I will make use uigetfile to make it a GUI 


[file,path] = uigetfile("*.dat",'Select Step Stess Data File.'); 


fid = fopen([path,file]); 
dat = textscan(fid,'%[^\n]');
fclose(fid); 
dat = dat{1,1}; 
%% Running the analysis 

x = find(dat == "*** Force and Length Signals vs Time ***"); % The data starts from x + 2 

fl_data_all = dat(x+2:end,1); % Gets the numbers 
fl_data_all = cellfun(@(x) strsplit(x," "),fl_data_all, 'UniformOutput', false); 
fl_data_all = vertcat(fl_data_all{:}); 
fl_data_all = cellfun(@str2num,fl_data_all); 

%% Finding the 2 relevant times 

t1 = find(fl_data_all(:,1) == 150);
t2 = find(fl_data_all(:,1) ==  10000);

t_all = fl_data_all(t1:1:t2,1)./1000;
L_all = fl_data_all(t1:1:t2,2).*1000; 


C = @(parms,tdata) parms(1).*(1 - exp(-tdata./parms(2)))+parms(3); 
x0 = [max(L_all),1,min(L_all)]; 

opts = optimset('Display','off');
my_fit = lsqcurvefit(C,x0,t_all,L_all,[],[],opts); 

y = my_fit(1).*(1-exp(-t_all./my_fit(2)))+my_fit(3); 

plot(t_all,L_all,'k.')
hold on; 
plot(t_all,y,'r--','LineWidth',4); 
ylabel('Length (\mu m)','FontSize',18)
xlabel('Time (s)','FontSize',18)

disp(strcat("tau_sigma: ",num2str(my_fit(2)), " s")); 







