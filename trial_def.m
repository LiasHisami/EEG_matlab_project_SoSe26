%trial definition

project_root = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/preprocessing_ID01';
cd(project_root);

S = [];
S.D = 'TfdfMinterpolate_SPNCartoons_ID01.mat';
S.timewin = [-100 400];
S.trialdef(1).conditionlabel = 'High';
S.trialdef(1).eventtype = 'STATUS';
S.trialdef(1).eventvalue = 1;
S.trialdef(1).trlshift = 0;
S.trialdef(2).conditionlabel = 'Low';
S.trialdef(2).eventtype = 'STATUS';
S.trialdef(2).eventvalue = 2;
S.trialdef(2).trlshift = 0;
S.reviewtrials = 0; 
S.save = 1; 
[trl, conditionlabels, S] = spm_eeg_definetrial(S); 
