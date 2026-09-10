% Display All Channels after grouping them based on electrode distance from
% the stimulation electrode.

% This function accepts both single session and multiple sessions.
% For multiple sessions, use cells for expData, protocolName and
% stimulationElectrode
% e.g. expDate = {'281025', '301025'}

% In these protocols
% azimuth is mapped to amplitude of the stimulation
% elevation is mapped to the frequency of stimulation (in the old version,
% it was the number of pulses)
% temporal frequency is mapped to duration (in the old version, the
% frequency of stimulation)

function displayAllChannelsICMSSingleElectrode(subjectName,expDate,protocolName,folderSourceString,stimulationElectrode,badTrialNameStr,useCommonBadTrialsFlag, modulatorElectrode, smooth)

if ~exist('folderSourceString','var');   folderSourceString='E:';       end
if ~exist('badTrialNameStr','var');     badTrialNameStr = '_v5';        end
if ~exist('useCommonBadTrialsFlag','var'); useCommonBadTrialsFlag = 1;  end

gridType = 'Microelectrode';
isSingleSession = false;
if (ischar(expDate))
    isSingleSession = true;
    expDate = {expDate};
    protocolName = {protocolName};
    stimulationElectrode = {stimulationElectrode};
end

% Load Parameter combinations
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate{1},protocolName{1});

% Get folders
folderExtract = fullfile(folderName,'extractedData');

% Get Combinations
[~,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);

% Check for consistency
for i=2:length(expDate)
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate{i},protocolName{i});

    % Get folders
    folderExtract = fullfile(folderName,'extractedData');
    
    % Get Combinations
    [~,aValsUnique_,eValsUnique_,sValsUnique_,...
        fValsUnique_,oValsUnique_,cValsUnique_,tValsUnique_] = loadParameterCombinations(folderExtract);
    
    if (~isequal(aValsUnique, aValsUnique_) ||...            
            ~isequal(sValsUnique,sValsUnique_) ||...
            ~isequal(fValsUnique,fValsUnique_) ||...
            ~isequal(oValsUnique,oValsUnique_) )%||...
            % ~isequal(cValsUnique,cValsUnique_) )%||...
            % ~isequal(eValsUnique,eValsUnique_) ||...
            % ~isequal(tValsUnique,tValsUnique_))
        error('Parameter combinations not consistent across sessions');
    end
end

% Guess the type of protocol
if ~isscalar(aValsUnique) && isscalar(eValsUnique) && isscalar(tValsUnique) && isempty(modulatorElectrode)
    protocolType = 1; 
    condVals = aValsUnique;
elseif isscalar(aValsUnique) && ~isscalar(eValsUnique) && isscalar(tValsUnique) && isempty(modulatorElectrode)
    protocolType = 2;
    condVals = eValsUnique;
elseif ~isempty(modulatorElectrode) % for the paired stimulation protocol
        protocolType = 3; 
        condVals = aValsUnique;
else
    error('Parameter combinations not in valid format');
end
numConditions = length(condVals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.25; panelStartHeight = 0.7;
staticPanelWidth = 0.2; staticStartPos = 0.75;
dynamicPanelWidth = 0.2; dynamicStartPos = 0.05;
timingPanelWidth = 0.2; timingStartPos = 0.25;
plotOptionsPanelWidth = 0.2; plotOptionsStartPos = 0.45;
backgroundColor = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamicHeight = 0.12; dynamicGap=0.02; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

% Amplitude
amplitudeString = getStringFromValues(aValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Amplitude (microAmps)','FontSize',fontSizeSmall);

if protocolType == 1
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','text','String','variable','FontSize',fontSizeSmall);
else
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','text','String',amplitudeString,'FontSize',fontSizeSmall);
end

% Frequency
freqString = getStringFromValues(eValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Freq / #Pulses','FontSize',fontSizeSmall);

if protocolType == 2
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','text','String','variable','FontSize',fontSizeSmall);
else
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','text','String',freqString,'FontSize',fontSizeSmall);
end

% Sigma
sigmaString = getStringFromValues(sValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Sigma (Deg)','FontSize',fontSizeSmall);
hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',sigmaString,'FontSize',fontSizeSmall);

% Spatial Frequency
spatialFreqString = getStringFromValues(fValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeSmall);
hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',spatialFreqString,'FontSize',fontSizeSmall);

% Orientation
orientationString = getStringFromValues(oValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Orientation (Deg)','FontSize',fontSizeSmall);
hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',orientationString,'FontSize',fontSizeSmall);

% Contrast
if ~isempty(cValsUnique)
    contrastString = getStringFromValues(cValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Contrast (%)','FontSize',fontSizeSmall);
    hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',contrastString,'FontSize',fontSizeSmall);
end

% Duration or frequency
if ~isempty(tValsUnique)
    temporalFreqString = getStringFromValues(tValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Dur / Freq','FontSize',fontSizeSmall);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','text','String',temporalFreqString,'FontSize',fontSizeSmall);
end

% Reference scheme
referenceChannelString = 'None';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.11; timingTextWidth = 0.5; timingBoxWidth = 0.25;
hTimingPanel = uipanel('Title','Timing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[timingStartPos panelStartHeight timingPanelWidth panelHeight]);

signalRange = [-0.5 1.5];
freqRange = [0 100];
if protocolType == 3 
    baseline = [-0.8 -0.3];
    stimPeriod = [0.75 1.25];
else
baseline = [-0.7 -0.2];
stimPeriod = [0.7 1.2];
end
delPSDFreqRange = [16 32];

% Signal Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Parameter','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Min','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Max','FontSize',fontSizeMedium);

% Stim Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim Range (s)','FontSize',fontSizeSmall);
hStimMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall);

% Freq Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Freq Range (Hz)','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-4*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(freqRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-4*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(freqRange(2)),'FontSize',fontSizeSmall);

% Delta PSD Freq Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Delta PSD Freq Range (Hz)','FontSize',fontSizeSmall);
hDelPSDMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(delPSDFreqRange(1)),'FontSize',fontSizeSmall);
hDelPSDMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(delPSDFreqRange(2)),'FontSize',fontSizeSmall);

% Baseline
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);

% Subtract No Stim Condition
hNoStimSubtract = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','togglebutton','String','Subtract No Stim','Value',0,'FontSize',fontSizeSmall);

% Subtract No Stim Condition
hShowSpiking = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.5 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','togglebutton','String','Show Spiking','Value',0,'FontSize',fontSizeSmall);

% Z Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-9*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Z Range','FontSize',fontSizeSmall);
hZMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','-5','FontSize',fontSizeSmall);
hZMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','10','FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotOptionsHeight = 0.15;
hPlotOptionsPanel = uipanel('Title','Plotting Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos panelStartHeight plotOptionsPanelWidth panelHeight]);

% Single Plot Options
singlePlotString = {"Electrodes", "vs Microstim Parameter", "vs Distance"};
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 5*plotOptionsHeight 0.5 plotOptionsHeight], ...
    'Style','text','String','Single Plot','FontSize',fontSizeSmall);
hSinglePlot = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 5*plotOptionsHeight 0.5 plotOptionsHeight], ...
    'Style','popup','String',singlePlotString,'FontSize',fontSizeSmall);

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 3*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','cla','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 2*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale Z','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleZ_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale XY','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 0 1 plotOptionsHeight], ...
    'Style','pushbutton','String','plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show electrode array and bad channels
% Get Bad channels from the main impedance file

badImpedanceCutoff = 2500;
for i=1:length(expDate)
    impedanceFileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate{i},'impedanceValues.mat');    
    
    if exist(impedanceFileName,'file')
        impedanceValues = getImpedanceValues(impedanceFileName);
        badChannels = [find(impedanceValues>badImpedanceCutoff) find(isnan(impedanceValues))];
    else
        disp(['Could not find impedance values for ' expDate{i}]);
        badChannels=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%% Get good electrode lists %%%%%%%%%%%%%%%%%%%%%%%%%
electrodeGridPos = [staticStartPos panelStartHeight staticPanelWidth panelHeight];
[~,~,electrodeArray] = electrodePositionOnGrid(1,gridType,subjectName);
for i=1:length(stimulationElectrode)
    [electrodeGroupList{i},groupNameList{i},goodElectrodes{i}] = getElectrodeGroups(subjectName,gridType,electrodeArray,stimulationElectrode{i},badChannels,expDate{i});
    
    %remove modElecs for paired stim 
    if ~isempty(modulatorElectrode{i})
        modElec = modulatorElectrode{i}; 
        for group = 1:length(electrodeGroupList{i})
            if ismember(modElec, electrodeGroupList{i}{group})
                electrodeGroupList{i}{group} = setdiff(electrodeGroupList{i}{group}, modElec);
            end
        end
        goodElectrodes{i} = setdiff(goodElectrodes{i},modElec);
    end
    
    numElectrodeGroups(i) = length(electrodeGroupList{i});
end
[maxNumElectrodeGroups, idx] = max(numElectrodeGroups);
colorNamesElectrodeGroups = copper(maxNumElectrodeGroups);

if (isscalar(stimulationElectrode))
    % Single electrode condition
    for iG=1:numElectrodeGroups(1)
        hElectrodes = showElectrodeLocations(electrodeGridPos,electrodeGroupList{1}{iG},colorNamesElectrodeGroups(iG,:),[],1,0,gridType,subjectName);
        text(hElectrodes,-0.35,iG/10,groupNameList{1}{iG},'color',colorNamesElectrodeGroups(iG,:),'unit','normalized');
    end

    if ~isempty(badChannels)
        showElectrodeLocations(electrodeGridPos,badChannels,'r',[],1,0,gridType,subjectName);
        text(hElectrodes,-0.35,1,'Bad','color','r','unit','normalized');
    end

else
    hElectrodes = subplot('Position',electrodeGridPos,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],'box','on');
    theta = linspace(0, 2*pi, 100); % Angles from 0 to 2*pi
    radii = linspace(5, 50, maxNumElectrodeGroups); % Radii is only for number of ellipses
    hold on;
    for iG = maxNumElectrodeGroups:-1:1
        r = radii(iG);
        x = r * cos(theta);
        y = r * sin(theta);        
        fill(x, y, colorNamesElectrodeGroups(iG,:), 'EdgeColor', 'flat');
        text(hElectrodes,-0.35,iG/10,groupNameList{idx}{iG},'color',colorNamesElectrodeGroups(iG,:),'unit','normalized');
    end
    % axis equal; % To make circle
    hold off;
end
% Get main plots and message handles
hERP = getPlotHandles(maxNumElectrodeGroups,1,[0.05 0.05 0.1 0.6]);
hFR  = getPlotHandles(maxNumElectrodeGroups,1,[0.175 0.05 0.1 0.6]);
hDeltaPSD = getPlotHandles(maxNumElectrodeGroups,1,[0.3 0.05 0.1 0.6]);
hDeltaTF  = getPlotHandles(maxNumElectrodeGroups,numConditions,[0.425 0.05 0.55 0.6]);

uicontrol('Unit','Normalized','Position',[0 0.975 1 0.025],'Style','text',...
    'String',[subjectName expDate protocolName],'FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%% Get data from  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numStimulationElectrodes = length(stimulationElectrode);
numGoodElectrodes = max(cellfun(@length, goodElectrodes));
totalGoodElectrodes = length([goodElectrodes{:}]);
allData = cell(numStimulationElectrodes,numGoodElectrodes);
for j=1:numStimulationElectrodes
    numGoodElectrodes = length(goodElectrodes{j});
    for i=1:numGoodElectrodes
        channelString = ['elec' num2str(goodElectrodes{j}(i))];
        disp(['Getting data: ' num2str((j-1)*numGoodElectrodes + i) ' of ' num2str(totalGoodElectrodes) ', ' channelString ' of ' protocolName{j} ', ' expDate{j}]);
    
        data = getSpikeLFPDataSingleChannel(subjectName,expDate{j},protocolName{j},folderSourceString,channelString,0,gridType,[],referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
        % [analogData, filterStr] = applyFilter(data.analogData,2000,'butter','high',1,3);
        % disp(['Applying ' filterStr ' on LFP'])
        % data.analogData = analogData;
        allData{j,i} = data;
    end        
end
colormap jet;
colorNames = jet(numConditions);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)

        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        con=get(hContrast,'val');

        signalRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        freqRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        delPSDFreqRange = [str2double(get(hDelPSDMin,'String')) str2double(get(hDelPSDMax,'String'))];

        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];

        isNoStimSubtract = get(hNoStimSubtract,'val');
        isShowSpiking = get(hShowSpiking, 'val');
        singlePlotType = get(hSinglePlot,'val');

        removeERPFlag = 1;
        
        deltaPSDSlowGamma = cell(max(numElectrodeGroups), numConditions);
        firingRateAllElecs = cell(max(numElectrodeGroups), numConditions);
        deltaTFNoStim = cell(max(numElectrodeGroups),1);
        deltaPSDNoStim = cell(max(numElectrodeGroups),1);
        tmpDeltaPSDNoStim = cell(max(numElectrodeGroups),1);
        for iCond = 1:numConditions

            if ismember(protocolType, [1,3])
                a = iCond; e = 1; t = 1;
            elseif protocolType == 2
                a = 1; e = iCond; t = 1;
            end
            
            
            numElectrodesInGroup = zeros(1, maxNumElectrodeGroups);
            for iGroup = 1:maxNumElectrodeGroups
                clear tmpElectrodes
                % Get data from electrodes                   
                for session=1:size(electrodeGroupList,2)
                    if iGroup > length(electrodeGroupList{session}) 
                        continue; 
                    end
                    tmpElectrodes{session} = electrodeGroupList{session}{iGroup};   %#ok<*AGROW>
                    numElectrodesInGroup(iGroup) = numElectrodesInGroup(iGroup) + length(tmpElectrodes{session});
                end
                
                if ~isempty(tmpElectrodes)

                    if numElectrodesInGroup(iGroup) > 1 % Combine across electrodes

                        tmpERPData = []; tmpFRData = []; tmpDeltaPSD = []; tmpDeltaTF = [];
                        
                        for session = 1:length(tmpElectrodes)  
                            % Accounting for difference in protocols
                            % performed before and after 060726
                            sessionDate = datetime(char(expDate{session}), 'InputFormat', 'ddMMyy');
                           if ismember(protocolType, [1,2])
                               referenceDate = datetime('060726', 'InputFormat', 'ddMMyy');
                            isAfterProtocolChange = sessionDate > referenceDate;
                            if isAfterProtocolChange
                                if con == 1   % 0% contrast not recorded after 060726                                    
                                    if isSingleSession
                                        c = con;
                                    else
                                        % TODO: Handle 0% contrast case. Till
                                        % then avoid 0% contrast
                                        error("0% contrast case is not handled. Please do not select 0% contrast.")
                                    end
                                else
                                    c = con-1;
                                end
                            else
                                c = con;
                            end
                           else
                                c=con;
                           end
                            
                            for k = 1:length(tmpElectrodes{session})
                                tmpData = getDataGRF(allData{session,tmpElectrodes{session}(k)==goodElectrodes{session}},a,e,s,f,o,c,t,blRange,stRange,removeERPFlag);

                                tmpERPData = cat(1,tmpERPData,tmpData.erp);
                                tmpFRData = cat(1,tmpFRData,tmpData.frVals);
                                tmpDeltaPSD = cat(1,tmpDeltaPSD,tmpData.deltaPSD');
                                tmpDeltaTF = cat(3,tmpDeltaTF,tmpData.deltaTF);
                            end
                        end
                        
                        erpData = mean(tmpERPData,1);
                        frData = mean(tmpFRData,1);
                        deltaPSD = mean(tmpDeltaPSD,1);
                        deltaTF = squeeze(mean(tmpDeltaTF,3));                        
                    else
                        % TODO: Update for single elctrode in group in multiple protocol case
                        zeroCol = 1;
                        while zeroCol <= length(tmpElectrodes) 
                            if isempty(tmpElectrodes{zeroCol})
                                tmpElectrodes(:,zeroCol) = [];
                            else 
                                zeroCol = zeroCol + 1;
                            end
                        end
                        tmpData = getDataGRF(allData{tmpElectrodes{1}==goodElectrodes{1}},a,e,s,f,o,con,t,blRange,stRange,removeERPFlag);
                        erpData = tmpData.erp;
                        frData = tmpData.frVals;
                        tmpFRData = frData;
                        deltaPSD = tmpData.deltaPSD';
                        tmpDeltaPSD = deltaPSD;
                        deltaTF = tmpData.deltaTF;
                    end                                           

                    if iCond == 1
                        deltaTFNoStim{iGroup} = deltaTF;
                        deltaPSDNoStim{iGroup} = deltaPSD;
                        tmpDeltaPSDNoStim{iGroup} = tmpDeltaPSD;
                    end
                    
                    if isNoStimSubtract
                        deltaTF = deltaTF - deltaTFNoStim{iGroup};
                        deltaPSD = deltaPSD - deltaPSDNoStim{iGroup};
                        tmpDeltaPSD = tmpDeltaPSD - tmpDeltaPSDNoStim{iGroup};
                    end
                                        
                    deltaPSDSlowGamma{iGroup, iCond} = mean(squeeze(tmpDeltaPSD(:,tmpData.freqST>=delPSDFreqRange(1) & tmpData.freqST<=delPSDFreqRange(2))),2);
                    firingRateAllElecs{iGroup, iCond} = mean(tmpFRData(:, tmpData.frTimeVals >= stRange(1) & tmpData.frTimeVals <= stRange(2)), 2)...
                        - mean(tmpFRData(:, tmpData.frTimeVals >= blRange(1) & tmpData.frTimeVals <= blRange(2)), 2);

                    % Plot data
                    if isSingleSession
                        % plot(hERP(iGroup),tmpData.timeVals,erpData,'color',colorNames(iCond,:)); hold(hERP(iGroup),'on');
                        plot(hERP(iGroup),tmpData.frTimeVals,frData,'color',colorNames(iCond,:)); hold(hERP(iGroup),'on');
                    end

                    if isShowSpiking
                        plot(hDeltaPSD(iGroup),tmpData.frTimeVals,frData,'color',colorNames(iCond,:)); hold(hDeltaPSD(iGroup),'on');
                    elseif smooth == 1
                            deltaPSD_smooth = sgolayfilt(deltaPSD,3,9);
                            plot(hDeltaPSD(iGroup),tmpData.freqST,deltaPSD_smooth,'color',colorNames(iCond,:)); hold(hDeltaPSD(iGroup),'on');
                            plot(hDeltaPSD(iGroup),tmpData.freqST,zeros(1,length(deltaPSD_smooth)),'color','k');
                        else
                        plot(hDeltaPSD(iGroup),tmpData.freqST,deltaPSD,'color',colorNames(iCond,:)); hold(hDeltaPSD(iGroup),'on');
                        plot(hDeltaPSD(iGroup),tmpData.freqST,zeros(1,length(deltaPSD)),'color','k');
                    end                    
                    pcolor(hDeltaTF(iGroup,iCond),tmpData.timeTF,tmpData.freqTF,deltaTF'); shading(hDeltaTF(iGroup,iCond),'interp');
                    clim(hDeltaTF(iGroup,iCond),zRange); axis(hDeltaTF(iGroup,iCond),[signalRange freqRange]);
                    
                end
            end
        end
        
        % Plot mean deltaPSD across electrodes in each group
        % if true
            if singlePlotType ~= 1
                cla(hElectrodes);
                hold(hElectrodes,'on'); 
                hElectrodes.YTickMode = 'auto';
                hElectrodes.YTickLabelMode = 'auto';
            end
            for iGroup=1:max(numElectrodeGroups)
                groupData = zeros(size(deltaPSDSlowGamma{iGroup,1},1),numConditions);                
                for iCond=1:numConditions                
                    if isShowSpiking
                        groupData(:,iCond) = firingRateAllElecs{iGroup, iCond};
                    else
                        groupData(:,iCond) = deltaPSDSlowGamma{iGroup,iCond};
                    end
                    
                end            
                meanData = mean(groupData,1);
                errorData = std(groupData,[],1)/sqrt(size(groupData,1));

                if singlePlotType == 2                    
                    errorbar(hElectrodes, 0:numConditions-1, meanData,errorData,...
                        '-o','Color',colorNamesElectrodeGroups(iGroup,:),'LineWidth',1.2);                    
                end
                errorbar(hFR(iGroup), 0:numConditions-1, meanData,errorData,...
                    '-o','Color',colorNamesElectrodeGroups(iGroup,:),'LineWidth',1.2,...
                    'MarkerSize',5);   
                if ~isSingleSession
                    ax = ancestor(hERP(iGroup), 'axes');            
                    v = violinplot(ax, groupData);
                    hold(ax, 'on');
                end
                % fprintf("Running Stats for %s", groupNameList{i});                
                if size(groupData, 1) > 1
                pValues = zeros(numConditions, numConditions);
                for xi = 1:numConditions
                    for yi = 1:numConditions
                        if xi ~= yi
                            % [h, p] = ttest(deltaPSDGroup(:,xi), deltaPSDGroup(:,yi));
                            [p, h] = signrank(groupData(:,xi), groupData(:,yi));
                            pValues(xi,yi) = p;
                            % if h == 1
                            %     fprintf("%d %s significantly different from %d %s, p-value = %f\n",xVals(x),units,xVals(y),units,p);
                            % end
                        end
                    end
                end
                
                maxValue = max(max(groupData));
                for xt = 1:numConditions
                    if ~isSingleSession
                        v(xt).FaceColor = colorNames(xt,:);
                        scatter(hERP(iGroup),ones(size(groupData,1))*xt, groupData(:,xt), 10, colorNames(xt,:), "filled")
                    end
                    % Plot Significance
                    if xt < numConditions
                        if pValues(xt,xt+1) < 0.05
                            % Draw a line between the two groups  
                            ax = ancestor(hFR(iGroup), 'axes');
                            line(ax,[xt-0.95, xt-0.05], [maxValue, maxValue] + 0.5, 'Color', 'k', 'LineWidth', 1);
                            % Add asterisk for significance
                            if pValues(xt,xt+1) < 0.001
                                significanceLevel = '***';
                            elseif pValues(xt,xt+1) < 0.01
                                significanceLevel = '**';
                            else
                                significanceLevel = '*';
                            end
            
                            text(ax,mean([xt-1, xt]), maxValue + 0.5, significanceLevel, 'HorizontalAlignment', 'center', 'FontSize', 14);                             
                        end
                    end
                end                                
                end
            end
       
            
            % Plot vs distance from stimulation electrode
            if singlePlotType == 3
                % numElecsToChoose = size(deltaPSDSlowGamma{1,1},1);
                for iCond=1:numConditions                    
                    % deltaPSDCond = zeros(max(numElectrodeGroups), numElecsToChoose);
                    meanData = zeros(max(numElectrodeGroups),1);
                    errorData = zeros(max(numElectrodeGroups),1);
                    for iGroup=1:max(numElectrodeGroups)                                                                
                        % tempData = deltaPSDSlowGamma{iGroup,iCond};
                        % randIndices = randsample(length(tempData), numElecsToChoose);
                        % deltaPSDCond(iGroup,:) = tempData(randIndices);
                        if isShowSpiking
                            meanData(iGroup) = mean(firingRateAllElecs{iGroup, iCond});
                            errorData(iGroup) = std(firingRateAllElecs{iGroup, iCond})/sqrt(size(firingRateAllElecs{iGroup, iCond},1));
                        else
                            meanData(iGroup) = mean(deltaPSDSlowGamma{iGroup, iCond});
                            errorData(iGroup) = std(deltaPSDSlowGamma{iGroup, iCond})/sqrt(size(deltaPSDSlowGamma{iGroup, iCond},1));
                        end
                    end            
                    % meanDelPSD = mean(deltaPSDCond,2);
                    % errorDelPSD = std(deltaPSDCond,[],2)/sqrt(size(deltaPSDCond,2));                    
                    errorbar(hElectrodes, 0:max(numElectrodeGroups)-1, meanData,errorData,...
                        '-o','Color',colorNames(iCond,:),'LineWidth',1.2);
                end

                rescalePlots(hElectrodes, [0 max(numElectrodeGroups) getYLims(hElectrodes)]);                       
                xticks(hElectrodes, [0 0.5:1:max(numElectrodeGroups)-1.5])
                xticklabels(hElectrodes, 0:0.4:max(numElectrodeGroups)*0.4)  
                title(hElectrodes, singlePlotString{3});
            end

            % Plot Decoration
            if protocolType == 1
                tuningTitle = 'vs Amplitude';
            else
                if eValsUnique(end) == 7
                    tuningTitle = 'vs # Pulses';
                else
                    tuningTitle = 'vs Frequency';
                end
            end
            % Rescale plots to same scale
            rescalePlots(hFR, [0 numConditions getYLims(hFR)]);
            rescalePlots(hERP,[0 numConditions getYLims(hERP)]);

            if singlePlotType == 2
                rescalePlots(hElectrodes, [0 numConditions getYLims(hElectrodes)]);                       
                xticks(hElectrodes, 0:numConditions-1)
                xticklabels(hElectrodes, condVals)                
                title(hElectrodes,tuningTitle);
            end
            
            xticks(hFR(max(numElectrodeGroups)), 0:numConditions-1)
            xticklabels(hFR(max(numElectrodeGroups)), condVals)
            xtickangle(hFR(max(numElectrodeGroups)), 90)
            title(hFR(1),tuningTitle);  
            
            if ~isSingleSession
                xticklabels(hERP(max(numElectrodeGroups)), condVals) 
                xtickangle(hERP(max(numElectrodeGroups)), 90)
                title(hERP(1),[tuningTitle ' (Violin)']);                              
            end
        if isSingleSession
            % Rescale plots to same scale
            rescalePlots(hERP,[signalRange getYLims(hERP)]);
            % rescalePlots(hFR,[signalRange getYLims(hFR)]);
            title(hERP(1),'ERP');
            % title(hFR(1),'Firing Rates');
        end
        
        if isShowSpiking                    
            rescalePlots(hDeltaPSD,[signalRange getYLims(hDeltaPSD)]);                        
            title(hDeltaPSD(1),'Firing Rates');
        else
            rescalePlots(hDeltaPSD,[freqRange getYLims(hDeltaPSD)]);                        
            title(hDeltaPSD(1),'\DeltaPSD (dB)');
        end

        for iCond = 1:numConditions
            title(hDeltaTF(1,iCond),num2str(condVals(iCond)),'color',colorNames(iCond,:));
        end
        
        % ylabel(hElectrodes, '\Delta Gamma Power')
        for iGroup = 1:maxNumElectrodeGroups
            ylabel(hERP(iGroup),groupNameList{idx}{iGroup},'color',colorNamesElectrodeGroups(iGroup,:));
            text(0.8,0.8,['N=' num2str(numElectrodesInGroup(iGroup))],'units','Normalized','Parent',hERP(iGroup));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleZ_Callback(~,~)

        zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];
        rescaleZPlots(hDeltaTF,zRange);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function rescaleData_Callback(~,~)
        
        signalRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        freqRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];

        % Rescale plots to same scale
        rescalePlots(hERP,[signalRange getYLims(hERP)]);
        rescalePlots(hFR,[signalRange getYLims(hFR)]);
        rescalePlots(hDeltaPSD,[freqRange getYLims(hDeltaPSD)]);
        rescalePlots(hDeltaTF,[signalRange freqRange]);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        claPlots(hERP);
        claPlots(hFR);
        claPlots(hDeltaPSD);
        claPlots(hDeltaTF);
        claPlots(hElectrodes);

        function claPlots(plotHandles)
            [numRow,numCol] = size(plotHandles);
            for ii=1:numRow
                for jj=1:numCol
                    cla(plotHandles(ii,jj));
                end
            end
        end

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        % tmpAxisVals = axis(plotHandles(row,column));
        tmpAxisVals = [0 0 ylim(plotHandles(row,column))];        
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end
function rescalePlots(plotHandles,axisLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        if iscategorical(xlim(plotHandles(i,j)))
            ylim(plotHandles(i,j),axisLims(3:4))
        else
            axis(plotHandles(i,j),axisLims);
        end
    end
end
end
function rescaleZPlots(plotHandles,caxisLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        clim(plotHandles(i,j),caxisLims);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [electrodeGroupList,groupNameList,goodElectrodes] = getElectrodeGroups(subjectName,gridType,electrodeArray,stimulationElectrode,badChannels,expDate_)
% Accounting for difference in protocols
% performed before and after 060726
sessionDate = datetime(char(expDate_), 'InputFormat', 'ddMMyy');
referenceDate = datetime('060726', 'InputFormat', 'ddMMyy');
isAfterProtocolChange = sessionDate > referenceDate;

% get highRMSelectrodes
tmp = load([subjectName gridType 'RFData.mat']); % Get RF data
highRMSElectrodes = tmp.highRMSElectrodes;
if strcmp(subjectName,'dona')    
    highRMSElectrodes = highRMSElectrodes(highRMSElectrodes<=48); % Only V1
    if isAfterProtocolChange        
        highRMSElectrodes = [highRMSElectrodes 12 32 33];     % Making 12, 32 and 33 high RMS electrode    
        nonResponsiveElectrodes = [9,10,18,19,20,27,29,30,39,40,43,45,48];
        highRMSElectrodes = setdiff(highRMSElectrodes, nonResponsiveElectrodes);
    end
elseif strcmp(subjectName,'jojo')    
    highRMSElectrodes = highRMSElectrodes(highRMSElectrodes>48); % Only V1
    highRMSElectrodes = [highRMSElectrodes [84 89]];    % Temporarily making 89 a high RMS electrode
end
goodElectrodes = setdiff(highRMSElectrodes,badChannels);

[r1,c1] = find(electrodeArray==stimulationElectrode);

distances = [];
for i=1:length(goodElectrodes)
    [r2,c2] = find(electrodeArray==goodElectrodes(i));
    distances = cat(2,distances,0.4*sqrt((r1-r2).^2 + (c1-c2).^2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Now pool by distance %%%%%%%%%%%%%%%%%%%%%%%%%%%
distanceRangeList = 0:0.4:2.4;
% distanceRangeList(2) = [];
numDistanceRangeList = length(distanceRangeList);
electrodeGroupList = cell(1,numDistanceRangeList);
groupNameList = cell(1,numDistanceRangeList);
for i=1:numDistanceRangeList-1
    electrodeGroupList{i} = goodElectrodes(intersect(find(distances>=distanceRangeList(i)),find(distances<distanceRangeList(i+1))));
    groupNameList{i} = [num2str(distanceRangeList(i)) '<=d<' num2str(distanceRangeList(i+1))];
end
electrodeGroupList{numDistanceRangeList} = goodElectrodes(distances>=distanceRangeList(numDistanceRangeList));
groupNameList{numDistanceRangeList} = ['d>=' num2str(distanceRangeList(numDistanceRangeList))];

% Check for empty electrode list
for i=numDistanceRangeList:-1:1
    if isempty(electrodeGroupList{i})
        electrodeGroupList(i) = [];
        groupNameList(i) = [];
        numDistanceRangeList = numDistanceRangeList - 1;
    end
end


end
function outString = getStringFromValues(valsUnique,decimationFactor)

if isscalar(valsUnique)
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
% load Data
function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract)

x=load(fullfile(folderExtract,'parameterCombinations.mat'));
parameterCombinations=x.parameterCombinations;
aValsUnique=x.aValsUnique;
eValsUnique=x.eValsUnique;

if ~isfield(x,'sValsUnique')
    sValsUnique = x.rValsUnique/3;         
else
    sValsUnique=x.sValsUnique;
end

fValsUnique=x.fValsUnique;
oValsUnique=x.oValsUnique;

if ~isfield(x,'cValsUnique')
    cValsUnique=[];
else
    cValsUnique=x.cValsUnique;
end

if ~isfield(x,'tValsUnique')
    tValsUnique=[];
else
    tValsUnique=x.tValsUnique;
end
end
function impedanceValues = getImpedanceValues(fileName)
x=load(fileName);
if isfield(x,'impedanceValues')
    impedanceValues = x.impedanceValues;
elseif isfield(x,'electrodeImpedances')
    impedanceValues = x.electrodeImpedances;
else
    disp('Impedance information is not available');
    impedanceValues = [];
end
end