%% stitchy super class
% A parent class for stitchy methodes.
% 
% Usage:
%         - (filePath):                 Constructor which (optionally) imports the image. 
%         - setPoints( ptNr, coordinate ):  Sets the specified points of a rectangle (pre projection) as [u,v].
%         - getPoints():                       Returns all the setPointss.
%         - stitch():                          Initiate stitchy.
%         - getTileImage():                Returns a copy of the stitching image if neccessary points are specified.
%         - getRefImage():                         Returns a copy of the original image.
%         - setRefImage(filePath):                 Reads the specified image for further use.
% Events:
%         - notstitched:     Triggers if getstitchedImage is called without a sucessful stitchy.
%         - noImage:          Triggers if stitch or getRefImage is called when no image has been specified.
%% class definition

classdef Mosaic < handle
    
    %% properties
    properties (Access = private)
        imRef%          The refrence image
        ptsRef%         Correlating points in refrence image
        
        imTile%         The image to be stitched in
        ptsTile%        Correlating points in tile image
        
        panoramaIm%     the resulting image
        
        refOpened%      Bool of reference image status
        tileOpened%     Bool of tile image status
    end% properties
    
    
    %% events
    events
        noImage
    end% events
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Mosaic( filePath )% Constructor
            obj.ptsRef = zeros(4,3);
            obj.ptsRef(:,3) = 1;
            obj.refOpened = false;
            obj.tileOpened = false;
            
            if nargin > 0
                setImage( filePath );
            end
        end% stitchy
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setPoints( obj, ptNr, coordinate )
            if ptNr>0 && ptNr<=4
                obj.ptsRef( ptNr, 1:2 ) = coordinate;
            end
        end% setPoint
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getPoints(obj)
            pts = obj.ptsRef;
        end% getPoints
               
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getTileImage(obj)
                im = obj.imTile;
        end% getTileImage

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getRefImage( obj )
            if obj.refOpened
                im = obj.imRef;
            else
                notify( obj, 'noImage' );
                im = 0;
            end
        end% getRefImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getPanoramaImage( obj )
            im = obj.panoramaIm;
        end% getPanoramaImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setRefImage( obj, filePath )
            try
                obj.imRef = imread( filePath );
                obj.refOpened = true;
            catch
                notify(obj, 'noImage' );
                obj.refOpened = false;
            end
        end% setImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTileImage( obj, filePath )
            try
                obj.imTile = imread( filePath );
                obj.tileOpened = true;
            catch
                notify(obj, 'noImage' );
                obj.tileOpened = false;
            end
        end% setImage

        function stitch(obj, tileIm)
            
            if nargin > 1
                obj.tileIm = tileIm;
            end
            
            H = homography( obj.ptsRef, obj.ptsTile );
            
                    
            if  ( any(isnan( obj.Ha(:) ))  || outOfBounds(H) )
                disp('No valid affine transformation')
                return;
            end
            
             %tform = affine2d( obj.Ha );
            tform = projective2d( obj.Ha' );
            
            
            % apply transformation
            if obj.imageOpened
                obj.recoveredImage = imwarp( obj.image, tform );
                obj.recovered = true;
                
            else
                notify(obj,'noImage');
            end

            
            
            %TODO
        end% stitch

     end% methods
    
  
    
end% stitchy

   