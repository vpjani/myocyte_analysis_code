% ktr.m 


% Keep as is 

close all; 
clear; 
clc; 

%% First Load the data file. I will make use uigetfile to make it a GUI 


[file,path] = uigetfile("*.dat",'Select ktr Data File.'); 
D = input("Enter myocyte diameter in (um): ");
D2 = D*0.8; 
CSA = (((D+D2)/2)*(1e-3)/2)^2*pi; 

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


%% First Getting Fmax

% Relevant times at which shortening happens 
t1 = find(fl_data_all(:,1) == 50); 
t2 = find(fl_data_all(:,1) == 70); 
t3 = find(fl_data_all(:,1) == 200); 
t4 = find(fl_data_all(:,1) == 225);


max_force = mean(maxk(fl_data_all(1:t1,4),5)); 
min_force = mean(mink(fl_data_all(t2:t3,4),5)); 
Fmax = (max_force-min_force)/CSA; 

disp(strcat("Fmax: ",num2str(Fmax), " mN/mm^2")); 


%% Now getting ktr 

t_ktr = fl_data_all(t4:end,1)./1000;
F_ktr = fl_data_all(t4:end,4); 

Ft = @(parms,tdata) parms(1).*(1 - exp(-parms(2).*tdata))+parms(3); 
x0 = [max(F_ktr),1,min(F_ktr)]; 
opts = optimset('Display','off');
my_fit = lsqcurvefit(Ft,x0,t_ktr,F_ktr,[],[],opts); 

y = my_fit(1).*(1-exp(-t_ktr.*my_fit(2)))+my_fit(3); 

plot(t_ktr,F_ktr.*1000,'k.')
hold on; 
plot(t_ktr,y.*1000,'r--','LineWidth',4); 
ylabel('Force (\muN)','FontSize',18)
xlabel('Time (s)','FontSize',18)

disp(strcat("ktr: ",num2str(my_fit(2)), " 1/s")); 




