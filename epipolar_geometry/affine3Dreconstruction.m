% Affine 3D reconstruction

clear all
close all

sampleIx =[...
    0.6360    0.6549;...
    1.2225    0.5724;...
    1.7173    0.7457;...
    0.9502    0.9331;...
    0.9292    0.5424;...
    0.9232    0.1336;...
    1.2308    0.1306;...
    1.2225    0.5454]*1000;


sampleIxp =[...
    0.7687    0.6121;...
    1.3747    0.6429;...
    1.4145    0.8904;...
    0.4710    0.8251;...
    1.1947    0.5754;...
    1.2082    0.1831;...
    1.4730    0.1771;...
    1.4445    0.6234]*1000;


%% load images
imx = imread('images/table1a.jpg');
imxp = imread('images/table2a.jpg');


%% estimate the fundamental matrix and triangulate
epi = Epipolar(imx,imxp);

%% find vanishing points
sampleIx = [ sampleIx, ones( length(sampleIx), 1) ];
% make lines
L1 = cross( sampleIx(1,1:3)', sampleIx(2,1:3)' );
L2 = cross( sampleIx(2,1:3)', sampleIx(3,1:3)' );
L3 = cross( sampleIx(3,1:3)', sampleIx(4,1:3)' );
L4 = cross( sampleIx(4,1:3)', sampleIx(1,1:3)' );
L5 = cross( sampleIx(5,1:3)', sampleIx(8,1:3)' );
L6 = cross( sampleIx(6,1:3)', sampleIx(7,1:3)' );
% find the vanishing points (parallel line intersections)
v1 = cross( L1,L3 ); v1 = v1./v1(end);
v2 = cross( L2,L4 ); v2 = v2./v2(end);
v3 = cross( L5,L6 ); v3 = v3./v3(end);

% find the vanishing points in image 2

sampleIxp = [ sampleIxp, ones( length(sampleIxp), 1) ];
L1 = cross( sampleIxp(1,1:3)', sampleIxp(2,1:3)' );
L2 = cross( sampleIxp(3,1:3)', sampleIxp(2,1:3)' );
L5 = cross( sampleIxp(5,1:3)', sampleIxp(8,1:3)' );
v1p = cross( L1, epi.F*v1 ); v1p = v1p./v1p(end);
v2p = cross( L2, epi.F*v2 ); v2p = v2p./v2p(end);
v3p = cross( L5, epi.F*v3 ); v3p = v3p./v3p(end);

%% triangulate

epi.in1 = [sampleIx;v1';v2';v3'];
epi.in2 = [sampleIxp;v1p';v2p';v3p'];

worldPts = epi.triangulate('optimal');

worldPts = [ worldPts, ones( length(worldPts),1) ];% make homogeneous

len = length( worldPts ) - 3;
subplot(2,2,[1 2]);
imshow(imx);
color = [   1   1   0;...
            1   0   1;...
            0   1   1;...
            1   0   0;...
            0   1   0;...
            0   0   1;...
            1   1   1;...
            0   0   0];
hold on
plot( [epi.in1(1:4,1);epi.in1(1,1)],[epi.in1(1:4,2);epi.in1(1,2)],'g','LineWidth',2 );
plot( [epi.in1(5:8,1);epi.in1(5,1)],[epi.in1(5:8,2);epi.in1(5,2)],'g','LineWidth',2 );
scatter( epi.in1(1:8,1), epi.in1(1:8,2), [],color,'filled' );
hold off
% projective reconstructed
subplot(2,2,3);
scatter3( worldPts(1:len,1), worldPts(1:len,2), worldPts(1:len,3), 30,color,'o','filled','MarkerEdgeColor','r');
hold on
plot3( [worldPts(1:4,1);worldPts(1,1)],[worldPts(1:4,2);worldPts(1,2)],[worldPts(1:4,3);worldPts(1,3)],...
        'g','LineWidth',2 );
plot3( [worldPts(5:8,1);worldPts(5,1)],[worldPts(5:8,2);worldPts(5,2)],[worldPts(5:8,3);worldPts(5,3)],...
        'g','LineWidth',2 );
hold off

%% affine recovery
% calc plane at infinity
v1 = worldPts(end-2,1:3)';
v2 = worldPts(end-1,1:3)';
v3 = worldPts(end,1:3)';

plane = [   cross(v1-v3,v2-v3);...
            -v3'*cross(v1,v2)   ];
% reconstructing homography
H = [   eye(3), [0;0;0];...
        plane' ];
    
worldPts = ( H*worldPts' )';
worldPts = worldPts(1:len,1:3)./[ worldPts(1:len,4), worldPts(1:len,4), worldPts(1:len,4) ];
% affine reconstructed
subplot(2,2,4);
scatter3( worldPts(1:len,1), worldPts(1:len,2), worldPts(1:len,3), 30,color,'o','filled','MarkerEdgeColor','r');
hold on
plot3( [worldPts(1:4,1);worldPts(1,1)],[worldPts(1:4,2);worldPts(1,2)],[worldPts(1:4,3);worldPts(1,3)],...
        'g','LineWidth',2 );
plot3( [worldPts(5:8,1);worldPts(5,1)],[worldPts(5:8,2);worldPts(5,2)],[worldPts(5:8,3);worldPts(5,3)],...
        'g','LineWidth',2 );
hold off

