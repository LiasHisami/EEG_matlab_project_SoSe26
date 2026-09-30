function out = stats_window_results(P, statsname, k, wname, win, opt)
% STATS_WINDOW_RESULTS  SPM results page for one contrast inside an a priori time window.
%   out = stats_window_results(P, 'stats_high_low', 1, 'P50', [30 60])
%
% The whole-epoch results page (run_trial_stats) puts its cursor on the global maximum,
% wherever in the epoch it is. This page restricts the search volume to the component
% window: the map is masked to the window (cursor on the window maximum) and the table is
% recomputed with SPM's small volume correction (spm_VOI), so its FWE p-values are corrected
% for the window's volume only. The model is not re-estimated.
%
%   P          participant struct (participant_paths)
%   statsname  stats folder inside derivatives/<ID>/ with an estimated SPM.mat
%   k          contrast index in SPM.xCon
%   wname, win component name and window [start end] in ms
%   opt.alpha  display threshold: peak FWE p < alpha over the whole epoch (default .05)
%
% Output in the stats folder: mask_<wname>_<win>.nii, svc_<k>_<contrast>_<wname>.png/.csv.
% Needs a display for the page (the CSV is written either way).

if nargin < 6, opt = struct(); end
if ~isfield(opt, 'alpha'), opt.alpha = 0.05; end
statsdir = fullfile(P.outdir, statsname);
load(fullfile(statsdir, 'SPM.mat'), 'SPM');
cname = SPM.xCon(k).name;

%% 1. Window mask: the model's mask with every time slice outside the window set to 0
Vm = spm_vol(fullfile(statsdir, 'mask.nii'));
M  = spm_read_vols(Vm) > 0;
t  = Vm.mat(3, 3) * (1:Vm.dim(3)) + Vm.mat(3, 4);          % time of each slice (ms)
M(:, :, ~(t >= win(1) & t <= win(2))) = false;
assert(any(M(:)), 'No voxels in window %g-%g ms', win(1), win(2));
Vw = struct('fname', fullfile(statsdir, sprintf('mask_%s_%g-%gms.nii', wname, win(1), win(2))), ...
            'dim', Vm.dim, 'dt', [spm_type('uint8') spm_platform('bigend')], 'mat', Vm.mat, ...
            'pinfo', [1 0 0]', 'descrip', sprintf('%s window %g-%g ms', wname, win(1), win(2)));
spm_write_vol(Vw, double(M));
fprintf('[%s] %s window %g-%g ms: %d of %d voxels, slices %s\n', P.id, wname, win(1), win(2), ...
        nnz(M), nnz(spm_read_vols(Vm) > 0), mat2str(t(t >= win(1) & t <= win(2))));

%% 2. Results page masked to the window
spm_jobman('initcfg');
clear matlabbatch
r.spmmat  = {fullfile(statsdir, 'SPM.mat')};
r.conspec = struct('titlestr', sprintf('%s, %s window %g-%g ms', cname, wname, win(1), win(2)), ...
                   'contrasts', k, 'threshdesc', 'FWE', 'thresh', opt.alpha, 'extent', 0, 'conjunction', 1, ...
                   'mask', struct('image', struct('name', {{Vw.fname}}, 'mtype', 0)));
r.units   = 2;                                              % scalp x time
r.export  = {};
matlabbatch{1}.spm.stats.results = r;
spm_jobman('run', matlabbatch);
xSPM = evalin('base', 'xSPM'); hReg = evalin('base', 'hReg');

%% 3. Small volume correction: p-values corrected for the window only
xY = struct('def', 'mask', 'spec', Vw.fname, 'xyz', [0 0 0]');
[TabDat, xSVC] = spm_VOI(SPM, xSPM, hReg, xY);
base = fullfile(statsdir, sprintf('svc_%02d_%s_%s', k, matlab.lang.makeValidName(cname), wname));
spm_list('CSVList', TabDat, [base '.csv']);
F = spm_figure('FindWin', 'Graphics');
if ~isempty(F), print(F, '-dpng', '-r150', [base '.png']); end

n_vox = size(xSVC.XYZ, 2);
if n_vox
    [peak, i] = max(xSVC.Z); loc = xSVC.XYZmm(:, i);
    p_fwe = TabDat.dat{1, 7};                               % peak-level pFWE of the strongest maximum
else
    peak = NaN; loc = NaN(3, 1); p_fwe = NaN;
end
fprintf('[%s] %-20s %s %g-%g ms: %d voxels above the whole-epoch FWE threshold; peak %s = %.2f at (%g, %g) mm, %g ms, window-corrected pFWE = %.3g\n', ...
        P.id, cname, wname, win(1), win(2), n_vox, xSPM.STAT, peak, loc(1), loc(2), loc(3), p_fwe);
out = struct('window', win, 'mask', Vw.fname, 'n_voxels', n_vox, 'peak_stat', peak, 'x_mm', loc(1), 'y_mm', loc(2), ...
             'time_ms', loc(3), 'p_fwe_window', p_fwe, 'png', [base '.png'], 'csv', [base '.csv']);
end
