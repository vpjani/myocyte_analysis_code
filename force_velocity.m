% force_velocity.m

close all; 
clear; 
clc; 

%% First get select all files that need to be analyzed 

[files,path] = uigetfile("*.dat",'Select ALL F-V Data Files.','MultiSelect','on'); 
D = input("Enter myocyte diameter in (um): ");
D2 = D*0.8; 
CSA = (((D+D2)/2)*(1e-3)/2)^2*pi; 

dats_all = cell(length(files),1); 
for ii = 1:length(files) 
    fid = fopen([path,files{ii}]); 
    dat = textscan(fid,'%[^\n]');
    fclose(fid); 
    dats_all{ii,1} = dat{1,1}; 
end 

%% Analysis - Needs to be done as a for loop as well. 

Fmax = zeros(length(files),1);
loads_all = zeros(length(files),1);
vel_all = zeros(length(files),1); 


for jj = 1:length(files) 
    datjj = dats_all{jj}; 
    x = find(datjj == "*** Force and Length Signals vs Time ***");
    fl_dat = datjj(x+2:end,1); % gets the numbers 
    fl_dat = cellfun(@(x) strsplit(x," "),fl_dat, 'UniformOutput', false); 
    fl_dat = vertcat(fl_dat{:});
    fl_dat = cellfun(@str2num,fl_dat); 
    
    % Setting time ranges for analysis 
    t1 = find(fl_dat(:,1) == 100);
    t2 = find(fl_dat(:,1) == 210);
    t3 = find(fl_dat(:,1) == 350);
    t4 = find(fl_dat(:,1) == 1600);
    t5 = find(fl_dat(:,1) == 1700);
    
    max_force = mean(maxk(fl_dat(1:t1,4),5));
    min_force = mean(mink(fl_dat(t4:t5,4),5));
    Fmax(jj) = abs(max_force - min_force)/CSA; 
    load_force = mean(mink(fl_dat(t2:t3,4),5));
    loads_all(jj) = abs(load_force - min_force)/CSA; 
    
    % Getting velocities 
    mdl = fitlm(fl_dat(t2:t3,1),fl_dat(t2:t3,2));
    fit_coeffs = mdl.Coefficients;
    fit_coeffs = table2array(fit_coeffs); 
    vel_all(jj) = abs(fit_coeffs(2,1))*(1e6); 
    
    % Testing the accuracy of the fits 
    figure(1); 
    subplot(4,4,jj) 
    plot(fl_dat(:,1),fl_dat(:,2),'k.'); 
    hold on; 
    plot(fl_dat(t2:t3,1),fit_coeffs(2,1).*fl_dat(t2:t3,1)+fit_coeffs(1,1),'r','LineWidth',3)
    title(['Load: ',num2str(loads_all(jj)),' mN/mm^2'])
    hold off; 
    
    if jj == 4
        figure(4); 
        plot(fl_dat(:,1),fl_dat(:,2),'k.'); 
        hold on; 
        plot(fl_dat(t2:t3,1),fit_coeffs(2,1).*fl_dat(t2:t3,1)+fit_coeffs(1,1),'r','LineWidth',3)
        title(['Load: ',num2str(loads_all(jj)),' mN/mm^2'])
        hold off; 
    end 
end 

%% Force-Velocity Fit 

loads_all =[loads_all;mean(Fmax)]; 
vel_all = [vel_all;0]; 
figure(2); 
plot(loads_all,vel_all,'ko') 
xlabel('Force (mN/mm^2)','FontSize',18)
ylabel('Velocity (\mu m/s)','FontSize',18)

% Getting the fit 
FV_fit = @(parms,Fdata) parms(2)*((mean(Fmax)+parms(1))./(Fdata + parms(1)) - 1); 
x0 = [1,1]; 
opts = optimset('Display','off');
my_fit = lsqcurvefit(FV_fit,x0,loads_all,vel_all,[],[],opts); 

f_fit = linspace(0,max(loads_all),1000); 
v_fit = FV_fit(my_fit,f_fit); 

hold on; 
plot(f_fit,v_fit,'r--','LineWidth',2)

hold off; 


%% Force-Power Fit 

figure(3); 
power_all = loads_all.*(vel_all./1000); 
PF_fit = @(parms,Fdata) parms(2).*Fdata.*((mean(Fmax)+parms(1))./(Fdata + parms(1)) - 1); 
x0 = [1,1]; 
opts = optimset('Display','off');
my_fit2 = lsqcurvefit(PF_fit,x0,loads_all,power_all,[],[],opts); 

f_fit = linspace(0,max(loads_all),1000); 
p_fit = PF_fit(my_fit2,f_fit); 


plot(loads_all,power_all,'ko')

xlabel('Force (mN/mm^2)','FontSize',18)
ylabel('Power (W/s)','FontSize',18)
hold on; 
plot(f_fit,p_fit,'r--','LineWidth',2) 
hold off; 

%% Creating a vector of data to copy 
Fmax_new = [Fmax;loads_all(end)]; 
F_Fmax = loads_all./Fmax_new; 
data_to_copy = [loads_all,Fmax_new,F_Fmax,vel_all,power_all]; 
data_to_copy = sortrows(data_to_copy,3); 

%% Displaying Results 


disp(strcat("Fmax: ",num2str(mean(Fmax)), " mN/mm^2"));
disp(strcat("Vmax: ",num2str(v_fit(1)), " um/s"));
disp(strcat("Pmax: ",num2str(max(p_fit)), " W/s"));


