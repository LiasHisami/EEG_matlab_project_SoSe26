function P = participant_paths(cfg, participant)
% PARTICIPANT_PATHS  Finds all input files of one participant and creates its output folders.
%   P = participant_paths(cfg, 'ID02')
% The participant is found by its ID in the BDF file name, so it does not matter which
% GroupN folder it is in (e.g. ID01 is in Group2).

bdf = dir(fullfile(cfg.data_root, '*', '01EEG', ['*' participant '*.bdf']));
assert(numel(bdf) == 1, 'Expected one BDF for %s under %s, found %d', participant, cfg.data_root, numel(bdf));
P.id    = participant;
P.bdf   = fullfile(bdf.folder, bdf.name);
[~, P.base] = fileparts(bdf.name);                % e.g. SPNCartoons_ID01
P.group_dir = fileparts(bdf.folder);

% electrode positions (.sfp): file names differ between participants (SPNCartoons_/Gian_)
sfp = dir(fullfile(P.group_dir, '00Behavioural', 'neuronavigation', ['*' participant '*.sfp']));
if isempty(sfp)
    sfp = dir(fullfile(P.group_dir, '00Behavioural', 'neuronavigation', '*.sfp'));
end
assert(numel(sfp) == 1, 'Expected one .sfp file for %s, found %d', participant, numel(sfp));
P.sfp = fullfile(sfp.folder, sfp.name);

P.outdir  = fullfile(cfg.out_root, participant);
P.plotdir = fullfile(P.outdir, 'plots');
if ~isfolder(P.plotdir), mkdir(P.plotdir); end

% bad channels from bad_channels.tsv (columns: id, channels separated by ';')
% [] = participant not listed -> spm_interpolate_bad_channels asks interactively
P.bad_channels = [];
if isfile(cfg.bad_channels_file)
    T = readtable(cfg.bad_channels_file, 'FileType', 'text', 'Delimiter', '\t', ...
                  'TextType', 'string', 'ReadVariableNames', true);
    row = find(T.id == participant, 1);
    if ~isempty(row)
        ch = strtrim(split(T.channels(row), ';'));
        P.bad_channels = cellstr(ch(ch ~= "" & ~ismissing(ch)))';
    end
end
end
