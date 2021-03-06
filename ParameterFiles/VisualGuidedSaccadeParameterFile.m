S.NumTrials                 =   1;         % Number of trials per condition         
S.FixationTimeMin_noDots    =   1000;
S.FixationTimeMax_noDots    =   1500;
S.TRIAL_TIMER               =   1000;       % (ms)
S.SaveFolder                =   'C:\Shahab\Stimulus Objects';
S.type                      =   'step';             % 'step', 'gap', or 'overlap'
S.TargetSize                =   .5; % (degrees)
TargetAngleMin = -pi;
TargetAngleInterval = pi/4;
TargetAngleMax = pi - TargetAngleInterval;

TargetAngle = TargetAngleMin:TargetAngleInterval:TargetAngleMax;

TargetAmpMin = 20;
TargetAmpMax = 20;
TargetAmpInterval = 5;
TargetAmp = TargetAmpMin:TargetAmpInterval:TargetAmpMax;

S.NumConditions = length(TargetAmp) * length(TargetAngle);
[X,Y] = meshgrid(TargetAngle,TargetAmp);

for c = 1:S.NumConditions
    C(:,c) = [X(c);Y(c)];
end

S.conditions = C;

