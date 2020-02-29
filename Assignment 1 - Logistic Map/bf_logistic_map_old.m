function [] = bf_logistic_map_old(lambdaMin, lambdaMax, N)

lambdas = linspace(lambdaMin, lambdaMax, N+2);

n = 400;
x = zeros(length(lambdas), n);

for i = 1:length(lambdas)
    x(i,1) = .5;
    for j = 1:n-1
        x(i,j+1) = lambdas(i) * x(i,j) * (1 - x(i,j));
	end
end

x = x(:,[n*.75:n]);

plot(lambdas, x, 'k.', 'markersize', 1);
title('Bifurcation diagram of the logistic map'); 
xlabel('r');  ylabel('x_n'); 
set(gca, 'xlim', [lambdaMin lambdaMax]); 
set(gcf, 'Position',  [100, 100, 800, 600])

return