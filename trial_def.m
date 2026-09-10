%===================================================================================
% Trial Definition for Standard vs. Deviant Analysis

% set project root and working directory
project_root = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/preprocessing_ID01';
cd(project_root);

% specify the preprocessed EEG dataset
S = [];
S.D = 'TfdfMinterpolate_SPNCartoons_ID01.mat';

% define stimulus-locked trials from -100 to +400ms relative to stimulus onset
S.timewin = [-100 400];

% high-intensity trials = STATUS trigger 1
S.trialdef(1).conditionlabel = 'High';
S.trialdef(1).eventtype = 'STATUS';
S.trialdef(1).eventvalue = 1;
S.trialdef(1).trlshift = 0;

% low-intensity trials = STATUS trigger 2
S.trialdef(2).conditionlabel = 'Low';
S.trialdef(2).eventtype = 'STATUS';
S.trialdef(2).eventvalue = 2;
S.trialdef(2).trlshift = 0;

% don't open the interactive trial-review window
S.reviewtrials = 0; 

% save resulting trial definition
S.save = 1; 

% generate trial definition
% 'trl' contains timing information for each trial
% 'conditionlabels' contains High/Low label in order
[trl, conditionlabels, S] = spm_eeg_definetrial(S); 
