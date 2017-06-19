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
            
            % initialize points
            obj.refPts = zeros( 4, 3 );
            obj.refPts(:,3) = 1;
            obj.tilePts = obj.refPts;
            
            if nargin == 1
                obj.setRefImage( filename )
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
            
            % store ref size within canvas
            obj.refSize = [ r,c,d ];
            
            obj.refOpened = true;
        end% setRefImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTileImage( obj, filename )
            
            % load image
            im = imread( filename );
            
            % check image size
            [r,c,~] = size( im );
            
            if( r> maxImSize() || c>maxImSize() )
                obj.tileOpened = false;
                boundsException = MException('MYFUN:incorrectSize', 'too large image');
                throw( boundsException );
            end
            
            obj.tileIm = im;
            obj.tileOpened = true;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setPoints( obj, ptNr, coordinate, imageId, options )
           
            % set points based on options
            switch( imageId )
                case 'ref'
                    
                    if ( nargin>4 && options == 'fill' )% replace matrix
                        obj.refPts = [ coordinate, 1 ];
                    elseif ptNr<=4% or insert
                        obj.refPts( ptNr, 1:2 ) = coordinate(1:2);
                    end
                    
                case 'tile'
                    
                    if ( nargin>4 && options == 'fill' )% replace matrix
                        obj.tilePts = [ coordinate, 1 ];
                    elseif ptNr<=4% or insert
                        obj.tilePts( ptNr, 1:2 ) = coordinate(1:2);
                    end
                    
                otherwise
                    error( 'ERROR @ setPoints(): Not a valid option' )
            end% switch image
            
        end% setPoints
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getRefImage(obj)
            im = obj.refIm( 1:obj.refSize(1), 1:obj.refSize(2), : );
        end% getRefImage()
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getTileImage(obj)
            im = obj.tileIm;
        end% getTileImage
        
        function stitch( obj, varargin )
            
            % set image if this option is used ('tile','tileImage')
            if ( nargin>2 && strcmp( varargin{1},'tile' ) )
                obj.setTileImage( varargin{2} );
            end
            
            % no point in going further without both images
            if ( ~obj.refOpened || ~obj.tileOpened ) 
                error( 'ERROR @ stitch(): missing image' )
            end
            
            % calc homography, offset is foud with respect to ref ([1,1])
            [r, c, ~] = size( obj.tileIm );
            [H,offset] = homography( obj.refPts, obj.tilePts, [r,c] );
            
            if  ( any(isnan( H(:) )) || any( abs(offset)>[maxImSize(),maxImSize()] ) )
                error('ERROR @ stitch(): No valid homography');
                return;
            end
            
            % apply transformation
            tform = projective2d( H' );
            obj.tileIm = imwarp( obj.tileIm, tform );
            obj.tileOpened = false;% this image is used up
            
            % check the offsets and if negative shift the image accordingly
            [r,c,~] = size( obj.tileIm );
            for i = 1:2
                if offset(i)<1
                    if i == 1% col
                        % shift to the left
                        obj.tileIm = circshift( obj.tileIm, offset(i),2 );
                        % delete the stuff that wrapped around
                        obj.tileIm(:,c+offset(i):c,:) = [];
                    elseif i == 2% row
                        % shift up
                        obj.tileIm = circshift( obj.tileIm, offset(i),1 );
                        % delete the stuff that wrapped around
                        obj.tileIm(r+offset(i):r,:,:) = [];
                    end
                    
                    offset(i) = 1;% rm negative offset
                end% if neg offset
            end% for i
            
            % get the new size
            [r,c,~] = size( obj.tileIm );
            % and find the position to place the transformed image on the canvas
            pos = [   offset(2),offset(2)+r-1;...% row limits
                      offset(1),offset(1)+c-1];% col limits
                  
            % expand canvas if neccessary
            [canvasR, canvasC, canvasD] = size( obj.refIm );
            if pos(1,2)>canvasR
                % add rows
                expansion = uint8( zeros( pos(1,2), canvasC, canvasD ) );
                obj.refIm = [ obj.refIm; expansion ];
                [canvasR, canvasC, canvasD] = size( obj.refIm );% update size
            end
            
            if pos(2,2)>canvasC
                % add columns
                expansion = uint8( zeros( canvasR, pos(2,2), canvasD ) );
                obj.refIm = [ obj.refIm, expansion ];
            end
            
                  
            % update image size within canvas
            obj.refSize(1:2) = [ max(obj.refSize(1),pos(1,2)),max(obj.refSize(2),pos(2,2))];
            
            % merge it with the preferred option
            arg = '';
            if( nargin>3 ) 
                arg = varargin{3};
            elseif( nargin == 2 )
                arg = varargin{1};
            end
            
            switch( arg )
                case 'insert'% replace the pixels if>0, NB: takes a long time
                
                    for i = 1:r
                        for j = 1:c
                            offs = [offset(2)-1+i,offset(1)-1+j ];
                            if any( obj.tileIm(i,j,:) )% if non-black pixel->replace
                                obj.refIm( offs(1),offs(2),:) = obj.tileIm(i,j,:);
                            end
                        end
                    end
                    
                    %%%%%%%%%%%%%%
                otherwise% default is adding in the tile making the overlapping pixels brighter
                    obj.refIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2),: ) = ...
                        obj.refIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2), : ) + obj.tileIm;
            end% switch arg
             
        end% stitch
        
        
    end% methods
    
end% Stitcher class

%% helpers
function n = maxImSize() 
    n = 15000;
end


