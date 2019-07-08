
clear;
close all;
clc;

% load colour schemes
load('cmap/inferno.mat');
cm = cm(40:end,:);
cm_inferno = cm;
load('cmap/magma.mat');
cm = cm(40:end,:);
cm_magma = cm;
load('cmap/plasma.mat');
cm_plasma = cm;
load('cmap/viridis.mat');


%%

% load('..\Data\Soot Data FlareNet 18\20180601_E.mat');
% load('..\Data\Soot-Salt Data M9 Flame\data_flameM9_soot+salt_v1.mat');
load('..\Data\Soot-Salt Data UA May 2019\20190509_SMPS\20190509g_SMPS.mat');

data = data';
b_max = max(max(data));
b = data(:)./b_max;
edges_b = {data_m,data_d'};
grid_b = Grid(edges_b,...
    [],'logarithmic');
sig = sqrt(data(:))+max(sqrt(data(:))).*0.01;
Lb = diag(sqrt(1./sig));
%}

figure(5);
colormap(gcf,cm_inferno);
grid_b.plot2d_marg(b);

figure(20);
n2 = floor(grid_b.ne(1));
n3 = floor(length(cm_inferno(:,1))/n2);
cm_b = cm_inferno(10:n3:end,:);
set(gca,'ColorOrder',cm_b,'NextPlot','replacechildren');
b_plot_rs = reshape(b,grid_b.ne);
semilogx(grid_b.edges{2},b_plot_rs);


%%  Generate A and grid_x

ne_x = [50,80]; % number of elements per dimension in x
    % [20,32]; % used for plotting projections of basis functions
    % [40,64]; % used in evaluating previous versions of regularization

span = [10^-2,20;10,10^3];
    % Hogan lab: -1 -> 1.5
grid_x = Grid(span,...
    ne_x,'logarithmic');

r_x = grid_x.nodes;
edges_x = grid_x.edges;
n_x = grid_x.ne;

disp('Evaluate kernel...');
% load('A_3.mat');
A = gen_A(grid_b,grid_x); % generate A matrix based on grid for x and b


%% Exponential, rotated

s1 = 1.0;
s2 = 0.1;
dtot = @(d1,d2) sqrt(exp(d1).^2+exp(d2).^2);
theta = -atan2(1,2.5);%-45/180*pi;%-atan2(3,1);
Lex = diag([1/s1,1/s2])*...
    [cos(theta),-sin(theta);sin(theta),cos(theta)];
lambda_expRot = 2e-4; % 5e-4

disp('Performing rotated exponential distance regularization...');
tic;
[x_expRot,L] = exponential_distance(Lb*A,Lb*b,grid_x.elements(:,2),grid_x.elements(:,1),...
    lambda_expRot,Lex);
t.expRot = toc;
disp('Inversion complete.');
disp(' ');

%%
x_plot = x_expRot;

figure(10);
colormap(gcf,cm);
grid_x.plot2d_marg(x_plot);

figure(13);
load('cmap/viridis.mat');
n1 = ceil(grid_x.ne(1)./20);
n2 = floor(grid_x.ne(1)/n1);
n3 = floor(240/n2);
cm_b = cm(10:n3:250,:);
set(gca,'ColorOrder',cm_b,'NextPlot','replacechildren');
x_plot_rs = reshape(x_plot,grid_x.ne);
semilogx(grid_x.edges{2},x_plot_rs(1:n1:end,:));

figure(10);



%% Plots for effective density

[y,rho_vec,dNdlogrho] = ...
    tools.massmob2rhomob(x_expRot,grid_x);

figure(30);
semilogx(rho_vec,dNdlogrho);

figure(31);
% imagesc(log10(grid_x.edges{2}),log10(rho_vec),max(log10(y),max(max(log10(y))).*0.1));
imagesc(log10(grid_x.edges{2}),log10(rho_vec),y);
set(gca,'YDir','normal');
colormap(cm);


