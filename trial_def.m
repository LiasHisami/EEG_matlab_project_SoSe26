%===================================================================================
% Trial Definition for Standard vs. Deviant Analysis

% Can be run on its own (after preprocessing.m has created the TfdfM... file)
% or is called automatically from preprocessing.m.
% set the participant first, e.g.  participant = 'ID02'; trial_def
if ~exist('participant', 'var'), participant = 'ID01'; end
if ~exist('P', 'var') || ~isfield(P, 'id') || ~strcmp(P.id, participant)
    cfg = project_config();
    P = participant_paths(cfg, participant);
end
cd(P.outdir);

% specify the preprocessed EEG dataset
S = [];
S.D = ['TfdfMinterpolate_' P.base '.mat'];

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
S.save = 0; 

% generate trial definition
% 'trl' contains timing information for each trial
% 'conditionlabels' contains High/Low label in order
[trl, conditionlabels, S] = spm_eeg_definetrial(S); 

%===================================================================================
% Assign trials to experimental blocks

% load events from the same EEG dataset
D = spm_eeg_load(S.D);
ev = events(D);

% keep only STATUS events
is_status = strcmp({ev.type}, 'STATUS');
status_events = ev(is_status);

% convert STATUS values to numeric values
status_values = cellfun(@double, {status_events.value});

% STATUS trigger 124 marks block starts
block_events = status_events(status_values == 124);
block_times = [block_events.time];

% determine stimulus onset time for each trial
% trl(:,1) is the epoch start sample; add 100 ms because epochs begin 100 ms before onset
trial_times = (trl(:,1) - 1) ./ D.fsample + 0.100;

% assign each stimulus trial to the most recent preceding block-start marker
block_id = zeros(size(trial_times));

for i = 1:length(trial_times)
    block_id(i) = find(block_times <= trial_times(i), 1, 'last');
end

% sanity: check that all trials were assigned to a block
assert(all(block_id > 0), 'At least one stimulus trial could not be assigned to a block.');

% sanity: check that all 12 experimental blocks are represented
fprintf('Number of blocks identified: %d\n', length(unique(block_id)));

% print number of stimulus trials within each block
for b = unique(block_id)'
    fprintf('Block %d: %d trials\n', b, sum(block_id == b));
end

% save variables required for Standard/Deviant classification
save(fullfile(P.outdir, 'trialdef.mat'), 'trl', 'conditionlabels', 'block_id');
