% fv_analysis.m

close all; 
clear; 
clc; 

%% Data Importation 

A = xlsread('fv_data_bin.xlsx'); 
N_cells = round(size(A,2)/5); 

% defining bins 
bins = [0,0.05,0.15,0.25,0.35,0.45,0.55,0.65,0.75,1]; 
data_out = zeros(length(bins),3); 

groups = zeros(size(A,1),N_cells); 

for ii = 1:N_cells
    f_norm = A(:,5*ii-2); 
    vel = A(:,5*ii-1);
    power = A(:,5*ii); 
    
    % Defining groups 
    
    for jj = 1:(length(bins)-1)
        f_binned = (f_norm > bins(jj) ) & (f_norm < bins(jj+1)); 
        groups(:,ii) = f_binned.*jj + groups(:,ii); 
    end 
end 

groups(end,:) = 10; % final group is 1, which is its own group 

%% Now using the groups to bin the data - and average 

fmat = A(:,[3:5:end]);
vmat = A(:,[4:5:end]); 
pmat = A(:,[5:5:end]); 


for bb = 1:10 
    [rows,cols] = find(groups == bb); 
    fbb = reshape(fmat(rows,cols),[],1); 
    vbb = reshape(vmat(rows,cols),[],1); 
    pbb = reshape(pmat(rows,cols),[],1);
    
    data_out(bb,1) = mean(fbb); 
    data_out(bb,2) = std(fbb); 
    data_out(bb,3) = mean(vbb); 
    data_out(bb,4) = std(vbb);
    data_out(bb,5) = mean(pbb); 
    data_out(bb,6) = std(pbb);

    
end 
