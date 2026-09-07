% Copyright (C) 2009-2022 Wellcome Centre for Human Neuroimaging

% PREPROCESSING PIPELINE EEG DATA 

%% Setting Paths

clear; clc; 

project_root = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project';
spm_path = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/MATLAB/spm25';

addpath(spm_path);
addpath('/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/DrosteEffect-BrewerMap-b373eab');

cd(project_root);

spm('defaults', 'EEG');

%% Loading and Converting Data

S = [];
S.dataset = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/group1/01EEG/SPNCartoons_ID01.bdf';
S.mode = 'continuous';
S.channels = {'EEG', 'EXG1', 'EXG2', 'EXG3', 'EXG4'};
S.eventpadding = 0;
S.blocksize = 3276800;
S.checkboundary = 1;
S.saveorigheader = 0;
S.outfile = 'SPNCartoons_ID01';
S.conditionlabels = {'Undefined'};
S.inputformat = [];
D = spm_eeg_convert(S);

D = chantype(D, D.indchannel('EXG1'), 'EOG'); 
D = chantype(D, D.indchannel('EXG2'), 'EOG'); 

D = chantype(D, D.indchannel('EXG3'), 'EOG');
D = chantype(D, D.indchannel('EXG4'), 'EOG');
D.save(); 

% Prepare (load sensor file)
S = [];
S.D = D;

S.task = 'loadeegsens';
S.source = 'locfile';
S.sensfile = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/group1/00Behavioural/neuronavigation/SPNCartoons_ID01.sfp';

D = spm_eeg_prep(S);

%% Interpolating Bad Channels
D = spm_interpolate_bad_channels(D);
 
%% Montage

S = [];
S.D = 'interpolate_SPNCartoons_ID01.mat'; 
S.mode = 'write';
S.blocksize = 655360;
S.prefix = 'M';
S.montage = 'avref_eog.mat';
S.keepothers = 1;
S.keepsensors = 1;
S.updatehistory = 1;
D = spm_eeg_montage(S);

%% High pass filter

S = [];
S.D = 'Minterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.1;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);
%% Downsampling

S = [];
S.D = 'fMinterpolate_SPNCartoons_ID01.mat';
S.fsample_new = 200;
S.prefix = 'd';
D = spm_eeg_downsample(S);

%% Low pass filtering

S = [];
S.D = 'dfMinterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

%% Eye blink removal
% Ensure SPM is in the path
S = [];
S.D = 'fdfMinterpolate_SPNCartoons_ID01.mat';
S.mode = 'mark'; % Change 'Mode' to 'Mark'
S.methods.fun = 'eyeblink'; % Detection algorithm
S.methods.settings.threshold = 4;
S.methods.channels = 'VEOG';
S.methods.settings.excwin = 0;
D_ebf = spm_eeg_artefact(S);

%check the events that have been added to the file
%display_SPM_data(D_ebf)

% create epoched events around eyeblinks (and then average)
S = []; 
S.D = D_ebf; 
S.timewin = [-500 500];
S.trialdef(1).conditionlabel = 'Eyeblink'; 
S.trialdef(1).eventtype = 'artefact_eyeblink';
S.trialdef(1).eventvalue = 'VEOG';
S.prefix = 'eyeblink';
D_ebf = spm_eeg_epochs(S); 

pause

S = []; 
S.D = D_ebf; 
D_ebf = spm_eeg_average(S); 

% spatial confounds
S = []; 
S.D = D_ebf; 
S.mode = 'SVD'; 
S.timewin = [-inf inf]; 
S.ncomp = 1; %to change with the right number of components!
D_ebf = spm_eeg_spatial_confounds(S); 

S = []; 
S.D = D; 
S.mode = 'SPMEEG';
S.conffile = D_ebf; 
D = spm_eeg_spatial_confounds(S); 

S = []; 
S.D = D; 
S.mode = 'SSP';
D = spm_eeg_correct_sensor_data(S); 
fprintf('Current dataset: %s\n', D.fname);

%% Epoching

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
S.bc = 1;
S.prefix = 'e';
S.eventpadding = 0;
D = spm_eeg_epochs(S);

%% Artefact removal

S = [];
S.D = 'eTfdfMinterpolate_SPNCartoons_ID01.mat';
S.mode = 'reject';
S.badchanthresh = 0.2;
S.methods.channels = {'EEG'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 200;
S.append = true;
S.prefix = 'a';
D = spm_eeg_artefact(S);

%check the bad segments (does it make sense?)
%display_SPM_data(D)

%% Averaging

S = [];
S.D = 'aeTfdfMinterpolate_SPNCartoons_ID01.mat';
S.robust.ks = 3;
S.robust.bycondition = false;
S.robust.savew = false;
S.robust.removebad = true;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

%% Reapplied Low pass filtering

S = [];
S.D = 'maeTfdfMinterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);
