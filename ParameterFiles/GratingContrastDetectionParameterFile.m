S.numBlocks               =   1;
S.postStimulusWaitTime    =   2;
S.postResponseWaitTime    =   2;

S.SaveFolder              = 'C:\Users\Shahab\Documents\Shahab\Psychophysics Data';

% 'maxStimulusFrameIndex' is equal to the frame rate. We'd like to get a
% sample from all the time points within one second. The upper limit of
% this is determined by the frame rate. We can also limit this the fist N
% frames within a trial.
S.maxStimulusFrameIndex   =   85;

% stimulus parameters that doesn't change from trial to trial
S.Ydim                    =   30;
S.Xdim                    =   36;
S.Ypxl                    =   1024;
S.Xpxl                    =   1280;
S.distance                =   40;
S.fixR                    =   0.1; %degrees
S.xFoV                    =   atan((S.Xdim/2)/S.distance) * 180/pi * 2;
S.yFoV                    =   atan((S.Ydim/2)/S.distance) * 180/pi * 2;
S.yPPD                    =   S.Ypxl/S.yFoV;
S.xPPD                    =   S.Xpxl/S.xFoV;
S.StimulusSize_radius     =   2.5; % degrees
S.GratingSize_radius      =   2.5;
S.sigma                   =   0.5;
S.f                       =   1/S.xPPD;
S.wf                      =   2 * pi * S.f;
S.K                       =   0.1;
S.dK                      =   0.0851;
S.sigmaX                  =   1.5 * S.xPPD;
S.sigmaY                  =   0.75 * S.yPPD;
S.muY                     =   1.25 * S.yPPD;


