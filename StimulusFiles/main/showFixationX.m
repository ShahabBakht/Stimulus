function showFixationX(screenInfo, FixationX)
% SHOWTARGETS Displays the targets identified by targetIndex in the structure targets 
%
% showTargets(screenInfo, targets, targetIndex)
%
%	where
%   screenInfo  created by openExperiment, has screen number and other info,
%   FixationX     initially created by setNumTargets and then targets are set using 
%               newTargets,
%
%	Examples:
%	To show a single target (#1) at its current position & color
%
%		showTargets(screenInfo, targets, 1)
%
%   To change a target, first call newTargets and then showTargets
%
%       targets = newTargets(screenInfo,targets,[2 3],[],[],[],[255 255 0; 0 255 255])
%       showTargets(screenInfo, targets, [1 2 3])
%

%   created by MKMK July, 2006

[sourceFactorOld, destinationFactorOld, colorMaskOld]=Screen('BlendFunction',screenInfo.curWindow,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', screenInfo.curWindow, FixationX.xy, 1, FixationX.colors, [] ,1);


% Draw the fixation cross
Screen('DrawingFinished',screenInfo.curWindow, screenInfo.dontclear);
Screen('Flip', screenInfo.curWindow, 0, screenInfo.dontclear);
