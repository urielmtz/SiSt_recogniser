%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% University of Leeds
% School of Mechanical Engineering
% Institute of Design, Robotics and Optimisation (iDRO)
%
% author: Uriel Martinez-Hernandez
% program name: controller.m
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


classdef controller < handle 
    properties
        state
        store

        ixydw

        nxydws
        ncs

        logp
        logpr

        p_history
        h
    end
    
    methods
        function mach = controller(state)
            % store
            mach.store = {};

            % state
            mach.state = state;

            % some vars
            cond = state.cond;
            nxs = length(cond.trainingXs);
            nys = length(cond.trainingYs);
            nds = length(cond.trainingDs);
            nws = length(cond.trainingWs);

            mach.nxydws = nxs*nys*nds*nws;
            mach.ncs = length(cond.classes);

            % set initial position
            if isfield(state, 'ixydw_init')
                mach.ixydw = state.ixydw_init;
            else
                RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
                mach.ixydw = randi(mach.nxydws);
            end

            % flat log prior
            mach.logpr = -log(mach.ncs*mach.nxydws) * ones(mach.ncs, mach.nxydws);

            % initialise log posterior with log prior
            mach.logp = mach.logpr;      

            % storage of probability history
            mach.p_history(:, :, 1) = mach.logp;

            % store init
            mach.state.ixydw_init = mach.ixydw;
            mach.store{end+1} = state;
        end

        function ixydw = getPosition(mach)
            ixydw = mach.ixydw;
        end

        function result = step(mach, WHISK_DATA, histogram_value)
            % store data
            mach.store{end+1} = {WHISK_DATA mach.ixydw};

            % set machine to continue
            result.continue = true;

            % default position same as now
            result.ixydw = mach.ixydw;

            % evaluate log likelihood for whisk
            [~, logl] = Bayesian_classifier(WHISK_DATA, [], mach.state.classifier, histogram_value);

            nis = size(WHISK_DATA, 1); % note scale logl by sample number
            logl = 1/nis * reshape(logl, [mach.ncs mach.nxydws]);

            % Bayes update of log posterior
            loglp = logl + mach.logp;
            logm = log(sum(exp(loglp(:))));
            mach.logp = loglp - logm;

            % store posterior history
            mach.p_history(:, :, end+1) = exp(mach.logp);

            % inferred position and class
            [mlogp_1 i_est_1] = max(mach.logp, [], 1);
            [mlogp ixydw_est] = max(mlogp_1);
            ic_est = i_est_1(ixydw_est);

            % return inferred position and class
            result.ixydw_est = ixydw_est;
            result.ic_est = ic_est;

            result.ic_beliefs = mlogp;
            result.ixydw_beliefs = mach.logp;

            % check if decision threshold reached
            if mlogp > mach.state.logth

                if ~mach.state.notext
                    fprintf('STOP: mp_c = %4.2f @ ic_est = %i\n\n', [exp(mlogp_c) ic_est]);
                end

                % STOP
                result.continue = false;
            end      
        end

        function terminate(mach)      
            % save store
            if isfield(mach.state, 'store')
                store = mach.store;
                save(mach.state.store, 'store')
            end        
        end
    end
end

