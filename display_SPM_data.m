function [] = display_SPM_data(D)
    % Load SPM EEG object    
    ft_defaults
    data = spm2fieldtrip(D);
    bad_segments = [];

    if strcmp(type(D), 'continuous')
        data.cfg.event = events(D); 
        temp = num2cell([data.cfg.event.time]*D.fsample);
        [data.cfg.event.sample] = temp{:}; 
    elseif strcmp(type(D), 'single')
        %if epoched, extract the bad trial information and add it to our
        %file to display it. 
        bad_segments = data.sampleinfo(badtrials(D),:);
    end

    if strcmp(type(D), 'continuous')
        cfg = [];
        cfg.length = 10;
        cfg.overlap = 0;
        data_epoched = ft_redefinetrial(cfg, data);
        
        figure; 
        cfg = [];
        cfg.preproc.demean = 'no';
        cfg.preproc.lpfilter = 'no';
        cfg.preproc.lpfreq = 45;
        cfg.preproc.hpfilter = 'no';
        cfg.preproc.hpfreq = 1;
        cfg.preproc.hpinstabilityfix = 'reduce';
        cfg.ylim = [-20 20];
        cfg.displayevents = 'yes';
        ft_databrowser(cfg, data_epoched);
    else
        figure; 
        cfg = [];
        cfg.preproc.demean = 'no';
        cfg.preproc.lpfilter = 'no';
        cfg.preproc.lpfreq = 45;
        cfg.preproc.hpfilter = 'no';
        cfg.preproc.hpfreq = 1;
        cfg.preproc.hpinstabilityfix = 'reduce';
        if ~isempty(bad_segments)
            cfg.artfctdef.SPM.artifact = bad_segments; 
        end
        cfg.ylim = [-20 20];
        ft_databrowser(cfg, data);
    end
end