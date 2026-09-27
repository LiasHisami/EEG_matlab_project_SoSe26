function out = run_trial_stats(P, epoched_file, cond1, cond2, contrasts, statsname, opt)
% RUN_TRIAL_STATS  Scripted version of the SPM "convert to images -> two-sample t-test ->
% estimate -> contrasts -> results" steps that were previously done in the SPM GUI
% (following the SPM MMN tutorial, see README).
%
%   out = run_trial_stats(P, epoched_file, cond1, cond2, contrasts, statsname, opt)
%
%   P             participant struct from participant_paths
%   epoched_file  epoched SPM file AFTER artefact rejection (bad trials are left out)
%   cond1, cond2  condition labels; cond1 = first design column, cond2 = second column
%   contrasts     struct array with fields name, type ('t' or 'F'), weights
%   statsname     name of the output folder inside derivatives/<ID>/
%   opt           struct: alpha (default .05), cluster_p (default .001)
%
% Level of inference: single trials of ONE participant (fixed effects). Results describe
% this participant only, and p-values assume independent trials (see README).

if nargin < 7, opt = struct(); end
if ~isfield(opt, 'alpha'),     opt.alpha = 0.05;      end
if ~isfield(opt, 'cluster_p'), opt.cluster_p = 0.001; end

spm_jobman('initcfg');
D = spm_eeg_load(fullfile(P.outdir, epoched_file));
fprintf('[%s] %s: %d trials, %d marked bad\n', P.id, epoched_file, D.ntrials, numel(D.badtrials));

%% 1. Convert every good trial to a scalp x time image (one 4D file per condition)
clear matlabbatch
matlabbatch{1}.spm.meeg.images.convert2images.D = {fullfile(D.path, D.fname)};
matlabbatch{1}.spm.meeg.images.convert2images.mode = 'scalp x time';
matlabbatch{1}.spm.meeg.images.convert2images.conditions = {cond1, cond2};
matlabbatch{1}.spm.meeg.images.convert2images.channels{1}.type = 'EEG';
matlabbatch{1}.spm.meeg.images.convert2images.timewin = [-Inf Inf];
matlabbatch{1}.spm.meeg.images.convert2images.freqwin = [-Inf Inf];
matlabbatch{1}.spm.meeg.images.convert2images.prefix = '';
spm_jobman('run', matlabbatch);

imgdir = fullfile(D.path, spm_file(D.fname, 'basename'));     % SPM writes a folder named after the file
scans1 = cellstr(spm_select('ExtFPList', imgdir, ['^condition_' cond1 '\.nii$'], Inf));
scans2 = cellstr(spm_select('ExtFPList', imgdir, ['^condition_' cond2 '\.nii$'], Inf));
assert(~isempty(scans1{1}) && ~isempty(scans2{1}), 'No images found for %s / %s in %s', cond1, cond2, imgdir);
fprintf('[%s] images: %s %d, %s %d\n', P.id, cond1, numel(scans1), cond2, numel(scans2));

%% 2. Two-sample (unpaired) t-test across trials: column 1 = cond1, column 2 = cond2
statsdir = fullfile(P.outdir, statsname);
if isfolder(statsdir), rmdir(statsdir, 's'); end               % start clean (SPM.mat would be overwritten anyway)
mkdir(statsdir);
clear matlabbatch
fd.dir = {statsdir};
fd.des.t2.scans1 = scans1;
fd.des.t2.scans2 = scans2;
fd.des.t2.dept = 0;                  % independent observations (trials)
fd.des.t2.variance = 1;              % unequal variances (SPM default)
fd.des.t2.gmsca = 0;
fd.des.t2.ancova = 0;
fd.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
fd.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
fd.masking.tm.tm_none = 1;
fd.masking.im = 1;
fd.masking.em = {''};
fd.globalc.g_omit = 1;
fd.globalm.gmsca.gmsca_no = 1;
fd.globalm.glonorm = 1;
matlabbatch{1}.spm.stats.factorial_design = fd;

%% 3. Estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(statsdir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% 4. Contrasts
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(statsdir, 'SPM.mat')};
for k = 1:numel(contrasts)
    field = [lower(contrasts(k).type) 'con'];          % 'tcon' or 'fcon'
    matlabbatch{3}.spm.stats.con.consess{k}.(field).name = contrasts(k).name;
    matlabbatch{3}.spm.stats.con.consess{k}.(field).weights = contrasts(k).weights;
    matlabbatch{3}.spm.stats.con.consess{k}.(field).sessrep = 'none';
end
matlabbatch{3}.spm.stats.con.delete = 1;
spm_jobman('run', matlabbatch);

%% 5. Results: headless tables (+ SPM result figures when a display is available)
% (a) peak-level FWE p < alpha, extent 0  (what was done in the GUI)
% (b) cluster-forming p < cluster_p uncorrected; read the cluster-level pFWE column (as in the paper)
load(fullfile(statsdir, 'SPM.mat'), 'SPM');
rows = {};
for k = 1:numel(contrasts)
    for thr = {'FWE', 'none'}
        xSPM = struct('swd', statsdir, 'title', contrasts(k).name, 'Ic', k, 'n', 1, 'Im', [], 'pm', [], ...
                      'Ex', [], 'thresDesc', thr{1}, 'k', 0, 'units', {{'mm', 'mm', 'ms'}});
        if strcmp(thr{1}, 'FWE'), xSPM.u = opt.alpha; tag = sprintf('peakFWE%.3g', opt.alpha);
        else,                     xSPM.u = opt.cluster_p; tag = sprintf('unc%.3g', opt.cluster_p); end
        [~, xSPM] = spm_getSPM(xSPM);
        TabDat = spm_list('Table', xSPM);
        csvname = fullfile(statsdir, sprintf('table_%02d_%s_%s.csv', k, matlab.lang.makeValidName(contrasts(k).name), tag));
        spm_list('CSVList', TabDat, csvname);
        n_vox = size(xSPM.XYZ, 2);
        if n_vox > 0
            [peak, i] = max(xSPM.Z);
            loc = xSPM.XYZmm(:, i);
            rows(end + 1, :) = {contrasts(k).name, tag, n_vox, peak, loc(1), loc(2), loc(3)}; %#ok<AGROW>
        else
            rows(end + 1, :) = {contrasts(k).name, tag, 0, NaN, NaN, NaN, NaN}; %#ok<AGROW>
        end
        fprintf('[%s] %-28s %-12s suprathreshold voxels: %6d   peak %s = %.2f\n', P.id, contrasts(k).name, tag, n_vox, xSPM.STAT, rows{end, 4});
    end
end
S = cell2table(rows, 'VariableNames', {'contrast', 'threshold', 'n_voxels', 'peak_stat', 'x_mm', 'y_mm', 'time_ms'});
writetable(S, fullfile(statsdir, 'summary.csv'));
disp(S)

if usejava('desktop') || feature('ShowFigureWindows')
    for k = 1:numel(contrasts)
        clear matlabbatch
        r.spmmat = {fullfile(statsdir, 'SPM.mat')};
        r.conspec = struct('titlestr', contrasts(k).name, 'contrasts', k, 'threshdesc', 'FWE', ...
                           'thresh', opt.alpha, 'extent', 0, 'conjunction', 1, 'mask', struct('none', 1));
        r.units = 2;                                  % 2 = EEG scalp x time
        r.export{1}.png = true;
        matlabbatch{1}.spm.stats.results = r;
        spm_jobman('run', matlabbatch);
    end
end

out = struct('statsdir', statsdir, 'n1', numel(scans1), 'n2', numel(scans2), 'summary', S);
end
