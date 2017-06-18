%% stitching class
% 
% Usage:
%         - (filePath):                 Constructor which (optionally) imports the image. 
%         - setRefPoints( ptNr, coordinate ):  Sets the specified points of a rectangle (pre projection) as [u,v].
%         - getRefPoints():                       Returns all the setRefPointss.
%         - stitch():                          Initiate stitchy.
%         - getTileImage():                Returns a copy of the stitching image if neccessary points are specified.
%         - getRefImage():                         Returns a copy of the original image.
%         - setRefImage(filePath):                 Reads the specified image for further use.
% Events:
%         - noImage:          Triggers if stitch or getRefImage is called when no image has been specified.
% Exceptions:
%         - sizeException:    Fires if the loaded image is too large, thrown by the image setters and stitch().
%% class definition

classdef Mosaic < handle
    
    %% properties
    properties (Access = private)
        imRef%          The refrence image
        ptsRef%         Correlating points in refrence image
        
        imTile%         The image to be stitched in
        ptsTile%        Correlating points in tile image
        
        panoramaIm%     the composite image that is built on
        panoramaSize%   The true size of the image, excluding fillers
        firstRef%       Bool to set the panorama image size at first use
        
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
        function obj = Mosaic( refImageFile )% Constructor
            obj.ptsRef = zeros(4,3);
            obj.ptsRef(:,3) = 1;
            obj.ptsTile = zeros(4,3);
            obj.ptsTile(:,3) = 1;
            
            obj.refOpened = false;
            obj.tileOpened = false;
            obj.firstRef = true;
            
            if nargin > 0
                setRefImage( obj,refImageFile );
            end
        end% stitchy
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setRefPoints( obj, ptNr, coordinate )
            if ptNr>0 && ptNr<=4
                obj.ptsRef( ptNr, 1:2 ) = coordinate;
            end
        end% setPoint
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getRefPoints(obj)
            pts = obj.ptsRef;
        end% getRefPoints
               
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTilePoints( obj, ptNr, coordinate )
            if ptNr>0 && ptNr<=4
                obj.ptsTile( ptNr, 1:2 ) = coordinate;
            end
        end% setPoint
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getTilePoints(obj)
            pts = obj.ptsTile;
        end% getRefPoints
               
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
            im = obj.panoramaIm( 1:obj.panoramaSize(1), 1:obj.panoramaSize(2), : );
            
        end% getPanoramaImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setRefImage( obj, filePath )
            obj.imRef = imread( filePath );
            
            [r,c,d] = size( obj.imRef );
            
            if r>15000 || c>15000
                obj.refOpened = false;
                sizeException = MException('MYFUN:incorrectSize', 'too large image');
                throw( sizeException );
            end
            
            if obj.firstRef
                obj.panoramaIm = uint8( zeros( r*3, c*3,d ) );% make room for up to ~3 images
                
                obj.panoramaIm(1:r,1:c,:) = obj.imRef;
                
                obj.panoramaSize = [ r,c,d ];
                obj.firstRef = false;
            end
            
            obj.refOpened = true;
        end% setImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTileImage( obj, filePath )
            obj.imTile = imread( filePath );
            
            [r,c,d] = size( obj.imTile );
            
            if r>15000 || c>15000
                obj.tileOpened = false;
                sizeException = MException('MYFUN:incorrectSize', 'too large image');
                throw( sizeException );
            end
            
            obj.tileOpened = true;
            
        end% setImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function stitch(obj, tileIm)
            
            if nargin > 1
                [r,c,d] = size( tileIm );
                
                if r>15000 || c>15000
                    obj.tileOpened = false;
                    sizeException = MException('MYFUN:incorrectSize', 'too large image');
                    throw( sizeException );
                    
                end
                obj.imTile = tileIm;
                obj.tileOpened = true;
            end
            
            % calculate homography and make sure it makes points within the
            % image, get the offset with refrence to the original image
            [rp, cp,d] = size( obj.imTile );
            [H,offset] = homography( obj.ptsRef, obj.ptsTile, [rp,cp] );
            

            
            if  any(isnan( H(:) ) )
                disp('No valid homography')
                return;
            end
            
            tform = projective2d( H' );
            
            
            % apply transformation
            if obj.tileOpened
                obj.imTile = imwarp( obj.imTile, tform );
                obj.tileOpened = false;
            else
                notify(obj,'noImage');
                return;
            end
            
            for i = 1:2
                if offset(i)<1
                    [r,c,~] = size( obj.imTile );
                    
                    % delete the shifted rows or columns
                    if i == 1
                        % shift up
                        obj.imTile = circshift( obj.imTile, offset(i),2 );%-150..
                        obj.imTile(:,c+offset(i):c,:) = [];
                    elseif i == 2
                        % shift up
                        obj.imTile = circshift( obj.imTile, offset(i),1 );%-150..
                        obj.imTile(r+offset(i):r,:,:) = [];
                    end
                    
                    offset(i) = 1;
                end
            end
            
            
            % overlay tile image on panorama
            [ rt,ct,d] = size( obj.imTile );
            pos = [   offset(2),offset(2)+rt-1;...
                      offset(1),offset(1)+ct-1];
            % something weird happens when removing the unused variable d..
            obj.panoramaIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2),: ) = ...
                obj.panoramaIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2),: ) + obj.imTile;
            
            obj.panoramaSize(1:2) = [ max(obj.panoramaSize(1),pos(1,2)),max(obj.panoramaSize(2),pos(2,2))];% 
            %obj.panoramaSize(2) = max(obj.panoramaSize(2),pos(2,2));
            
%             for i = 1:rt
%                 for j = 1:ct
%                     offs = [offset(2)-1+i,offset(1)-1+j ];
%                     if ( offs(1)>1 && offs(2)>1 )
%                         if any( obj.imTile(i,j,:) )% if non-black pixel->replace
%                             obj.panoramaIm( offs(1),offs(2),:) = obj.imTile(i,j,:);
%                         end
%                     end
%                 end
%             end
            
        end% stitch

     end% methods
    
  
    
end% stitchy

   