% Copyright (C) 2009-2022 Wellcome Centre for Human Neuroimaging

% PREPROCESSING PIPELINE EEG DATA 

%===================================================================================
%% Setup

% clear workspace and command window
clear; clc; 

% set project root
project_root = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/preprocessing_ID01';

% add path to spm and to the brewermap package
spm_path = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/MATLAB/spm25';
addpath(spm_path);
addpath('/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/DrosteEffect-BrewerMap-b373eab');

% set the current directory to the project root
cd(project_root);

% initialise SPM
spm('defaults', 'EEG');

%===================================================================================
%% Loading and Converting Data

% convert from .bdf format to SPM's format
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

% the four external channels (EXG1-EXG4) contain EOG signals
% we manually change their channel type from default to EOG
D = chantype(D, D.indchannel('EXG1'), 'EOG'); 
D = chantype(D, D.indchannel('EXG2'), 'EOG'); 
D = chantype(D, D.indchannel('EXG3'), 'EOG');
D = chantype(D, D.indchannel('EXG4'), 'EOG');
D.save(); 

% prepare the sensor file
% i.e. the electrode-location file obtained from neuronavigation
% required for spatial operations, such as bad-channel-interpolation
S = [];
S.D = D;
S.task = 'loadeegsens';
S.source = 'locfile';
S.sensfile = '/Users/vanessaobi/Documents/Uni/Master/SS 26/EEG/project/group1/00Behavioural/neuronavigation/SPNCartoons_ID01.sfp';
D = spm_eeg_prep(S);

%===================================================================================
%% Interpolating Bad Channels

% The function "spm_interpolate_bad_channels" opens the FieldTrip data browser. We 
% visually inspect the EEG and decide which signals are bad. We visually identified 
% only CP3 to be bad for ~20% of the time. We therefore have to interpolate it.

% enter {'CP3'} to interpolate the channel
D = spm_interpolate_bad_channels(D);

%===================================================================================
%% Montage

% re-references the EEG channels to the average reference
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

%===================================================================================
%% High pass filter

% We apply a 0.1 Hz high-pass filter.

S = [];
S.D = 'Minterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.1;
S.dir = 'twopass';
S.order = 4; % 5th order gets reduced to 4th order
S.prefix = 'f';
D = spm_eeg_filter(S);

%===================================================================================
%% Downsampling

% We downsample to 200 Hz.

S = [];
S.D = 'fMinterpolate_SPNCartoons_ID01.mat';
S.fsample_new = 200;
S.prefix = 'd';
D = spm_eeg_downsample(S);

%===================================================================================
%% Low pass filtering

% We apply a 30 Hz low-pass filter.

S = [];
S.D = 'dfMinterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 4; % 5th order gets reduced to 4th order
S.prefix = 'f';
D = spm_eeg_filter(S);

%===================================================================================
%% Eye blink removal

% detect eyeblinks and mark them as events
S = [];
S.D = 'fdfMinterpolate_SPNCartoons_ID01.mat';
S.mode = 'mark'; % Change 'Mode' to 'Mark'
S.methods.fun = 'eyeblink'; % Detection algorithm
S.methods.settings.threshold = 4;
S.methods.channels = 'VEOG';
S.methods.settings.excwin = 0;
D_ebf = spm_eeg_artefact(S);

% check the events that have been added to the file
% display_SPM_data(D_ebf)

% create epoched events around eyeblinks
S = []; 
S.D = D_ebf; 
S.timewin = [-500 500];
S.trialdef(1).conditionlabel = 'Eyeblink'; 
S.trialdef(1).eventtype = 'artefact_eyeblink';
S.trialdef(1).eventvalue = 'VEOG';
S.prefix = 'eyeblink';
D_ebf = spm_eeg_epochs(S); 

pause

% average all blink epochs
S = []; 
S.D = D_ebf; 
D_ebf = spm_eeg_average(S); 

% extract the dominant blink component with SVD
% SVD = "singular value decomposition"
% i.e. "What pattern across all EEG electrodes explains most of the blink?"
S = []; 
S.D = D_ebf; 
S.mode = 'SVD'; 
S.timewin = [-inf inf]; 
S.ncomp = 1;
D_ebf = spm_eeg_spatial_confounds(S); 

% attach blink component as spatial confound to original EEG
S = []; 
S.D = D; 
S.mode = 'SPMEEG';
S.conffile = D_ebf; 
D = spm_eeg_spatial_confounds(S); 

% actually remove the blink contribution using SSP
% SSP = "signal space projection"
S = []; 
S.D = D; 
S.mode = 'SSP';
D = spm_eeg_correct_sensor_data(S); 
fprintf('Current dataset: %s\n', D.fname);

%===================================================================================
%% Epoching H1

% segment recording into stimulus-locked epochs
% epochs of -100 to +400ms relative to stimulus onset
S = [];
S.D = 'TfdfMinterpolate_SPNCartoons_ID01.mat';
S.timewin = [-100 400];

% Trials are assigned to High or Low based on the STATUS triggers.

% high condition
S.trialdef(1).conditionlabel = 'High';
S.trialdef(1).eventtype = 'STATUS';
S.trialdef(1).eventvalue = 1;
S.trialdef(1).trlshift = 0;

% low condition
S.trialdef(2).conditionlabel = 'Low';
S.trialdef(2).eventtype = 'STATUS';
S.trialdef(2).eventvalue = 2;
S.trialdef(2).trlshift = 0;

% do NOT use SPM's default baseline correction
S.bc = 0;

% create epoched dataset
S.prefix = 'e';
S.eventpadding = 0;
D = spm_eeg_epochs(S);

% number of trials in each condition
nHigh = sum(strcmp(D.conditions, 'High'));
nLow  = sum(strcmp(D.conditions, 'Low'));

fprintf('High condition: %d trials\n', nHigh);
fprintf('Low condition:  %d trials\n', nLow);
fprintf('Total:           %d trials\n', nHigh + nLow);

%===================================================================================
%% Baseline correction H1

% baseline-correct each epoch using the mean EEG amplitude from -100 to -5 ms 
% relative to stimulus onset
S = [];
S.D = D;
S.timewin = [-100 -5];
S.prefix = 'b';
D = spm_eeg_bc(S);

%===================================================================================
%% Epoching H2

% load the original trial definition
% --> there is a script to generate this file on this repo!
load(fullfile(project_root, 'trialdef.mat'));

% convert condition labels to a column string array
conds_str = string(conditionlabels(:));

% ensure block IDs are also a column vector
block_id = block_id(:);

% identify adjacent trials that belong to the same experimental block
same_block = block_id(2:end) == block_id(1:end-1);

% identify High/Low intensity changes between adjacent trials
is_change = conds_str(2:end) ~= conds_str(1:end-1);

% identify valid within-block transitions
Dev_pos = find(is_change & same_block) + 1;
Std_pos = Dev_pos - 1;

% keep Standard + Deviant trials in presentation order
keep_pos = sort([Std_pos; Dev_pos]);

% extract corresponding trials
new_trl = trl(keep_pos, :);

% assign Standard/Deviant labels
new_conditionlabels = cell(length(keep_pos), 1);
new_conditionlabels(1:2:end) = {'Standard'};
new_conditionlabels(2:2:end) = {'Deviant'};

% segment recording into stimulus-locked epochs
% epochs of -100 to +400ms relative to stimulus onset
S = [];
S.D = 'TfdfMinterpolate_SPNCartoons_ID01.mat';
S.timewin = [-100 400];
S.trl = new_trl;
S.conditionlabels = new_conditionlabels; 

% do NOT use SPM's default baseline correction
S.bc = 0;

% create epoched dataset
S.eventpadding = 0;
S.prefix = 'std_dev_';
D = spm_eeg_epochs(S);

% number of trials in each condition
nStandard = sum(strcmp(D.conditions, 'Standard'));
nDeviant  = sum(strcmp(D.conditions, 'Deviant'));

fprintf('Standard condition: %d trials\n', nStandard);
fprintf('Deviant condition:  %d trials\n', nDeviant);
fprintf('Total:               %d trials\n', nStandard + nDeviant);

%===================================================================================
%% Baseline correction H2

% baseline-correct each epoch using the mean EEG amplitude from -100 to -5 ms 
% relative to stimulus onset
S = [];
S.D = D;
S.timewin = [-100 -5];
S.prefix = 'b';
D = spm_eeg_bc(S);

%===================================================================================
%% Artefact removal H1

% reject epochs containing residual EEG amplitudes exceeding ±80 µV
S = [];
S.D = 'beTfdfMinterpolate_SPNCartoons_ID01.mat';
S.mode = 'reject';
S.badchanthresh = 0.2;
S.methods.channels = {'EEG'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 200;
S.append = true;
S.prefix = 'a';
D = spm_eeg_artefact(S);

% check the bad segments (does it make sense?)
% display_SPM_data(D)

%===================================================================================
%% Artefact removal H2

% reject epochs containing residual EEG amplitudes exceeding ±80 µV
S = [];
S.D = 'bstd_dev_TfdfMinterpolate_SPNCartoons_ID01.mat';
S.mode = 'reject';
S.badchanthresh = 0.2;
S.methods.channels = {'EEG'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 200;
S.append = true;
S.prefix = 'a';
D = spm_eeg_artefact(S);

% check the bad segments (does it make sense?)
% display_SPM_data(D)

% 199 rejected trials

%===================================================================================
%% Robust Averaging H1

% estimate ERP for each condition using robust averaging
S = [];
S.D = 'abeTfdfMinterpolate_SPNCartoons_ID01.mat';
S.robust.ks = 3;
S.robust.bycondition = false;
S.robust.savew = false;
S.robust.removebad = true;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

%===================================================================================
% Reapplied Low pass filtering H1

% Robust averaging can introduce high-frequency components into the averaged 
% waveform. We therefore re-apply the 30 Hz low-pass filter to the robust average.

S = [];
S.D = 'mabeTfdfMinterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

%===================================================================================
%% Averaging H2

% estimate ERP for each condition using robust averaging
S = [];
S.D = 'abstd_dev_TfdfMinterpolate_SPNCartoons_ID01.mat';
S.robust.ks = 3;
S.robust.bycondition = false;
S.robust.savew = false;
S.robust.removebad = true;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

%===================================================================================
% Reapplied Low pass filtering H2

% Robust averaging can introduce high-frequency components into the averaged 
% waveform. We therefore re-apply the 30 Hz low-pass filter to the robust average.

S = [];
S.D = 'mabstd_dev_TfdfMinterpolate_SPNCartoons_ID01.mat';
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);
