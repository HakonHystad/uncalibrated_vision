% Affine 3D reconstruction

clear all
close all

%% config
showVanishingPts = true;

%% control points (hand picked)

cp1 = [...
        0.7775    0.3771;...
        1.1772    0.5064;...
        1.1707    0.7191;...
        0.7940    0.5679;...
        1.0710    0.1254;...
        1.2060    0.1479;...
        1.0267    0.2146;...
        0.8842    0.1831]*1000;
cp2 = [...
        0.7105    0.5779;...
        1.3027    0.6234;...
        1.2902    0.8516;...
        0.7297    0.8009;...
        0.9615    0.2439;...
        1.1407    0.2484;...
        1.1002    0.3444;...
        0.8902    0.3369]*1000;

%% load images
im1 = imread('images/block1.png');
im2 = imread('images/block2.png');


%% estimate the fundamental matrix and triangulate
epi = Epipolar(im1,im2);

%% find vanishing points from control points
cp1 = [ cp1, ones(length(cp1),1) ];
cp2 = [ cp2, ones(length(cp2),1) ];

% parallel lines im1
L1 = cross( cp1(1,:)',cp1(2,:)' );
L3 = cross( cp1(3,:)',cp1(4,:)' );
L2 = cross( cp1(2,:)',cp1(3,:)' );
L4 = cross( cp1(4,:)',cp1(1,:)' );
L5 = cross( cp1(8,:)',cp1(5,:)' );
L6 = cross( cp1(6,:)',cp1(7,:)' );
% vanishing points im1
v1 = zeros(3,3);
v1(1,:) = ( cross( L1,L3 ) )'; v1(1,:) = v1(1,:)./v1(1,3);
v1(2,:) = ( cross( L2,L4 ) )'; v1(2,:) = v1(2,:)./v1(2,3);
v1(3,:) = ( cross( L5,L6 ) )'; v1(3,:) = v1(3,:)./v1(3,3);

% parallel lines im2
L1 = cross( cp2(1,:)',cp2(2,:)' );
L2 = cross( cp2(2,:)',cp2(3,:)' );
L5 = cross( cp2(8,:)',cp2(5,:)' );
% vanishing points im2 compatible with the epipolar line from v1
v2 = zeros(3,3);
v2(1,:) = ( cross( L1,epi.F*v1(1,:)' ) )'; v2(1,:) = v2(1,:)./v2(1,3);
v2(2,:) = ( cross( L2,epi.F*v1(2,:)' ) )'; v2(2,:) = v2(2,:)./v2(2,3);
v2(3,:) = ( cross( L5,epi.F*v1(3,:)' ) )'; v2(3,:) = v2(3,:)./v2(3,3);

%% triangulate
epi.in1 = [ cp1;v1 ];
epi.in2 = [ cp2;v2 ];

worldPts = epi.triangulate('optimal');

worldPts = [ worldPts, ones( length(worldPts),1) ];% make homogeneous


%% show image with controlpoints
color = [   1   1   0;...
            1   0   1;...
            0   1   1;...
            1   0   0;...
            0   1   0;...
            0   0   1;...
            1   1   1;...
            0   0   0];
        
subplot(2,2,[1 2]);
imshow(im1);
hold on
plot2DShape( cp1(1:4,1:2), color(1:4,:) );
plot2DShape( cp1(5:8,1:2), color(5:8,:) );
hold off

%% show projective reconstruction (triangulation)
subplot(2,2,3);
hold on
plot3DShape( worldPts(1:4,1:3), color(1:4,:) ); 
plot3DShape( worldPts(5:8,1:3), color(5:8,:) );

if showVanishingPts
    plotVanishingPt( worldPts(9,:), [worldPts(1,1:3);worldPts(4,1:3)], 'r+' );% 1
    plotVanishingPt( worldPts(10,:), [worldPts(3,1:3);worldPts(4,1:3)], 'g+' );% 2
    plotVanishingPt( worldPts(11,:), [worldPts(5,1:3);worldPts(6,1:3)], 'b+' );% 3
end
hold off

%% Reconstruct Affine properties
v_1 = worldPts(end-2,1:3)';
v_2 = worldPts(end-1,1:3)';
v_3 = worldPts(end,1:3)';

plane = [   cross(v_1-v_3,v_2-v_3);...
            -v_3'*cross(v_1,v_2)   ]; plane = plane./plane(end);

% reconstructing homography
H = [   eye(3), [0;0;0];...
        plane' ];

worldPts = ( H*worldPts' )';

worldPts = worldPts(1:end-3,:)./repmat( worldPts(1:end-3,4),1,4 );% non-homogeneous

%% show reconstructed results
subplot(2,2,4);
hold on
plot3DShape( worldPts(1:4,1:3), color(1:4,:) ); 
plot3DShape( worldPts(5:8,1:3), color(5:8,:) );
hold off




%% functions
function plot2DShape( data, color )
    % sides
    plot( [data(:,1);data(1,1)],[data(:,2);data(1,2)],'g','LineWidth',2 );     
    % verticies
    scatter( data(:,1), data(:,2), [],color,'filled' );
end

function plot3DShape( data, color )
    % sides
    plot3( [data(:,1);data(1,1)],[data(:,2);data(1,2)],[data(:,3);data(1,3)],...
        'g','LineWidth',2 );
    % verticies
    scatter3( data(:,1), data(:,2), data(:,3), 30,color,'o','filled','MarkerEdgeColor','r');
end

function plotVanishingPt( pt, origins, marker )
    
    % points
    scatter3( pt(:,1), pt(:,2), pt(:,3), marker);
    % lines
    plot3(  [origins(1,1); pt(:,1); origins(2,1)],...
            [origins(1,2); pt(:,2); origins(2,2)],...
            [origins(1,3); pt(:,3); origins(2,3)],'--' );
   
end

