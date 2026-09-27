function cfg = project_config()
cfg = struct();
cfg.code_dir       = fileparts(mfilename('fullpath'));          % folder of this repository
cfg.data_root      = getenv('EEG_DATA_ROOT');                    % contains Group1, Group2, ...
cfg.out_root       = getenv('EEG_OUT_ROOT');                     % where SPM files are written
cfg.spm_path       = getenv('SPM_PATH');                         % SPM25 folder
cfg.brewermap_path = getenv('BREWERMAP_PATH');                   % optional
cfg.bad_channels_file = fullfile(cfg.code_dir, 'bad_channels.tsv');
cfg.interactive    = usejava('desktop');                         % false in matlab -batch

if exist('config_local', 'file') == 2
    loc = config_local();
    f = fieldnames(loc);
    for i = 1:numel(f)
        cfg.(f{i}) = loc.(f{i});
    end
end

if isempty(cfg.out_root), cfg.out_root = fullfile(cfg.code_dir, 'derivatives'); end
addpath(cfg.code_dir, '-begin');
assert(~isempty(cfg.data_root) && isfolder(cfg.data_root), ...
    'Data folder not set or not found: set data_root in config_local.m or EEG_DATA_ROOT');

if ~isempty(cfg.spm_path), addpath(cfg.spm_path); end
if ~isempty(cfg.brewermap_path), addpath(cfg.brewermap_path); end
assert(exist('spm', 'file') == 2, 'SPM not found: set spm_path in config_local.m or SPM_PATH');
spm('defaults', 'EEG');
end
