% STATS_HIGH_LOW  H1: High vs Low intensity, trial-level SPM statistics for one participant.
%   participant = 'ID01'; stats_high_low
% Run after preprocessing.m. Output: derivatives/<ID>/stats_high_low/
%   SPM.mat, summary.csv (suprathreshold voxels + peak per contrast and threshold),
%   table_*.csv (SPM results tables), and SPM result figures (PNG) when a display is available.
%
% Design: two-sample t-test across trials, column 1 = High, column 2 = Low.
% Contrasts:
%   1. High > Low  (t, [1 -1])  - the directional H1 hypothesis (larger P50 for high intensity)
%   2. Low > High  (t, [-1 1])  - opposite sign, e.g. polarity-reversed parts of the topography
%   3. High vs Low (F, [1 -1])  - non-directional, as in the SPM tutorial

if ~exist('participant', 'var'), participant = 'ID01'; end
cfg = project_config();
P = participant_paths(cfg, participant);

contrasts = struct('name',    {'High > Low', 'Low > High', 'High vs Low'}, ...
                   'type',    {'t',          't',          'F'}, ...
                   'weights', {[1 -1],       [-1 1],       [1 -1]});

opt.alpha     = 0.05;     % peak-level FWE threshold per contrast
opt.cluster_p = 0.001;    % cluster-forming threshold for the cluster-level table

res_high_low = run_trial_stats(P, ['abeTfdfMinterpolate_' P.base '.mat'], 'High', 'Low', ...
                               contrasts, 'stats_high_low', opt);
