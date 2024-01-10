% The resutlt 'est' is the coefficients for intercept fisrt, then all x's.

% read sample data. 
load('sample.mat')
tau=0.8;

%% 
%1) the general way to do quantile regression (interior points)
est = [];
pvalue = [];
tic
for i=1:500 % only calculated 500 x's of 10000, to save time
    [beta, p]=qr_standard([z x(:,i)], y, tau,'test','wald','method','interior');
    est = [est beta];
    pvalue = [pvalue p];
end
toc
%%

%2) the general way to do quantile regression (standard linear programming)
est = [];
pvalue = [];
tic
for i=1:500 % only calculated 500 x's of 10000, to save time
    [beta, p] = qr_standard([z x(:,i)], y, tau,'test','kernel');
    est = [est beta];
    pvalue = [pvalue p];
end
toc
%%
%3) fit all z's first, then add one x at each time
tic
[est, pvalue] = qr_add(z,x,y,tau,1,'test','kernel');  % for all 10000 x's
toc

%%
%4) change one x at each time
tic
[est, pvalue] = qr_alter(z,x(:,1:500),y,tau,1);  % for 500 x's
toc


%% Change 2 predictors at each regression %%%%
%5) fit all z's first, then add two x's at each time
tic
[est, pvalue] = qr_add(z,x,y,tau,2,'test','kernel');  % for all 5000 x's pairs
toc


%6) change two x's at each time
tic
[est, pvalue] = qr_alter(z,x(:,1:500),y,tau,2);  % for 250 x's pairs
toc

%% Compare algorithm with sequence of quantile level


tau = 0.01:0.02:0.99;
len =length(tau);
new = zeros(1, len);
original = zeros(1, len);
difference = zeros(1, len);
original_iter = zeros(1, len);
new_iter = zeros(1, len);

%7) qr_add for each quantile

est = cell(len, 1);
for i = 1:len
    [temest, ~, temtime, temiter, ~, ~] = qr_add_one_quantile(Z,X,Y,tau(i),1,'test','kernel');
    original(1, i) = temtime; %computing time
    original_iter(1, i) = temiter; % # of iteration
    est(i) = {temest};
end

%8) start with the warm solution of first quantile 

[est, ~, ziter, iter, ~, ~] = qr_add_across_quantile(Z,X,Y,tau,1,'test','kernel');
for q = 1:len
    new(1, q) = cell2mat(ziter1(q));
    new_iter(1, q) = cell2mat(iter1(q));
    % compare the difference
    difference(1, q) = sum(sum(abs((cell2mat(est1(q)) - cell2mat(est2(q)))/cell2mat(est1(q)))));
end