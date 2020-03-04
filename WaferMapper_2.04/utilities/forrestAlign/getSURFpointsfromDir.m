function [points,FullFiles]=getSURFpointsfromDir(StackDirectory,Options)
    %use OpenSurf to get SURF points from each section in the virtual stack
    %of StackDirectory (assumes tif files). 
    %Options is a struct which contains the options for the OpenSurf points
    %see help OpenSurf for details
    %returns points, a 1xZ cell array containing the SURF points
    files=dir([StackDirectory '*.tif'])
    imagepath=[StackDirectory files(1).name];
    theinfo=imfinfo(imagepath);
    N=theinfo.Height;
    M=theinfo.Width;
    Z=length(files);
    FullFiles=cell(1,Z);
    %% calculate points of interest
    points=cell(1,Z);
    if ~exist('Options','var')
        Options.verbose=false;
        Options.init_sample=2;
        Options.octaves=3;
        Options.tresh=.001;
    end
    if ~isfield(Options,'verbose')
        Options.verbose=0;
    end
    if ~isfield(Options,'init_sample')
         Options.init_sample=2;
    end
    if ~isfield(Options,'octaves')
        Options.octaves=3;
    end
    if ~isfield(Options,'tresh')
        Options.tresh=.001;
    end
    matlabpool(8);
    
    parfor i=1:Z
        FullFiles{i}=[StackDirectory files(i).name]
        data=imread(FullFiles{i});
        points{i}=OpenSurf(data,Options);
    end
    matlabpool CLOSE;
end
