% RUN_ALL_PARTICIPANTS  Preprocess and plot every participant (or a chosen list).
%   participants = {'ID01','ID03'}; run_all_participants     % only these
%   clear participants; run_all_participants                 % all found in the data folder
% Headless:  matlab -batch "cd('/path/to/repo'); run_all_participants"

cfg = project_config();
run_state = struct();
if exist('participants', 'var') && ~isempty(participants)
    run_state.todo = participants;
else
    f = dir(fullfile(cfg.data_root, '*', '01EEG', '*.bdf'));
    run_state.todo = unique(regexp({f.name}, 'ID\d+', 'match', 'once'));
end
run_state.done = {};

for run_state.k = 1:numel(run_state.todo)
    participant = run_state.todo{run_state.k};
    fprintf('\n===== %s (%d of %d) =====\n', participant, run_state.k, numel(run_state.todo));
    preprocessing;          % clears all variables except participant and run_state
    plot_preprocessing;
    plot_ERP_high_low;
    plot_ERP_std_dev;
    close all
    run_state.done{end + 1} = participant;
end
fprintf('\nFinished: %s\n', strjoin(run_state.done, ', '));
