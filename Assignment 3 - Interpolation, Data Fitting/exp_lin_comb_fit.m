function [] = exp_lin_comb_fit(data, initial_guess_lambdas, max_evals)
%exp_lin_comb Fit a linear combination of exponential functions to data.
%   EXP_LIN_COMB_FIT(DATA, INITIAL_GUESS_LAMBDAS, MAX_EVALS) tries to fit a 
%   line on the input DATA by creating a combination of exponential
%   functions. A function is found by using the INITIAL_GUESS_LAMBDAS
%   vector as start variables of the function, and then finding optimal
%   values in the neighbourhood of this input.
%   After method completion, a graph will be shown with the data points and
%   fitted line printed. The console will return the constants, lambdas
%   and residue of the found function.
%   The option MAX_EVALS is optional, if nothing is input it will default
%   to the default value of 200 times the amount of variables in the guess.

% Set default values. Default MaxFunEvals of fminsearch is
% 200*numberOfVariables per documentation.
if nargin < 3
    max_evals = 200*length(initial_guess_lambdas);
end

% Input data is an (m x 2) matrix. With columns 1 and 2 being x and y
% respectively.
x = data(:, 1);
y = data(:, 2);

% We want to minimise residue, so the least squares function should be on
% ||AC-y||, with A being the vector of all e-powers and C being A\y.
least_squares_function = @(lambdas) norm(exp(x*lambdas) * (exp(x*lambdas)\y) - y);

% With the initial guess, try to find lambdas where the residue is the
% smallest with fminsearch.
best_found_lambdas = fminsearch(least_squares_function, initial_guess_lambdas, ...
    optimset('MaxFunEvals', max_evals));

% With the found lambdas, calculate A, C and the residue.
A       = exp(x*best_found_lambdas);
C       = A\y;
residue = norm(A*C-y);

% The fit line has the x values of the input and the y values A*C.
x_line = x;
y_line = A*C;

% Print out all the values.
disp(['constants : ' num2str(C')                ]);
disp(['lambdas   : ' num2str(best_found_lambdas)]);
disp(['residue   : ' num2str(residue)           ]);

% Plot the data as black dots and the fit line as red line.
hold on;
plot(x,      y,      'k.');
plot(x_line, y_line, 'r-', 'LineWidth', 2);
title('Data Points with Fitted Line of Linear Combination of Exponential Functions');
legend('data points', 'function');
hold off;