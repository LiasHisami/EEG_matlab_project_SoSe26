% set the participant first, e.g.  participant = 'ID02'; plot_ERP_std_dev
if ~exist('participant', 'var'), participant = 'ID01'; end
cfg = project_config();
P = participant_paths(cfg, participant);

% Load averaged file (H2: Standard vs Deviant)
D = spm_eeg_load(fullfile(P.outdir, ['fmabstd_dev_TfdfMinterpolate_' P.base '.mat']));

% Average across channels P2, CP2, P4, CP4 for H2 (N140)
% chan_names = {'P2', 'CP2', 'P4', 'CP4'};  %choose a version

% Average across channels 'C4', 'C6', 'CP2', 'CP4', 'CP6'
chan_names = {'C4', 'C6', 'CP2', 'CP4', 'CP6'};


chan_idx   = find(ismember(D.chanlabels, chan_names));

% Sanity check: make sure all channels were found
if numel(chan_idx) ~= numel(chan_names)
    found = D.chanlabels(chan_idx);
    missing = setdiff(chan_names, found);
    warning('Missing channels: %s', strjoin(missing, ', '));
end

% Get data for both conditions
time  = D.time * 1000;        % ms
conds = conditions(D);
data  = squeeze(double(D(chan_idx, :, :)));   % channels x time x conditions

% Average across the channel dimension
data_avg = squeeze(mean(data, 1));            % time x conditions

% Plot both conditions overlaid
figure('Color', 'w', 'Position', [100 100 700 400]);
hold on
colors = {'b', 'r'};
for c = 1:numel(conds)
    plot(time, data_avg(:,c), colors{c}, 'LineWidth', 1.5, ...
        'DisplayName', conds{c});
end
xline(0, 'k--', 'Stimulus', 'LineWidth', 1, 'HandleVisibility', 'off');
yline(0, 'k', 'HandleVisibility', 'off');
%set(gca, 'YDir', 'reverse');
xlabel('Time (ms)', 'FontSize', 12);
ylabel('Amplitude (\muV)', 'FontSize', 12);


legend('FontSize', 11);
title(['ERP - average (' strjoin(chan_names, ', ') ')'], 'FontSize', 14);
grid on; box off;

% save the figure in the participant's plots folder
exportgraphics(gcf, fullfile(P.plotdir, 'ERP_std_dev.png'), 'Resolution', 200);
