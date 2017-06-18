% finds the relationship between two frames given (min) 4 corresponding
% (homogeneous) points.
% The coordinates are passed as 1 row per point, where each row of s and p
% correspond to eachother.

function [H,offset] = homography( s, p, bbox )
    
    [r,c] = size(s);
    
    
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
    
    % if a bounding box is specified we will translate to positive values
    % thank you peter corke
    if nargin>2
        box = boundingBox( H, bbox );
        xmin = min( box(:,1) );
        ymin = min( box(:,2) );

        offset = floor( [ xmin, ymin] );
        
%         H = [   1   0   -offset(1);...
%                 0   1   -offset(2);...
%                 0   0   1]*H;
    else
        offset = [1,1];
    end
    
end% homography