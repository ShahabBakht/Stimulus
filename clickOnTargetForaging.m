function result = clickOnTargetForaging()

S.BGImagesFolder = 'C:\Users\Shahab\Documents\Shahab\Stimulus\allImages\';
S.ScreenCov_v = 0.4571;
S.ScreenCov_h = 0.3556;
S.PPD_X = 15;
S.PPD_Y = 15;

listBGImages = ls(S.BGImagesFolder);
listBGImages = listBGImages(3:end,:);
numBGImages = size(listBGImages,1);

screenNumber=max(Screen('Screens'));
[window, wRect]=Screen('OpenWindow', screenNumber);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[winWidth, winHeight] = WindowSize(window);
result.wRect = wRect;
result.winWidth = winWidth;
result.winHeight = winHeight;

windowSubPart = [winWidth/2 - wRect(3) * S.ScreenCov_h/2, winHeight/2 - wRect(4) * S.ScreenCov_v/2, ...
    winWidth/2 + wRect(3) * S.ScreenCov_h/2,  winHeight/2 + wRect(4) * S.ScreenCov_v/2];

try
WaitSecs(1);
for imcount = 1:numBGImages
    thisImage = imread([S.BGImagesFolder,listBGImages(imcount,:)]);
    imtex=Screen('MakeTexture', window, thisImage);
    result.windowSubPart = windowSubPart;
    Screen('FillRect', window, [0 0 0]);
    Screen('DrawTexture', window, imtex, [], windowSubPart);  % fill screen with image
    Screen('Flip', window);
    WaitSecs(1);
    while 1
        ShowCursor('CrossHair');
        [clicks,x,y,~] = GetClicks;
        if clicks>0
            targetPosition(:,imcount)= [x;y];
            break;
        end
    end

    
end
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    cleanup;
    myerr
    myerr.message
    myerr.stack
end %try..catch

result.targetPosition = targetPosition;
cleanup;

end
function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
commandwindow;
% Restore keyboard output to Matlab:
ListenChar(0);
end