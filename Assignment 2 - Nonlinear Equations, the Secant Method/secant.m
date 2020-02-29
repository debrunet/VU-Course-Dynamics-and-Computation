function [zero, niter] = secant(f, x1, x2, tol, nmax, varargin)
%SECANT Find function zeros.
%   ZERO=SECANT(FUN,X1,X2,TOL,NMAX) tries to find the zero ZERO of the
%   function FUN using the Secant method, an algorithm that uses a
%   succession of roots of secant lines as an approximation of the real root.
%   If the search fails an error message is displayed. FUN can also be an
%   inline object.
%   [ZERO,NITER]= SECANT(FUN,...) returns the iteration number at which
%   ZERO was computed.
%   
%   Default values of tolerance and maximum iterations are 0.001 and 1000
%   respectively.

if nargin < 5
    nmax = 1000;
end
if nargin < 4
    tol = .001;
end

x(1) = x1;
x(2) = x2;

line(linspace(x1 - 1, x2 + 1), feval(f, linspace(x1 - 1, x2 + 1), varargin{:})); % the function
line([0 0], ylim, 'Color', 'red'); % x-axis
line(xlim, [0 0], 'Color', 'red'); % y-axis
title(['Secant Method with Starting Values x_1=' num2str(x1) ' and x_2=' num2str(x2)]);
line([x(1), x(2)], [feval(f, x(1), varargin{:}), feval(f, x(2), varargin{:})], 'Color', 'black');

for i = 3:nmax
    x(i) = x(i - 1) - (feval(f, x(i - 1), varargin{:})) * ((x(i - 1) - x(i - 2)) / (feval(f, x(i - 1), varargin{:}) - feval(f, x(i - 2), varargin{:})));
    line([x(i - 1), x(i)], [feval(f, x(i - 1), varargin{:}), feval(f, x(i), varargin{:})], 'Color', 'black');
    if abs(x(i) - x(i - 1)) < tol
        niter = i - 2;
        zero = vpa(x(i));
        return
    end
end

fprintf(['secant stopped without converging to the desired tolerance', ...
  'because the maximum number of iterations was reached\n']);
return