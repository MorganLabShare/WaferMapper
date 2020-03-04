[SFN SPN] = GetMyFile
[TFN TPN] = GetMyFile



s = getCheckSum([SPN SFN])
t = getCheckSum([TPN TFP])

checkMatch = strcmp(s,t)