% STATS_STD_DEV  H2: Standard vs Deviant (mismatch response), trial-level SPM statistics for
% one participant.
%   participant = 'ID01'; stats_std_dev
% Run after preprocessing.m. Output: derivatives/<ID>/stats_std_dev/
%   SPM.mat, summary.csv, table_*.csv, and SPM result figures (PNG) when a display is available.
%
% Design: two-sample t-test across trials, column 1 = Standard (last standard of a train),
% column 2 = Deviant (first stimulus after an intensity change).
% Contrasts (signed, so the direction of the mismatch is tested):
%   1. Deviant > Standard  (t, [-1 1]) - deviant more positive: expected for the P300 MMR
%                                         (paper: 246-418 ms, central, peak C2)
%   2. Standard > Deviant  (t, [1 -1]) - deviant more negative: expected for the N140 MMR
%                                         (paper: 109-172 ms, right temporal, peak T8)
%   3. Standard vs Deviant (F, [1 -1]) - non-directional

if ~exist('participant', 'var'), participant = 'ID01'; end
cfg = project_config();
P = participant_paths(cfg, participant);

contrasts = struct('name',    {'Deviant > Standard', 'Standard > Deviant', 'Standard vs Deviant'}, ...
                   'type',    {'t',                  't',                  'F'}, ...
                   'weights', {[-1 1],               [1 -1],               [1 -1]});

opt.alpha     = 0.05;     % peak-level FWE threshold per contrast (0.025 if direction not predicted)
opt.cluster_p = 0.001;    % cluster-forming threshold for the cluster-level table (as in the paper)

res_std_dev = run_trial_stats(P, ['abstd_dev_TfdfMinterpolate_' P.base '.mat'], 'Standard', 'Deviant', ...
                              contrasts, 'stats_std_dev', opt);
