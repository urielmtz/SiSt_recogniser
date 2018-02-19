%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% University of Leeds
% School of Mechanical Engineering
% Institute of Design, Robotics and Optimisation (iDRO)
%
% author: Uriel Martinez-Hernandez
% program name: Bayesian_classifier.m
% date: February 2018
% version: 1.0
%
% This program is part of the project 'Wearable soft robotics for
% independent living' funded by EPSRC.
%
% Description:
% This program is responsible to keep track and updated all variables and
% objects created during the recognition process.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [c,logp] = Bayesian_classifier(test,train,file_p,d,ns)

    % defaults if not set
    if ~exist('d','var')
        d = 200;
    elseif isempty(d)
        d = 200;
    end

    if ~exist('ns','var')
        ns = 2;
    end

    if ~iscell(test)
        test = {test};
    end

%% calculate/load likelihood from training data
    if isempty(train)
        if isstruct(file_p)
            p = file_p.p;
            d = file_p.d;
        else
            load(file_p,'p','d')
        end
    else
        ntrain = length(train);
        rtrain = 1:ntrain;
        nn = size(train{1},2);
        rn = 1:nn;

        % min and max of range
        for i = rtrain
            for n = rn
                ltrain_n(i,n) = min(train{i}(:,n));
                mtrain_n(i,n) = max(train{i}(:,n));
            end
        end
        ltrain = min(ltrain_n, [], 1); mtrain = max(mtrain_n, [], 1);

        % make sure d is right size
        if length(d)==1
            nd = fix(d); clear d
            for n = rn
                d(:,n) = linspace(ltrain(n)-eps,mtrain(n)+eps,nd+1);
            end
        end
        if any(size(d)==1); d = d(:); d = repmat(d,[1,nn]); end

        % find likelihood
        for i = rtrain
            p{i} = find_p(train{i},d,ns);
        end

        if exist('file_p','var')
            if ~isempty(file_p)
                save(file_p,'p','d');
            end
        end

        if isempty(test{1})
            return;
        end
    end

%% calculate summed likelihood over test data
    ntest = length(test);
    rtest = 1:ntest;
    ntrain = length(p);
    rtrain = 1:ntrain;
    nn = size(p{1},2);
    rn = 1:nn;

    % only sum over dims with nonzero prob
    rn = rn(logical(sum(p{1},1)));

    % find values of distn
    for i = rtest
        for n = rn
            [dummy,bin_test{i}(:,n)] = histc(test{i}(:,n),d(:,n));
        end
        bin_test{i}(bin_test{i}==0) = 1;
    end

    % summed likelihood
    for i = rtest
        for j = rtrain
            for n = rn
                logl = log( p{j}(bin_test{i}(:,n),n)+eps );
                sum_logl_n(n) = sum( logl );
            end
            logp(i,j) = sum( sum_logl_n ); % naive over rn
        end
        [dummy,in] = max(logp(i,:),[],2); c(i) = squeeze(in);
    end

end

%% find probability distn
function px = find_p(x,d,ns)

    nn = size(x,2);
    rn = 1:nn;
    nd = size(d,1);

    % calculate likelihood
    for n = rn
        hx(:,n) = histc(x(:,n),d(:,n));
        px(:,n) = hx(:,n)/sum(hx(:,n));
    end

    % smooth probability distn
    g = @(n,si) exp(-(-n:n).^2/(2*si^2))/sum( exp(-(-n:n).^2/(2*si^2)) );
    if ns~=0
        for n = rn
            pxn = filter(g(ns,1),1,px(:,n));
            pxn(1:ns) = []; pxn(nd) = 0;
            px(:,n) = pxn/sum(pxn);
        end
    end
end
