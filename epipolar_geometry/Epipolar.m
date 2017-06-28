%% Epipolar - a base class for holding the epipolar geometric information shared by two images. 
%
% %%%%%%%%%%%%%%%%%%METHODS%%%%%%%%%%%%%%%%%%%%%%
% Epipolar( im1, im2 )		- Constructor, estimates the fundamental matrix
% and other epipolar properties.
% plotEpiLine(option, n)		- Plots n epipolar line of image <1 or 2>
% plotEpiPole(option)		- Plots the epipole of image <1 or 2>
% plotInlierFeatures(option, n)	- Plots n inliers of image <1 or 2> 
% 
% 
% %%%%%%%%%%%%%%%%%%PROPERTIES%%%%%%%%%%%%%%%%%%%%%%
% 
%         im1%    image 1
%         im2%    image 2
%         
%         F%      estimated fundamental matrix
%         
%         eP1%    epipole of image 1 (image of camera center 2)
%         eP2%    epipole 2          (image of camera center 1)
%         eL1%    epipolar line 1    (lines in image 1 due to points in 2)
%         eL2%    epipolar line 2    (lines in image 2 due to points in 1) 
%         
%         in1%    inliers of corresponding points in image 1 
%         in2%    inliers of corresponding points in image 2

%% class definition

classdef Epipolar < handle
    
    %% Properties
    properties
        im1%    image 1
        im2%    image 2
        
        F%      estimated fundamental matrix
        
        eP1%    epipole of image 1 (image of camera center 2)
        eP2%    epipole 2          (image of camera center 1)
        eL1%    epipolar line 1    (lines in image 1 due to points in 2)
        eL2%    epipolar line 2    (lines in image 2 due to points in 1) 
        
        in1%    inliers of corresponding points in image 1 
        in2%    inliers of corresponding points in image 2
        
    end% properties
    
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Epipolar( im1, im2 )% Constructor
            obj.im1 = im1;
            obj.im2 = im2;
            
            % estimate the fundamental matrix 
            [obj.F,obj.in1, obj.in2] = extractF(im1,im2);
            
            % calculate epipolar lines
            % of image 1 due to points in image 2
            obj.eL1 = epipolarLine( obj.F', obj.in2 );
            % of image 2 due to points in image 1
            obj.eL2 = epipolarLine( obj.F, obj.in1 );
            
            % calculate epipoles
            % of image 1 due to camera center in image 2 (right nullspace)
            obj.eP1 = null(obj.F);
            obj.eP1 = obj.eP1./obj.eP1(3);
            % of image 2 due to camera center in image 1 (left nullspace)
            obj.eP2 = null(obj.F');
            obj.eP2 = obj.eP2./obj.eP2(3);

        end% Epipolar constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotEpiLine( obj, imOption, nr )
            
            if nargin<=2
                nr = length( obj.eL1 );
            elseif nr>length( obj.eL1 )
                error('Too many lines requested\n');
            end
             
            switch imOption
                case 1
                    plottablePts1 = lineToBorderPoints( obj.eL1(1:nr,:), size( obj.im1 ) );
                    line( plottablePts1( :,[1,3] )', plottablePts1(:,[2,4])', 'Color','cyan');
                case 2
                    plottablePts2 = lineToBorderPoints( obj.eL2(1:nr,:), size( obj.im2 ) );
                    line( plottablePts2( :,[1,3] )', plottablePts2(:,[2,4])', 'Color','cyan');
                otherwise
                    error('Not a valid option\n');
            end
        end% plotEpiLines
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotEpiPole( obj, imOption )
            switch imOption
                case 1
                    plot( obj.eP1(1), obj.eP1(2), 'gs' );
                case 2
                    plot( obj.eP2(1), obj.eP2(2), 'gs' );
                otherwise
                    error('Not a valid option\n');
            end
        end% plotEpiPole
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotInlierFeatures( obj, imOption, nr )
            
            if nargin<=2
                nr = length( obj.in1 );
            elseif nr>length( obj.in1 )
                error('Too many points requested\n');
            end
            
            switch imOption
                case 1
                    plot( obj.in1(1:nr,1), obj.in1(1:nr,2),'go' );
                    plot( obj.in1(1:nr,1), obj.in1(1:nr,2),'g+' );
                case 2
                    plot( obj.in2(1:nr,1), obj.in2(1:nr,2),'go' );
                    plot( obj.in2(1:nr,1), obj.in2(1:nr,2),'g+' );
                otherwise
                    warning('Not a valid option\n');
            end
                    
        end% plotInlierFeatures
        
    end% methods
    
    
end% Epipolar