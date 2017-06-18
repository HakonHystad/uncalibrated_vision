%% Stitcher - a class for making a mosaic/stitching images together.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%% methods %%%%%%%%%%%%%%%%%%%%%%%%%
%
% - Stitcher( ['refImage'] )%                   Initializing constructor with optional refImage load.
% - stitch( ['tileImage'] )%                    Perform transformation and overlay tile and ref image, 
%                                               optionally set the tile image in the same action.  
% % getters and setters
% - setRefImage( 'refImage' )
% - setTileImage( 'tileImage' )
% - setPoints( ptNr, coordinate, 'image', ['options'] )%     
%                                               Set the points correlating points of either 'ref' or 'tile',
%                                               the option 'fill' may also be used to load everything at once.
% - getRefImage()%                              Get the panorama image.
% - getTileImage()%                             Get the tile image which may or may not be transformed.
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%% properties %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - refIm%	Reference/panorama image.
% - refSize%	The actual size of the reference image instead of the canvas around it.
% - refPts%	Reference points correlating with the tile image.
% 
% - tileIm%	The image to transform and overlay the reference.
% - tilePts%	Points of the tile image which correlate to the reference points.
% 
% % boolean status variables
% - refOpened
% - tileOpened
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%% Events %%%%%%%%%%%%%%%%%%%%%%%%%
% - noImage             - if an action is attempted while no image is available.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%% Exceptions %%%%%%%%%%%%%%%%%%%%%%%%%
%
% incorrectSize       - Thrown if some specified property (image or point) is too large.



%% class definition
classdef Stitcher < handle
    
    %% Properties
    properties (Access = private)
        refIm%      Reference/panorama image.
        refSize%	The actual size of the reference image instead of the canvas around it.
        refPts%     Reference points correlating with the tile image.
        
        tileIm%     The image to transform and overlay the reference.
        tilePts%	Points of the tile image which correlate to the reference points.
        
        % boolean status variables
        refOpened
        tileOpened
    end% properties (private)
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Stitcher( filename )
            obj.refOpened = false;
            obj.tileOpened = false;
            
            if nargin == 1
                setRefImage( filename )
            end
        end% Stitcher constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setRefImage( obj, filename )
            
            % load image
            im = imread( filename );
            
            % check image size
            [r,c,d] = size( im );
            
            if( r> maxImSize() || c>maxImSize() )
                obj.refOpened = false;
                boundsException = MException('MYFUN:incorrectSize', 'too large image');
                throw( boundsException );
            end
            
            % make canvas
            obj.refIm = uint8( zeros( r*3, c*3,d ) );% make room for up to ~3 images initially
            obj.refIm(1:r,1:c,:) = im;
            
            % initialize points
            obj.refPts = zeros( 4, 3 );
            obj.refPts(:,3) = 1;
            obj.tilePts = obj.refPts;
            
            % store ref size within canvas
            obj.refSize = [ r,c,d ];
            
            obj.refOpened = true;
        end% setRefImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTileImage( obj, filename )
            
            % load image
            im = imread( filename );
            
            % check image size
            [r,c,d] = size( im );
            
            if( r> maxImSize() || c>maxImSize() )
                obj.refOpened = false;
                boundsException = MException('MYFUN:incorrectSize', 'too large image');
                throw( boundsException );
            end
            
            obj.tileIm = im;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setPoints( ptNr, coordinate, image, options )
            
            % set points based on options
            switch( image )
                case 'ref'
                    % CONTINUE
            
        end% setPoints
    end% methods
    
end% Stitcher class

%% helpers
function n = maxImSize() 
    n = 15000;
end


