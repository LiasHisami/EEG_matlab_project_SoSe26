% Load averaged file
D = spm_eeg_load('preprocessed/fmaeTfdfMinterpolate_SPNCartoons_ID01.mat');

% Average across channels CP6, P6, CP4, C6, TP8, P8
chan_names = {'CP6', 'P6', 'CP4', 'C6', 'TP8', 'P8'};
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
