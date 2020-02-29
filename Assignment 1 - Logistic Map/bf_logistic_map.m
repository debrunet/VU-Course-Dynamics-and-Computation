function [] = bf_logistic_map(lambdaMin, lambdaMax, N, x_0, n)
% This function produces a picture of the "attractor" for a sequence
% of values lambda (r) of the logistic map:
%
%                  x_{n+1} = lambda * x_n * (1 - x_n)
%
%   bf_logistic_map(lambdaMin, lambdaMax, N, x_0, n)
%   tries to plot a bifurcation diagram of the logistic map with variables
%   lambdaMin and lambdaMax, which are the values of interest for the
%   parameter lambda which creates an interval. This interval is divided
%   into N parts. The interval should in between or at maximum [0,4].
%   
%   x_0 is the initial value of x_n which is a number in [0,1]. x_n repre-
%   sents the ratio of existing population to the maximum possible
%   population.
%
%   The default values of N, x_0 and n are 2000, 0.5 and 400 respectively.

% check if all parameters are present, if not: fill in default values
if ~exist('N')
    N = 2000;
end;
if ~exist('x_0')
    x_0 = .5;
end;
if ~exist('n')
    n = 400;
end;

% check if parameters are correct
assert(lambdaMin>=0 && lambdaMin<=lambdaMax, ...
    'lambdaMin is not an element of [0, lambdaMax]');
assert(lambdaMax>=lambdaMin, lambdaMax<=4, ...
    'lambdaMax is not an element of [lambdaMin, 4]');
assert(x_0>=0 && x_0<=1, ...
    'x_0 is not an element of [0, 1]');

% create interval of [lambdaMin,lambdaMax] with N steps in between
% create vector of xs for every lambda
lambdas = linspace(lambdaMin, lambdaMax, N+2)';
x = zeros(length(lambdas), n+1);

% set initial x_0 on every row of x
x(:, 1) = x_0;

% apply the formula for every column, based on the previous column
% use point wise multiplication for better performance
for i = 1:n
    x(:, i+1) = lambdas .* x(:,i) .* (1 - x(:, i));
end;

% only use top 25% of n (large n)
x = x(:, .75*n:n);

% plot lambdas to x, black dots
plot(lambdas, x, 'black.', 'markersize', 1);

% add titles, axis and set window size
title(['Bifurcation Diagram for Logistic Map with ' ...
    '\lambda_{min} = ' num2str(lambdaMin) ...
    ', \lambda_{max} = ' num2str(lambdaMax) ...
    ', x_{0} = ' num2str(x_0) ...
    ', n = ' num2str(n) ...
    ', N = ' num2str(N)]);
xlabel('Value of r');
ylabel('Value of x');
set(gcf, 'Position',  [100, 100, 800, 600])

return;