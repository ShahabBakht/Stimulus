function FixationX = newFixationX(screenInfo,x_position,y_position,diameter,tcolor)

% NEWTARGETS sets up targets for erasing & displaying 
%
% targets = newTargets(screenInfo,targets,targetIndex,x_position,y_position,diameter,tcolor)
%
% All input arguments can be arrays where
%       screenInfo          required input, info about the screen obtained from 
%                           [screenInfo, targets] = setupScreen(38,50,8);
%		x_position:			x_position of fixation crosses centers to be shown or [], row
%		y_position:			y_position of fixation crosses centers to be shown or [], row
%		diameter:			diameter of fixation crosses to be shown or [], row
%		tcolor:             new values for color of fixation crosses to be shown or []
%
% Examples:
%
%   Make the target structure first before calling newTargets function by
%
%       targets = setNumTargets(6);
%   
%   To create 2 new targets, first call
%
%		targets = newTargets(screenInfo, targets, [1 2], [-5 5], [0 0], [4 4],...
%           [255 255 0; 255 255 0])
%
%   and then show these targets on screen with
%
%       showTargets([1 2])
%
%   If there are 3 targets and in order to change the colors of targets 2 and 3,
%   call
%
%       targets = newTargets(screenInfo, targets, [2 3], [], [], [], ...
%           [255 255 0; 0 255 255])
%
%   Show any combination of targets by
%
%       showTargets([1 3])
% 

%	5/29/01 ... created by jig
%   6/06 ... greatly change and adapted to OSX by MKMK
%   June 2014 revised code syntax and comments by Jian Wang

if isempty(x_position)
    x_position = 0;
end

if isempty(y_position)
    y_position = 0;
end

if isempty(diameter)
    diameter = 2;
end

center = repmat(screenInfo.center',size(x_position));

% ppd is off by a factor of 10 so that we don't send any fractions to rex
ppd = screenInfo.ppd/10;
% change the xy coordinates to pixels (y is inverted - pos on bottom, neg. on top
tar_xy = [center(1,:) + x_position * ppd; center(2,:) - y_position * ppd];

% change the diameter to pixels, make it same size as tar_xy so we can add them
diam = [diameter; diameter] * ppd;

% change from center and diameter to the corners of a box that encloses the circle 
% for use with Screen('FillOval')
tarRects = [tar_xy-diam/2; tar_xy+diam/2]';

if isempty(tcolor)
    tcolor = [255,255,255];
end

FixationX.hline = [[center(1,:) + x_position * ppd - diam(1)/2;center(2,:) - y_position * ppd],[center(1,:) + x_position * ppd + diam(1)/2;center(2,:) - y_position * ppd]] ;
FixationX.vline = [[center(1,:) + x_position * ppd; center(2,:) - y_position * ppd - diam(2)/2],[center(1,:) + x_position * ppd; center(2,:) - y_position * ppd + diam(2)/2]] ;
FixationX.xy = [FixationX.hline,FixationX.vline];
FixationX.d = diameter;
FixationX.colors = tcolor;