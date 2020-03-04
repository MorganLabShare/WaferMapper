function FixMontageParametersDefaults(paramInput)
%Fill in any absent parameters with defaults

global GuiGlobalsStruct;

%record previous

if exist('paramInput','var')
    oldParam = paramInput;
else
    oldParam = GuiGlobalsStruct.MontageParameters;
end

oldFields = fieldnames(oldParam);

%set to defaults
SetMontageParametersDefaults;

%Replace defaults with any previous
for i = 1:length(oldFields)
    Value = getfield(oldParam,oldFields{i});
    GuiGlobalsStruct.MontageParameters = setfield(GuiGlobalsStruct.MontageParameters,oldFields{i},Value);
end
