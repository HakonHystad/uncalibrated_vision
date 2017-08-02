% Rectify: a class for doing epipolar rectification and perform dense stereomatching

%% class definition
classdef Rectify < handle
    
    %% properties
    properties
        epi;        % obj.epipolar properties
        
        rectIm1;    % the first rectified image
        rectIm2;    % the second rectified image
        
        pts1;       % matched points of image 1
        pts2;       % mathced points of image 2
        
        H1;         % rectifycation homography of image 1
        H2;         % rectifycation homography of image 2 
        
        rectStatus; % bool successful rectification
        disparityMap;   % disparity map after dense stereo matching
        
    end% properties
    
    %% methods
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj,status] = Rectify( im1, im2 )
            obj.epi = Epipolar( im1, im2 );
            status = rectify( obj, im1, im2 );
        end% Rectify constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function status = rectify( obj, im1, im2 )% Mallon rectification
            obj.rectStatus = false;
            status = false;
            %% find initial rectification matrices
            obj.H1 = [   1                              0       0;...
                    -obj.epi.eP1(2)/obj.epi.eP1(1)  1       0;...
                    -1/obj.epi.eP1(1)               0       1];

            % use whole F (overconstrained) to calculate obj.H2 for less distortion
            A = [   -1             0            0       0            0            0;...
                    0              -1           0       0            0            0;...
                    0              0           -1       0            0            0;...
                    0              0            0       1            0            0;...
                    0              0            0       0            1            0;...
                    0              0            0       0            0            1;...
                    -obj.H1(3,1)   0            0       obj.H1(2,1)  0            0;...
                    0              -obj.H1(3,1) 0       0            obj.H1(2,1)  0;...
                    0               0      -obj.H1(3,1) 0            0             obj.H1(2,1)];
            b = [   obj.epi.F(1,3);...
                    obj.epi.F(2,3);...
                    obj.epi.F(3,3);...
                    obj.epi.F(1,2);...
                    obj.epi.F(2,2);...
                    obj.epi.F(3,2);...
                    obj.epi.F(1,1);...
                    obj.epi.F(2,1);...
                    obj.epi.F(3,1)];
            x = (A'*A)\(A'*b);% least square

            obj.H2 = [  1       0   0;...
                        x(1:3)';...
                        x(4:6)'];

            % use Jacobian of corners to minimize distortion
            [r,c,~] = size( im1 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            obj.H1 = minimizeDistortion( obj.H1, pts, 0 );
            [r,c,~] = size( im2 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            obj.H2 = minimizeDistortion( obj.H2, pts, 0 );

            
            [obj.rectIm1, obj.rectIm2] = rectifyImages( im1, im2, obj.H1, obj.H2 );
            
            if ~isempty( obj.rectIm1 ) && ~isempty( obj.rectIm2 )
                status = true;
                obj.rectStatus = true;
            end
        end% rectify
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [disparityMap,disparityRange] = calcDisparity(obj, varargin)
            
            if obj.rectStatus
                % check input args
                noRangeGiven = true;
                for i=1:length(varargin)
                    if strcmp( varargin{i}, 'DisparityRange')
                        disparityRange = varargin{i+1};
                        noRangeGiven = false;
                        break;
                    end
                end
                        
                if noRangeGiven
                    % estimate ca disparity range from inliers
                    diff = abs( obj.epi.in1(:,1) - obj.epi.in2(:,1) );
                    maxDiff = max( diff );
                    
                    maxDiff = ceil(maxDiff);
                    remainder = mod(maxDiff,16);
                    maxDiff = maxDiff + (16-remainder);% make a multiple of 16
                    disparityRange = [ 0 maxDiff ];
                    
                    disparityMap = disparity( rgb2gray(obj.rectIm1), rgb2gray(obj.rectIm2),...
                                                'DisparityRange', disparityRange, varargin{:});
                
                else
                    disparityMap = disparity( rgb2gray(obj.rectIm1), rgb2gray(obj.rectIm2), varargin{:});
                end% noRangeGiven
                
                obj.disparityMap = disparityMap;
            else
                disp('Perform rectification first')
                disparityMap = [];
            end
            
        end% disparity
        
    end% methods
    
end% Rectify classdef




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [im1, im2] = rectifyImages( I1, I2, H1, H2 )
    % find common transformed area
    [r,c,~] = size(I1);
    corners1 = transformCorners( H1, r,c );
    [r,c,~] = size(I2);
    corners2 = transformCorners( H2, r,c );
    
    corners = [ corners1;corners2 ];
    x = sort( corners(:,1) );
    y = sort( corners(:,2) );
    
    xmin = ceil( x(4) );
    xmax = floor( x(5) );
    ymin = ceil( y(4) );
    ymax = floor( y(5) );
    
    width = xmax-xmin;
    height = ymax-ymin;
    
    if width<=1 || height<=1
         disp('Bad rectification');
         im1 = [];
         im2 = [];
         return;
    end
    
    xLim = [ xmin-0.5,xmax+0.5 ];
    yLim = [ ymin-0.5,ymax+0.5 ];
    
    tform1 = projective2d( H1' );
    tform2 = projective2d( H2' );
    
    outputView = imref2d([height-1, width-1], xLim, yLim);
     
    im1 = imwarp(I1, tform1, 'OutputView', outputView );
    im2 = imwarp(I2, tform2, 'Outputview', outputView );
end

function corners = transformCorners( H,r,c )
    
    a = [ [1 1 1]', [c 1 1]', [c r 1]', [1 r 1]' ];   
    a = H*a;
    a = a./repmat(a(3,:),3,1);
    
    corners = [ a(1:2,1)';a(1:2,2)';a(1:2,3)';a(1:2,4)';];% start upper left CCW around
    
end