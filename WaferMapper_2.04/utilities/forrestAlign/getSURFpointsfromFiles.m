function points=getSURFpointsfromFiles(Files,Options)
    %use OpenSurf to get SURF points from each section in the cell array of
    %full file paths
    %Options is a struct which contains the options for the OpenSurf points
    %see help OpenSurf for details
    %returns points, a 1xZ cell array containing the SURF points
   
    if ~exist('Options','var')
        Options.verbose=false;
        Options.init_sample=2;
        Options.octaves=3;
        Options.tresh=.001;
        Options.centerfrac=1.0;
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
    if ~isfield(Options,'tresh')
        Options.centerfrac=1.0;
    end
    
    imagepath=Files{1};
    theinfo=imfinfo(imagepath);
    N=theinfo.Height;
    M=theinfo.Width;
    Z=length(Files);
    centerX=M/2;
    centerY=N/2;
    Cols=[centerX-(Options.centerfrac*M/2) centerX+(Options.centerfrac*M/2)];
    Rows=[centerY-(Options.centerfrac*N/2) centerY+(Options.centerfrac*N/2)];
    PixelRegion={Rows,Cols};
    readRegion=Options.centerfrac<1.0; 
    %% calculate points of interest
    points=cell(1,Z);
    
    matlabpool(8);
    SURFOptions.verbose=Options.verbose;
    SURFOptions.init_sample=Options.init_sample;
    SURFOptions.octaves=Options.octaves;
    SURFOptions.tresh=Options.tresh;
  
    parfor i=1:Z
        if (readRegion)
            data=imread(Files{i},'PixelRegion',PixelRegion);
        else
            data=imread(Files{i});
        end
        points{i}=OpenSurf(data,SURFOptions);
        disp([i Z]);
    end
    matlabpool CLOSE;
end
