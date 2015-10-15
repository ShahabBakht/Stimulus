function VisualGuidedSaccadeStimulusFile(S)

NumTrials                   =   S.NumTrials;         % Number of trials per condition         
FixationTimeMin_noDots      =   S.FixationTimeMin_noDots;
FixationTimeMax_noDots      =   S.FixationTimeMax_noDots;
TRIAL_TIMER                 =   S.TRIAL_TIMER;       % (ms)
SaveFolder                  =   S.SaveFolder;
type                        =   S.type;             % 'step', 'gap', or 'overlap'
NumConditions               =   S.NumConditions;
conditions                  =   S.conditions;


trials = nan(2,NumConditions*NumTrials);
for condcount = 1:NumConditions
    trials(:,((condcount-1)*NumTrials + 1):condcount*NumTrials) = repmat(conditions(:,condcount),1,NumTrials);
end

S.trials = trials;

%%


    % Initialize the screen. This will create a screen in monitor 1. In order to
    % create in monitor 0, replace 1 with 0 in the following line of code.
    screenInfo = openExperiment(38,50,0);        
    
    targets = setNumTargets(6); % initialize targets        
%     dotInfo = createDotInfo; % initialize dots   

    targets = newTargets(screenInfo,targets,[1:10],[0,randi([-50,50],1,9)],[0,randi([0,0],1,9)],...
        5*ones(1,10),repmat([0,0,255],10,1));
    for i = 1:10
    showTargets(screenInfo,targets,[i]);
    pause(1);
    end
   
    
    closeExperiment; % clear the screen and exit



end



