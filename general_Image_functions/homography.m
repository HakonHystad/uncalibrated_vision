% finds the relationship between two frames given (min) 4 corresponding
% (homogeneous) points.
% The coordinates are passed as 1 row per point, where each row of s and p
% correspond to eachother.

function H = homography( s, p )
    
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
end% homography