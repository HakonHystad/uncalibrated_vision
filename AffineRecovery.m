%% affine recovery class
% A child of the recovery class, uses a line at infinity to recover affine properties.
% Usage:
%         - getPointsAtInfinity()
%         - getTransformation()
        
%% class definition

classdef AffineRecovery < Recovery
    
    %% properties
    properties (SetAccess = private)
        ptsAtInf
        Ha
    end% properties
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function recover(obj)
            
            % Parallel L1&L3 intersect at xi1, Parallel L2&L4 intersect at xi2
            L1 = cross( obj.corners(1,:)', obj.corners(2,:)' );
            L2 = cross( obj.corners(2,:)', obj.corners(3,:)' ); 
            L3 = cross( obj.corners(4,:)', obj.corners(3,:)'); 
            L4 = cross( obj.corners(1,:)', obj.corners(4,:)'); 
            xi1 = cross(L1,L3);
            xi1 = xi1/xi1(3);% point at infinity
            xi2 = cross(L2,L4);
            xi2 = xi2/xi2(3);% point at infinity
            
            obj.ptsAtInf(1,:) = xi1';
            obj.ptsAtInf(2,:) = xi2';
            
            % line at infinity
            Li = cross(xi1,xi2);
            Li = Li/Li(3);

            % The homographic transform recovering the affine properties
            obj.Ha = [  1   0   0;...
                        0   1   0;...
                        Li'];
            tform = projective2d( obj.Ha' );
           
            
            % apply transformation
            if obj.imageOpened
                obj.recoveredImage = imwarp( obj.image, tform );
                obj.recovered = true;
            else
                notify(obj,'noImage');
            end

        end% recovery
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getPointsAtInfinity(obj)
            pts = obj.ptsAtInf;
        end% getPointsAtInfinity
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function T = getTransformation(obj)
            T = obj.Ha;
        end% getTransformation
        
    end% methods
end% AffineRecovery