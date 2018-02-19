%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% University of Leeds
% School of Mechanical Engineering
% Institute of Design, Robotics and Optimisation (iDRO)
%
% author: Uriel Martinez-Hernandez
% program name: test_program.m
% date: February 2018
% version: 1.0
%
% This program is part of the project 'Wearable soft robotics for
% independent living' funded by EPSRC.
% 
% Description:
% This program tests the Bayesian approach developed for recognition of
% sit-to-stand activity and transition phases during standing and sitting.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clear variables
clear all
clc

%% definition of variables, paths, filenames
save_data_output = 1;
minHistBin = 50;
maxHistBin = 100;
stepHistAnalysis = 10;
histogram_value = [minHistBin:stepHistAnalysis:maxHistBin];
actions_list = {'standup','sitdown','transit'};
path = '..\sample_data';
folder_name = '3state5transitionPhases';

path = [path filesep folder_name];

maxNumberOfIterations = 100;
noiseRatio = 100;


%% Load testing dataset
disp('=======================================');
disp('Loading and preparing testing datatset');
disp('=======================================');

disp([path filesep 'multiple_expt.mat']);    
load([path filesep 'multiple_expt.mat'], 'expt');

expt.rootpath = '';
expt.path = path;

% some variables
ncs = length(expt.trainingClasses);
nxydws = length(expt.trainingXs)*length(expt.trainingYs)*length(expt.trainingDs)*length(expt.trainingWs);
nwhisks = expt.trainingNwhisks;

% only test with last Nwhisks
Nwhisks = expt.testingNwhisks;

% parameters
state.cond = expt;
state.logth = nan;

% figure and text output
state.nofig = true;
state.notext = true;

% collect data together
for ic = 1:ncs    
    % filename    
    fname = ['multiple_data_' expt.testingClasses{ic} '_test'];

    % is data stored?
    expt.store = true;

    % load data
    if ~expt.store
    else
        % load data from store
        load([expt.path filesep fname '_store.mat']);
        disp([expt.path filesep fname '_store.mat']);

        % extract data
        for ixydw = 1:nxydws
            for iwhisk = 1:nwhisks
                ind = sub2ind([nxydws, nwhisks], ixydw, iwhisk);                    
                data{ic}(:, :, ind) = store{ind+1}{1};
            end                
        end            
    end
end


%% recognition of SiSt activity and transition phases

for h_iter=1:length(histogram_value)

    % load classifier from pclass
    disp('=======================================');
    disp('Loading an preparing training datatset');
    disp(['Histogram bins = ' num2str(histogram_value(h_iter))]);
    disp('=======================================');

    run_classifier(expt, Nwhisks, '_train',histogram_value(h_iter));
    
    load([expt.path filesep 'multiple_pclass_train.mat'], 'p', 'd')
    state.classifier.p = p;
    state.classifier.d = d;
    
    
    output_all = {};
    logths = log( [0.0:0.1:0.9 0.95 0.99 0.995 0.999] ); nths = length(logths);

    for ith = 1:nths
        % set thresholds (state)
        state.logth = logths(ith);

        % initialize outputs
        output.ic = [];
        output.ixydw = [];
        output.e_c = cell(ncs, nxydws);
        output.e_xydw = cell(ncs, nxydws);
        output.confusion_mat_class = zeros(ncs, ncs);
        output.confusion_mat_subclass = zeros(nxydws, nxydws);
        output.confusion_mat_subclass_no_transit = zeros(nxydws, nxydws);
        output.confusion_mat_transition = cell(1, nxydws);


        for trans=1:nxydws
            output.confusion_mat_transition{1,trans} = zeros(ncs, ncs);
        end


        for i = 1:maxNumberOfIterations
            % class and starting position
            ic = randi(ncs);
            ixydw = randi(nxydws);

            % set state
            state.ic = ic;
            state.ixydw_init = ixydw;

            % initialize position history
            ixydw_history = [];

            % start up machine
            machine = controller(state);
            result.ixydw = state.ixydw_init;
            result.continue = 1;

            % whisk range (last Nwhisks)
            rwhisks = (nwhisks-Nwhisks+1) : nwhisks;

            % loop machine
            while result.continue
                % available whisk?
                if isempty(rwhisks); null = 1; break; end

                % choose whisk
                iwhisk = rwhisks( randi(length(rwhisks)) );
                ind = iwhisk + (result.ixydw-1)*nwhisks;

                % position history
                ixydw_history(end+1) = result.ixydw;

                r_line = data{ic}(randi([1 length(data{ic}(:,:,ind))],4,1),:,ind);
                result = step(machine, awgn(r_line, noiseRatio, 'measured'),histogram_value(h_iter));
            end

            % terminate machine
            machine.terminate();

            % process outputs
            output.ic(end+1) = state.ic;
            output.ixydw{end+1} = ixydw_history;
            output.e_c{ic, ixydw}(end+1) = ic - result.ic_est;

            if( ic == 1 || ic == 2 )
                output.e_xydw{ic, ixydw}(end+1) = result.ixydw - result.ixydw;
                output.confusion_mat_subclass_no_transit(ixydw, ixydw) = output.confusion_mat_subclass_no_transit(ixydw, ixydw) + 1;
            else
                output.e_xydw{ic, ixydw}(end+1) = result.ixydw - result.ixydw_est;
                output.confusion_mat_subclass(ixydw, result.ixydw_est) = output.confusion_mat_subclass(ixydw, result.ixydw_est) + 1;
            end
            output.confusion_mat_class(ic, result.ic_est) = output.confusion_mat_class(ic, result.ic_est) + 1;

            output.confusion_mat_transition{1,ixydw}(ic, result.ic_est) = output.confusion_mat_transition{1,ixydw}(ic, result.ic_est) + 1;
        end
        % store output
        output_all{ith} = output;
    end

    if( save_data_output == 1 )
        save([expt.path filesep 'output_histBin_' num2str(histogram_value(h_iter)) '_testing'], 'output_all', 'expt', 'logths')
    end
end
