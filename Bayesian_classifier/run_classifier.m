%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% University of Leeds
% School of Mechanical Engineering
% Institute of Design, Robotics and Optimisation (iDRO)
%
% author: Uriel Martinez-Hernandez
% program name: run_classifier.m
% date: February 2018
% version: 1.0
%
% This program is part of the project 'Wearable soft robotics for
% independent living' funded by EPSRC.
%
% Description:
% This program prapares the training datasets for the Bayesian classifier.
% From the training process, the variables 'p' and 'd' are created, where
% 'p' represents the probabilities of the activities and transition
% classes. The variable 'd' represents the histrograms calculated from each
% activity and transition class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p d] = run_classifier(expt, Nwhisks, suffix, histogram_value)

% args
if nargin < 3
	suffix = '_none'; % default
end

ncs = length(expt.trainingClasses);
nxydws = expt.trainingNwhisks;
nxydws = length(expt.trainingXs)*length(expt.trainingYs)*length(expt.trainingDs)*length(expt.trainingWs);
nwhisks = expt.trainingNwhisks;

% only use first Nwhisks (for test/training separation)
if ~exist('Nwhisks','var'); Nwhisks = nwhisks; end

% loop through classes
for ic = 1:ncs
    
  % load training data
  fname = ['multiple_data_' expt.trainingClasses{ic} suffix];

  % load data
  if ~expt.store
    
    % load data from job
    warning off; load([expt.path filesep fname '.mat']); warning on
    
    % extract data
    indices = find(~job.out.feedback.inhibitWPG) + 1;
    data{ic} = job.out.datapack.macro; clear job
    data{ic} = [squeeze(data{ic}(1, :, :, indices)); squeeze(data{ic}(2, :, :, indices))];
    data{ic} = permute(data{ic}, [2 1 3]);
    
  else
    
    % load data from store
    load([expt.path filesep fname '_store.mat']);
        
    % extract data
    for ixydw = 1:nxydws
      for iwhisk = 1:nwhisks
        ind = sub2ind([nxydws, nwhisks], ixydw, iwhisk);
        data{ic}(:, :, ind) = store{ind+1}{1};
      end
    end
    
  end
  
  % construct position classes
  for ixydw = 1:nxydws
    data_train{ic, ixydw} = [];
    for iw = 1:Nwhisks
       data_train{ic, ixydw} = [data_train{ic, ixydw}; data{ic}(:, :, (ixydw-1)*nwhisks + iw)];
    end
  end
  
end

% train classifier
Bayesian_classifier([], data_train(:), [expt.path filesep 'multiple_pclass' suffix], histogram_value);


% load results into workspace
load([expt.path filesep 'multiple_pclass' suffix], 'p', 'd');
