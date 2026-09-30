% set the participant first, e.g.  participant = 'ID02'; plot_ERP_std_dev
if ~exist('participant', 'var'), participant = 'ID01'; end
cfg = project_config();
P = participant_paths(cfg, participant);

% Load averaged file (H2: Standard vs Deviant)
D = spm_eeg_load(fullfile(P.outdir, ['fmabstd_dev_TfdfMinterpolate_' P.base '.mat']));

% One ROI and time window per mismatch component, taken from the reference paper
% (Giannini et al. 2026): N140 MMR peaks at T8/FT8/TP8, P300 MMR peaks at C2.
% They are fixed a priori (not chosen from this participant's topography), so that
% the Standard vs Deviant comparison is not biased by the ROI selection.
% (previous version: one ROI {'C4','C6','CP2','CP4','CP6'} = the P50 ROI of H1)
rois(1).name  = 'N140 MMR (right temporal)';
rois(1).chans = {'FT8', 'T8', 'TP8', 'FC6', 'C6', 'CP6'};
rois(1).win   = [109 172];                 % ms
rois(2).name  = 'P300 MMR (central)';
rois(2).chans = {'FCz', 'Cz', 'CPz', 'FC2', 'C2', 'CP2'};
rois(2).win   = [246 418];                 % ms (inside the -100..500 ms epoch)

time  = D.time * 1000;                     % ms
conds = conditions(D);
i_std = find(strcmp(conds, 'Standard'));
i_dev = find(strcmp(conds, 'Deviant'));
assert(numel(i_std) == 1 && numel(i_dev) == 1, 'Expected conditions Standard and Deviant, found: %s', strjoin(conds, ', '));

fig = figure('Color', 'w', 'Position', [100 100 1100 420]);
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
    std_wave = mean(data(:, :, i_std), 1);
    dev_wave = mean(data(:, :, i_dev), 1);
    diff_wave = dev_wave - std_wave;

    % mean amplitude in the component window
    w = time >= rois(r).win(1) & time <= rois(r).win(2);
    summary(r, :) = {rois(r).name, strjoin(rois(r).chans, ' '), sprintf('%g-%g', rois(r).win(1), min(rois(r).win(2), time(end))), ...
        mean(std_wave(w)), mean(dev_wave(w)), mean(diff_wave(w))};

    ax = nexttile(tl);
    hold(ax, 'on')
    yl = [min([std_wave dev_wave diff_wave]) max([std_wave dev_wave diff_wave])];
    yl = yl + [-0.1 0.1] * diff(yl);
    patch(ax, [rois(r).win(1) rois(r).win(2) rois(r).win(2) rois(r).win(1)], yl([1 1 2 2]), ...
        [0.9 0.9 0.9], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, time, std_wave, 'b', 'LineWidth', 1.5, 'DisplayName', 'Standard');
    plot(ax, time, dev_wave, 'r', 'LineWidth', 1.5, 'DisplayName', 'Deviant');
    plot(ax, time, diff_wave, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Deviant - Standard');
    xline(ax, 0, 'k:', 'LineWidth', 1, 'HandleVisibility', 'off');
    yline(ax, 0, 'k', 'HandleVisibility', 'off');
    ylim(ax, yl); xlim(ax, [time(1) time(end)]);
    xlabel(ax, 'Time (ms)', 'FontSize', 12);
    ylabel(ax, 'Amplitude (\muV)', 'FontSize', 12);
    title(ax, rois(r).name, 'FontSize', 12);     % channels are listed in the CSV, not the title
    text(ax, mean(rois(r).win), yl(2), sprintf('dev-std = %.2f \\muV', summary{r, 6}), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10);
    legend(ax, 'FontSize', 10, 'Location', 'southwest');
    grid(ax, 'on'); box(ax, 'off');
end
title(tl, sprintf('%s: Standard vs Deviant (grey = component window)', P.id), 'FontSize', 14);

% print and save the window means
T = cell2table(summary, 'VariableNames', {'component', 'channels', 'window_ms', 'standard_uV', 'deviant_uV', 'dev_minus_std_uV'});
disp(T)
writetable(T, fullfile(P.plotdir, 'ERP_std_dev_window_means.csv'));

% save the figure in the participant's plots folder
exportgraphics(fig, fullfile(P.plotdir, 'ERP_std_dev.png'), 'Resolution', 200);