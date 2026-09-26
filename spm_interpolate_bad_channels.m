function D2 = spm_interpolate_bad_channels(D, bad_labels)
% SPM_INTERPOLATE_BAD_CHANNELS - Load SPM EEG file, let user mark bad channels,
% interpolate them using spline (uses embedded sensors location in meeg file), and save the updated data.
%
% Inputs:
%   D          - meeg file loaded in workspace
%   bad_labels - (optional) cell array of channel labels, e.g. {'CP3'}; {} = none.
%                If omitted or [], the user is asked to type them in (original behaviour).
% Outputs:
%   D    - meeg file with specified channels interpolated (also saved on
%   disk in same folder as loaded D file with prefix "interpolate_"

    data = spm2fieldtrip(D);

    %% THEN PLOT
    cfg = [];
    cfg.length = 10;
    cfg.overlap = 0;
    data_epoched = data;
    cfg = [];
    cfg.preproc.demean = 'yes';
    cfg.preproc.lpfilter = 'yes'; 
    cfg.preproc.lpfreq = 45; 
    cfg.preproc.hpfilter = 'yes'; 
    cfg.preproc.hpfreq = 1; 
    cfg.preproc.hpinstabilityfix = 'reduce'; 
    cfg.ylim = [-20 20];
    if isfield(cfg,'colormap')
        cfg = rmfield(cfg,'colormap');
    end  % optional safety
    %ft_databrowser(cfg, data_epoched);  % REMOVE COMMENT IF YOU WANT TO
    %INSPECT THE DATA

    % Let user input bad channels (only if they were not passed in)
    if nargin < 2 || (isnumeric(bad_labels) && isempty(bad_labels))
        disp('Channel labels:');
        bad_labels = input('Enter bad channels as a cell array (e.g. {''F3'', ''T7''}): ');
    end
    fprintf('Bad channels: %s\n', strjoin(bad_labels, ', '));

    for i =1:length(bad_labels)
        if any(strcmp(bad_labels{i}, data.label)) == 0
            error(sprintf('The typed channel: %s do not exist', bad_labels{i}))
        end
    end

    if length(bad_labels) > 0
        cfg               = [];
        cfg.method = 'spline';
        cfg.badchannel    = bad_labels;
        %cfg.neighbours = neighbours;
        data_corr = ft_channelrepair(cfg, data);
       
    else
        data_corr = data;
    end

   
    D2 = D.copy(['interpolate_' fname(D)]);

    %check that dimension match
    % match channels by label, in case ft_channelrepair changed their order
    eeg_idx = indchantype(D, 'EEG');
    [found, loc] = ismember(D.chanlabels(eeg_idx), data_corr.label);
    if numel(eeg_idx) == numel(data_corr.label) && all(found)
        D2(eeg_idx,:) = data_corr.trial{1,1}(loc,:);
        D2.save();
    else
        error('something went wrong with channel indices')
    end
    
    fprintf('Done. Saved interpolated data as: %s\n', fullfile(D2.path, [D2.fname]));
end
