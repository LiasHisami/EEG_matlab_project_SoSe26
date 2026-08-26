% generate_avref.m
% Generates an average reference montage file (avref.mat) for use with spm_eeg_montage.
%
% This creates a standard average reference: for N EEG channels, each
% re-referenced channel = original - mean(all EEG channels).
% The montage matrix has 1 on the diagonal and -1/N elsewhere for EEG channels.
% Non-EEG channels (EOG) are passed through unchanged.
%
% Run this AFTER the convert step in preprocessing.m so that the .mat file exists.

clear; clc;

spm_path = 'C:\Users\lilas\Documents\MATLAB\spm';
addpath(spm_path);
spm('defaults', 'EEG');

% Load the converted SPM data to get channel info
D = spm_eeg_load('C:\Users\lilas\Documents\UNI\EEG_PRACTICAL_Vanessa_FOR_ID01\preprocessed\interpolate_SPNCartoons_ID01.mat');

% Get EEG channel indices and labels
eeg_idx = D.indchantype('EEG');
all_labels = D.chanlabels;
n_eeg = length(eeg_idx);
n_all = length(all_labels);

% Build the montage
montage = [];
montage.labelorg = all_labels(:)';   % original labels (row cell)
montage.labelnew = all_labels(:)';   % new labels (same)

% Identity matrix as starting point
tra = eye(n_all);

% For EEG channels: subtract the mean of all EEG channels
% Each EEG row gets -1/N for every other EEG channel
for i = 1:n_eeg
    for j = 1:n_eeg
        if i == j
            tra(eeg_idx(i), eeg_idx(j)) = 1 - 1/n_eeg;
        else
            tra(eeg_idx(i), eeg_idx(j)) = -1/n_eeg;
        end
    end
end

montage.tra = tra;

% Save
save('C:\Users\lilas\Documents\UNI\EEG_PRACTICAL_Vanessa_FOR_ID01\preprocessed\avref.mat', 'montage');
fprintf('Saved avref.mat with %d EEG channels and %d total channels.\n', n_eeg, n_all);
