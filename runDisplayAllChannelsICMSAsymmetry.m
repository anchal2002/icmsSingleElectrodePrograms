% This code assigns variables for merging multiple recordings using
% displayAllChannelsICMSAsymmetry.m. For visualizing only one protocol,
% input single myDate and myProtocol. For multiple recordings, use a cell
% array. Eg: myDates = {'240626' '290626'}

subjectName = 'dona'; 
myDates = {'240626' '290626' '010726' '020726'};%'010726';%{'240626' '290626' '010726' '020726'};
myProtocols = {'AMS_003' 'AMS_002' 'AMS_002' 'AMS_002'};%{'AMS_003' 'AMS_002' 'AMS_002' 'AMS_002'};
folderSourceString = 'N:'; %Keep commented if locally saved. Uncomment if on network drive 
stimulationElectrode = {21 32 23 26};
expDate = myDates; 
protocolName = myProtocols; 
badTrialNameStr = '';
useCommonBadTrialsFlag = '';


displayAllChannelsICMSMergedv4(subjectName,expDate,protocolName, ...
        folderSourceString,stimulationElectrode,badTrialNameStr,useCommonBadTrialsFlag)


