%%Merlin Evactron Checklist 
%{
1) start timed rotation
2) Disconnect SCM
3) open Evactron Control and Vac Test program
4) Vent chamber above 1 Torr
5) Enable Evactron
6) Pump Chamber
8) Turn off Quiet Mode
7) Turn off turbo pump before 3 * 10 ^0

%}

% 
% if ~exist('sm','var')
%     sm = startFibics;
% end
global GuiGlobalsStruct

sm = GuiGlobalsStruct.MyCZEMAPIClass;


%% Get old
oldX = sm.Get_ReturnTypeSingle('AP_STAGE_GOTO_X');
oldY = sm.Get_ReturnTypeSingle('AP_STAGE_GOTO_Y');
oldR = sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
oldT = sm.Get_ReturnTypeSingle('AP_STAGE_AT_T');
oldZ = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Z');


%% Move to corner
X =  59.127e-003; %0 is limit. 50 still causing faults with stage bias off
Y =  86.822e-003; %130 is limit, 98 still causing faults with stage bias off
Z =  21.019e-003;
T =  48.4;



sm.Set_PassedTypeSingle('AP_STAGE_GOTO_X',X);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_Y',Y);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_Z',Z);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_T',T);
smwait(sm,'DP_STAGE_IS');


tic


%% Rotate
Time = 200; %minutes
sm.Set_PassedTypeString('DP_STAGE_BACKLASH','Off')
startRotationTime = clock;
while toc < (Time * 300)
    timeLeft = Time - toc/60
    % R =sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    sm.Set_PassedTypeSingle('AP_STAGE_GOTO_R',0);
    TargetR=0;
    i=40; %speed control
    
    while TargetR < 360
        TargetR = round(TargetR +i);
        sm.Set_PassedTypeSingle('AP_STAGE_GOTO_R',TargetR);
        
        dpAuto = 'holding';
        pause(.2)
        lastR = oldR;
        tic;
        keepTurning = 1;
        waitForTurn = 1;
        while waitForTurn %wait to finish moving
            currentR = sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
            pause(.01)
            if   abs(TargetR-currentR)<1
                waitForTurn = 0;
            end
            
            
            lastCheckedMove = toc;
            if lastCheckedMove >1
                moved = abs(lastR-currentR);
                lastR = currentR;
                if moved < .1
                    sm.Execute('CMD_STAGE_ABORT');
                    waitForTurn = 0;
                end
                tic
            end
            
            
            %dpAuto = sm.Get_ReturnTypeString('DP_STAGE_IS');
            %dpTouch = sm.Get_ReturnTypeString('DP_STAGE_TOUCH');
            %sm.Set_PassedTypeString('DP_STAGE_TOUCH','No')
            
            %         if dpTouch
            %             break
            %         end
        end
   
        timeLeft = Time - (startRotationTime -clock)/60
        'Check stage bias and touch sensor.'
        if TargetR >=360
            TargetR = 0;
        end
    end
    
    %     TargetR = mod(R-157,360);
    %     sm.Set_PassedTypeSingle('AP_STAGE_GOTO_R',TargetR);
    %     smwait(sm,'DP_STAGE_IS')
    
end

sm.Set_PassedTypeString('DP_STAGE_BACKLASH','On')


%% Return to old
smwait(sm,'DP_STAGE_IS')

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_T',oldT);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_Z',oldZ);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_X',oldX);
smwait(sm,'DP_STAGE_IS');

sm.Set_PassedTypeSingle('AP_STAGE_GOTO_Y',oldY);
smwait(sm,'DP_STAGE_IS');







