spm('defaults', 'eeg');

% Settings
chan_name = 'CP3';
t_start   = 380;
t_end     = 390;

% Load each preprocessing stage
D1 = spm_eeg_load('preprocessed/SPNCartoons_ID01.mat'); %raw
D2 = spm_eeg_load('preprocessed/Minterpolate_SPNCartoons_ID01.mat'); %montage
D3 = spm_eeg_load('preprocessed/fMinterpolate_SPNCartoons_ID01.mat'); % highpass filter
D4 = spm_eeg_load('preprocessed/dfMinterpolate_SPNCartoons_ID01.mat'); %downsampled 
D5 = spm_eeg_load('preprocessed/fdfMinterpolate_SPNCartoons_ID01.mat'); %lowpass filter
D6 = spm_eeg_load('preprocessed/TfdfMinterpolate_SPNCartoons_ID01.mat'); % eyeblink removal

% Find channel indices
c1 = find(strcmp(D1.chanlabels, chan_name));
c2 = find(strcmp(D2.chanlabels, chan_name));
c3 = find(strcmp(D3.chanlabels, chan_name));
c4 = find(strcmp(D4.chanlabels, chan_name));
c5 = find(strcmp(D5.chanlabels, chan_name));
c6 = find(strcmp(D6.chanlabels, chan_name));

% Get time indices for continuous files
getidx = @(D, ts, te) find(D.time >= ts & D.time <= te);
idx1 = getidx(D1, t_start, t_end);
idx2 = getidx(D2, t_start, t_end);
idx3 = getidx(D3, t_start, t_end);
idx4 = getidx(D4, t_start, t_end);
idx5 = getidx(D5, t_start, t_end);
idx6 = getidx(D6, t_start, t_end);

% Extract continuous segments
seg1 = squeeze(double(D1(c1, idx1, 1)));
seg2 = squeeze(double(D2(c2, idx2, 1)));
seg3 = squeeze(double(D3(c3, idx3, 1)));
seg4 = squeeze(double(D4(c4, idx4, 1)));
seg5 = squeeze(double(D5(c5, idx5, 1)));
seg6 = squeeze(double(D6(c6, idx6, 1)));

% Time axes for continuous files
t1 = D1.time(idx1)';
t2 = D2.time(idx2)';
t3 = D3.time(idx3)';
t4 = D4.time(idx4)';
t5 = D5.time(idx5)';
t6 = D6.time(idx6)';


% Use raw data's scale as the common reference
ref_scale = max(abs(seg1(:) - mean(seg1(:)))) + eps;

normShared = @(x) (x - mean(x)) / ref_scale * 100;
s1 = normShared(seg1(:));
s2 = normShared(seg2(:));
s3 = normShared(seg3(:));
s4 = normShared(seg4(:));
s5 = normShared(seg5(:));
s6 = normShared(seg6(:));

% Spacing
spacing = 250;
offsets = [6*spacing, 5*spacing, 4*spacing, 3*spacing, 2*spacing, spacing, 0];

% Plot
figure('Color', 'w', 'Position', [100 100 900 600]);
hold on

plot(t1, s1 + offsets(1), 'k', 'LineWidth', 0.3);
plot(t2, s2 + offsets(2), 'k', 'LineWidth', 0.3);
plot(t3, s3 + offsets(3), 'k', 'LineWidth', 0.3);
plot(t4, s4 + offsets(4), 'k', 'LineWidth', 0.3);
plot(t5, s5 + offsets(5), 'k', 'LineWidth', 0.3);
plot(t6, s6 + offsets(6), 'k', 'LineWidth', 0.3);

% Labels
text(t_start - 0.15, offsets(1), '1) raw data', 'HorizontalAlignment', 'right', 'FontSize', 12);
text(t_start - 0.15, offsets(2), '2) montaged', 'HorizontalAlignment', 'right', 'FontSize', 12);
text(t_start - 0.15, offsets(3), '3) high pass filtered', 'HorizontalAlignment', 'right', 'FontSize', 12);
text(t_start - 0.15, offsets(4), '4) downsampled', 'HorizontalAlignment', 'right', 'FontSize', 12);
text(t_start - 0.15, offsets(5), '5) low pass filtered', 'HorizontalAlignment', 'right', 'FontSize', 12);
text(t_start - 0.15, offsets(6), '6) eye blink removal', 'HorizontalAlignment', 'right', 'FontSize', 12);

% Scale bar
x_bar = t_end - 0.1;
line([x_bar x_bar], [0 100], 'Color', 'r', 'LineWidth', 2);
text(x_bar + 0.05, 50, '100 \muV', 'Color', 'r', 'FontSize', 10);

% Trigger lines
ev        = events(D1);
status_ev = ev(strcmp({ev.type}, 'STATUS'));
for i = 1:numel(status_ev)
    t = status_ev(i).time;
    if t >= t_start && t <= t_end
        xline(t, 'k:', 'LineWidth', 0.5);
    end
end

% Formatting
xlabel('time (s)', 'FontSize', 12);
xlim([t_start t_end]);
set(gca, 'YTick', [], 'Box', 'off');
title('Preprocessing steps - CP3', 'FontSize', 14);


