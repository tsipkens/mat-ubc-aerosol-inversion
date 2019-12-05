
% EXP_DIST_OPBF  Approximates optimal lambda for exponential distance solver by brute force method.
%=========================================================================%

function [x,lambda,out] = exp_dist_opbf(A,b,d_vec,m_vec,guess,x_ex,x0,solver)
%-------------------------------------------------------------------------%
% Inputs:
%   A       Model matrix
%   b       Data
%   n       Length of first dimension of solution
%   lambda  Regularization parameter
%   span    Range for 1/Sf, two entry vector
%   x_ex    Exact distribution project to current basis
%   Lex     Transformation to rotate space (Optional, default is indentity matrix)
%   x0      Initial guess for solver    (Optional, default is zeros)
%   solver  Solver                      (Optional, default is interior-point)
%
% Outputs:
%   x       Regularized estimate
%-------------------------------------------------------------------------%


%-- Parse inputs ---------------------------------------------%
if ~exist('solver','var'); solver = []; end
    % if computation method not specified

if ~exist('x0','var'); x0 = []; end % if no initial x is given
% x_ex is required
%--------------------------------------------------------------%

Gd_fun = @(y) [(y(3)/y(2))^2,y(4)*y(3)^2;y(4)*y(3)^2,y(3)^2]; % version for no correlation
    % y(2) = ratio, y(3) = ld, y(4) = Dm

lambda_vec = logspace(log10(0.7),log10(1.3),5);
ratio_vec = logspace(log10(1/5),log10(1/2),5); % ratio = ld/lm
ld_vec = logspace(log10(log10(1.5)),log10(log10(2)),5);
Dm_vec = linspace(2,3,4);

[vec_lambda,vec_ratio,vec_ld,vec_Dm] = ndgrid(lambda_vec,ratio_vec,ld_vec,Dm_vec);
vec_lambda = vec_lambda(:);
vec_ratio = vec_ratio(:);
vec_ld = vec_ld(:);
vec_Dm = vec_Dm(:);

disp('Optimizing exponential distance regularization (using least-squares)...');

tools.textbar(0);
out(length(vec_lambda)).chi = [];
for ii=1:length(vec_lambda)
    y = [vec_lambda(ii),vec_ratio(ii),vec_ld(ii),vec_Dm(ii)];
    
    out(ii).rho = y(4)*y(2);
    if out(ii).rho>1; continue; end % non-physical case
    
    out(ii).x = invert.exp_dist(...
        A,b,d_vec,m_vec,y(1),Gd_fun(y),x0,solver);
    out(ii).chi = norm(out(ii).x-x_ex);
    
    out(ii).lambda = vec_lambda(ii);
    out(ii).sm = vec_ratio(ii);
    out(ii).sd = vec_ld(ii);
    
    tools.textbar(ii/length(vec_lambda));
end

[~,ind_min] = min(chi);
x = out(ind_min).x;
lambda = out(ind_min).lambda;

end


