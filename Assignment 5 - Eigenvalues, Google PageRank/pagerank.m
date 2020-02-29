function [] = pagerank(relations,urls,show_plot,top_max,p)
%This function determines the Google page rankings using the power method
%   PAGERANK(RELATIONS,URLS,SHOW_PLOT,TOP_MAX,P)
%   tries to find the Google page rank of the sparse input matrix RELATIONS
%   using the power method with probability P. Default is 85% for Google
%   page rank. The result will be a nx1 cell array containing the top n
%   pageranks. The default value for n is 5, but can be changed by setting
%   TOP_MAX. It is also optional to show a plot of the page rank
%   distribution by setting SHOW_PLOT to true. The pageranks can be
%   connected to a URL input by giving an mx1 cell array as input for the
%   URLS parameter. The output will then change to an nx2 cell array, with
%   the second column the most popular URLs.

% Check if parameters are present, otherwise set defaults.
if ~exist('show_plot')
    show_plot = false;
end
if ~exist('top_max')
    top_max = 5;
end
if ~exist('p')
    p = 0.85;
end

% Get amount of websites.
n = length(relations);
% Calculate the out-degree c_j.
c = sum(relations, 1);
% Find all URLs with out degree.
c_non_zero = find(c~=0);
% Calculate 1/cj when c is non zero and create sparse matrix.
D = sparse(c_non_zero,c_non_zero,1./c(c_non_zero),n,n)
% Create identity matrix.
I = speye(n,n);
% Solve x = Bx, account for URLs that do not follow links with f.
x = (I-p*relations*D)\ones(n,1);
% Rescale to get page ranks.
pageranks = x/sum(x);

% Sort the found page ranks with the highest on top, then save it as a
% vector. Also save indices as a vector.
[topPageRanks, topIndices] = sort(pageranks, 'descend');

% Get only the top n values of the page rank and URLs for display. Also
% convert the vector to cell array.
topPageRanks = num2cell(topPageRanks(1:top_max));
urls         = urls(topIndices(1:top_max));

% If we have URL input, show the top n URLs, otherwise only show page ranks.
if exist('urls')
    [topPageRanks urls]
else
    [topPageRanks]
end

% If plot wanted, show it.
if show_plot
    % Bring figure to front.
    figure();
    bar(pageranks);
    title(['Page Rank per URL']);
    xlabel('URL Index');
    ylabel('Page Rank');
end

end