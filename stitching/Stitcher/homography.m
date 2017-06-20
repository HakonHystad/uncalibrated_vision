% Homography - finds the relationship between two frames given (min) 4 corresponding
% (homogeneous) points.
% The coordinates are passed as 1 row per point, where each row of s and p
% correspond to eachother.
% optional bbox is 2 points which defines the size of a rectangle.

function [H,offset] = homography( s, p, bbox, varargin )
    
    [r,c] = size(s);
    
    % validate input, should prob do the same for p..
    if ( r<4 || c < 3 )
        error( 'ERROR @ homography(): Not enough points.' );
    end
    
    if ( nargin>3 && strcmp( varargin{1}, 'ransac' ) )
        nargs = length( varargin );
        if nargs>0
            H = homographyRANSAC(s,p, varargin{2:nargs});
        else
            H = homographyRANSAC(s,p);
        end
    else
        
        A = zeros( r*3, c*3 );
        
        j = 1;
        for i = 1:3:(r*3-2)
            s_skew = Skew( s(j,:)' );
            A( i:i+2, : ) = [  p(j,1)*s_skew     p(j,2)*s_skew     p(j,3)*s_skew     ];
            j = j+1;
        end% i
        
        
        [~, ~ , v] = svd(A);
        
        h = v(:,9);
        h = h/h(9);% normalize
        
        H = [ h(1:3)    h(4:6)  h(7:9)  ];
    end% if ransac
        
    % if a bounding box is specified we will calc the offset from [1,1]
    % - thank you peter corke
    if nargin>2
        % transform the bounding box according to H
        box = boundingBox( H, bbox );
        % find the offset
        xmin = min( box(:,1) );
        ymin = min( box(:,2) );

        offset = floor( [ xmin, ymin] );
%         
%         H = [   1   0   -offset(1);...
%                 0   1   -offset(2);...
%                 0   0   1]*H;
    else% no offset
        offset = [1,1];
    end
    
end% homography