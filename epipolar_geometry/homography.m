% Homography - finds the relationship between two frames given (min) 4 corresponding
% (homogeneous) points.
% The coordinates are passed as 1 row per point, where each row of s and p
% correspond to eachother.

function H = homography( s, p )
    [r,c] = size(s); 
 
    [s,Ts] = normalize(s);
    [p,Tp] = normalize(p);
    
    % validate input, should prob do the same for p..
    if ( r<4 || c < 3 )
        error( 'ERROR @ homography(): Not enough points.' );
    end
    
    A = zeros( r*3, c*3 );
    
    j = 1;
    for i = 1:3:(r*3-2)
        s_skew = Skew( s(j,:)' );
        A( i:i+2, : ) = [  p(j,1)*s_skew     p(j,2)*s_skew     p(j,3)*s_skew     ];
        j = j+1;
    end% i
    
    
    [~, ~ , v] = svd(A);
    
    h = v(:,9);
    h = h/h(9);
    
    H = [ h(1:3)    h(4:6)  h(7:9)  ];
    
    H = Ts\H*Tp;
    H = H./H(3,3);
        
    
end% homography