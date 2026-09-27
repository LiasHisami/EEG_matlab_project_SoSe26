function c = config_local()
c = struct();
c.data_root      = '/home/chuddy/dev/MCNB/eeg/EEG_matlab_project_SoSe26';          % folder that contains Group1 ... Group4
c.spm_path       = '/home/chuddy/dev/tool/spm_25.01.02';
c.brewermap_path = '/path/to/DrosteEffect-BrewerMap';   % optional, '' if not needed
end
