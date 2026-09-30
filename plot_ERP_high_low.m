% set the participant first, e.g.  participant = 'ID02'; plot_ERP_high_low
if ~exist('participant', 'var'), participant = 'ID01'; end
cfg = project_config();
P = participant_paths(cfg, participant);

% Load averaged file (H1: High vs Low)
D = spm_eeg_load(fullfile(P.outdir, ['fmabeTfdfMinterpolate_' P.base '.mat']));

% One ROI and time window per component, fixed a priori so that the High vs Low
% comparison is not biased by the ROI selection. H1 concerns the P50: the early
% somatosensory response contralateral to the (left-hand) stimulation, over the
% right central-parietal electrodes; window from the group's replication analysis
% (P50 peak at CP4, 30-60 ms; see wiki/replication-results.md).
rois(1).name  = 'P50 (right central-parietal)';
rois(1).chans = {'C4', 'C6', 'CP2', 'CP4', 'CP6'};
rois(1).win   = [30 60];                   % ms

time  = D.time * 1000;                     % ms
conds = conditions(D);
i_high = find(strcmp(conds, 'High'));
i_low  = find(strcmp(conds, 'Low'));
assert(numel(i_high) == 1 && numel(i_low) == 1, 'Expected conditions High and Low, found: %s', strjoin(conds, ', '));

fig = figure('Color', 'w', 'Position', [100 100 550 * numel(rois), 420]);
tl = tiledlayout(fig, 1, numel(rois), 'TileSpacing', 'compact', 'Padding', 'compact');
summary = cell(numel(rois), 6);

for r = 1:numel(rois)
    chan_idx = find(ismember(D.chanlabels, rois(r).chans));
    % Sanity check: make sure all channels were found
    if numel(chan_idx) ~= numel(rois(r).chans)
        missing = setdiff(rois(r).chans, D.chanlabels(chan_idx));
        warning('Missing channels: %s', strjoin(missing, ', '));
    end

    % average across the ROI channels -> time x conditions
    data = double(D(chan_idx, :, :));
    high_wave = mean(data(:, :, i_high), 1);
    low_wave  = mean(data(:, :, i_low), 1);
    diff_wave = high_wave - low_wave;

    % mean amplitude in the component window
    w = time >= rois(r).win(1) & time <= rois(r).win(2);
    summary(r, :) = {rois(r).name, strjoin(rois(r).chans, ' '), sprintf('%g-%g', rois(r).win(1), min(rois(r).win(2), time(end))), ...
        mean(high_wave(w)), mean(low_wave(w)), mean(diff_wave(w))};

    ax = nexttile(tl);
    hold(ax, 'on')
    yl = [min([high_wave low_wave diff_wave]) max([high_wave low_wave diff_wave])];
    yl = yl + [-0.1 0.1] * diff(yl);
    patch(ax, [rois(r).win(1) rois(r).win(2) rois(r).win(2) rois(r).win(1)], yl([1 1 2 2]), ...
        [0.9 0.9 0.9], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, time, high_wave, 'b', 'LineWidth', 1.5, 'DisplayName', 'High');
    plot(ax, time, low_wave, 'r', 'LineWidth', 1.5, 'DisplayName', 'Low');
    plot(ax, time, diff_wave, 'k--', 'LineWidth', 1.2, 'DisplayName', 'High - Low');
    xline(ax, 0, 'k:', 'LineWidth', 1, 'HandleVisibility', 'off');
    yline(ax, 0, 'k', 'HandleVisibility', 'off');
    ylim(ax, yl); xlim(ax, [time(1) time(end)]);
    xlabel(ax, 'Time (ms)', 'FontSize', 12);
    ylabel(ax, 'Amplitude (\muV)', 'FontSize', 12);
    title(ax, rois(r).name, 'FontSize', 12);     % channels are listed in the CSV, not the title
    text(ax, mean(rois(r).win), yl(2), sprintf('high-low = %.2f \\muV', summary{r, 6}), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10);
    legend(ax, 'FontSize', 10, 'Location', 'southwest');
    grid(ax, 'on'); box(ax, 'off');
end
title(tl, sprintf('%s: High vs Low (grey = component window)', P.id), 'FontSize', 14);

% print and save the window means
T = cell2table(summary, 'VariableNames', {'component', 'channels', 'window_ms', 'high_uV', 'low_uV', 'high_minus_low_uV'});
disp(T)
writetable(T, fullfile(P.plotdir, 'ERP_high_low_window_means.csv'));

% save the figure in the participant's plots folder
exportgraphics(fig, fullfile(P.plotdir, 'ERP_high_low.png'), 'Resolution', 200);
