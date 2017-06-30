% Triangulate corresponding points (n*3) with the camera matrices to retreive depth.
% There is a triangulate in the MATLAB toolbox but it does not normalize
% the data and is therefor useless.
function pts = triangulate2d( x, xp, Px, Pxp )

    % validate input
    [r,c] = size(x);
   
    if c<3% make homogeneous
        x = [x,ones(r,1)];
        xp = [xp,ones(r,1)];
    end
    

    % normalize
    if r<2
        [ x, Tx ] = normalize( x );
        [ xp, Txp ] = normalize( xp );
    else
        Tx = eye(3);
        Txp = Tx;
    end

    P1 = Tx*Px;
    P2 = Txp*Pxp;
    
    pts = zeros( r, 3 );
    
    for i=1:r
        A = [   x(i,1)*Px(3,:)-Px(1,:);...
                x(i,2)*Px(3,:)-Px(2,:);...
                xp(i,1)*Pxp(3,:)-Pxp(1,:);...
                xp(i,2)*Pxp(3,:)-Pxp(2,:)];
        [~,~,V] = svd( A );
        pt = V(:,end);
        pt = pt./pt(end);
        
        pts(i,:) = pt(1:3);
    end
    
end% triangulate2d