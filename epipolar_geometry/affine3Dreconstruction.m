% Affine 3D reconstruction

clear all
close all

alt = true;

sampleIx =[...
    0.6405    0.6564;...
    1.2255    0.5709;...
    1.7160    0.7434;...
    0.9480    0.9294;...
    0.9292    0.5424;...
    0.9232    0.1336;...
    1.2308    0.1306;...
    1.2225    0.5454]*1000;


sampleIxp =[...
    0.7695    0.6084;...
    1.3775    0.6439;...
    1.4150    0.8890;...
    0.4735    0.8214;...
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
if ~alt
    L1 = cross( sampleIx(1,:)', sampleIx(2,:)' );
    L3 = cross( sampleIx(3,:)', sampleIx(4,:)' );
else
    L1 = cross( sampleIx(5,:)', sampleIx(6,:)' );
    L3 = cross( sampleIx(7,:)', sampleIx(8,:)' );
end
L2 = cross( sampleIx(2,:)', sampleIx(3,:)' );
L4 = cross( sampleIx(4,:)', sampleIx(1,:)' );
L5 = cross( sampleIx(5,:)', sampleIx(8,:)' );
L6 = cross( sampleIx(6,:)', sampleIx(7,:)' );
% find the vanishing points (parallel line intersections)
v1 = cross( L1,L3 ); v1 = v1./v1(end);
v2 = cross( L2,L4 ); v2 = v2./v2(end);
v3 = cross( L5,L6 ); v3 = v3./v3(end);

% find the vanishing points in image 2

sampleIxp = [ sampleIxp, ones( length(sampleIxp), 1) ];
if ~alt
    L1p = cross( sampleIxp(1,:)', sampleIxp(2,:)' );
    % L3p = cross( sampleIxp(3,:)', sampleIxp(4,:)' );

else
    L1p = cross( sampleIxp(5,:)', sampleIxp(6,:)' );
    % L3p = cross( sampleIxp(7,:)', sampleIxp(8,:)' );
end
L2p = cross( sampleIxp(2,:)', sampleIxp(3,:)' );
% L4p = cross( sampleIxp(4,:)', sampleIxp(1,:)' );
L5p = cross( sampleIxp(5,:)', sampleIxp(8,:)' );
% L6p = cross( sampleIxp(6,:)', sampleIxp(7,:)' );

v1p = cross( L1p, epi.F*v1 ); v1p = v1p./v1p(end);
v2p = cross( L2p, epi.F*v2 ); v2p = v2p./v2p(end);
v3p = cross( L5p, epi.F*v3 ); v3p = v3p./v3p(end);
% v1p = cross( L1p,L3p ); v1p = v1p./v1p(end);
% v2p = cross( L2p,L4p ); v2p = v2p./v2p(end);
% v3p = cross( L5p,L6p ); v3p = v3p./v3p(end);


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
% image points and rectangle
plot( [epi.in1(1:4,1);epi.in1(1,1)],[epi.in1(1:4,2);epi.in1(1,2)],'g','LineWidth',2 );
plot( [epi.in1(5:8,1);epi.in1(5,1)],[epi.in1(5:8,2);epi.in1(5,2)],'g','LineWidth',2 );
scatter( epi.in1(1:8,1), epi.in1(1:8,2), [],color,'filled' );
hold off
% projective reconstructed
subplot(2,2,3);
scatter3( worldPts(1:len,1), worldPts(1:len,2), worldPts(1:len,3), 30,color,'o','filled','MarkerEdgeColor','r');
hold on
% vanishing points
% scatter3( worldPts(end-2:end,1), worldPts(end-2:end,2), worldPts(end-2:end,3),'r+');
% if ~alt
%     plot3( [worldPts(4,1);worldPts(end-2,1);worldPts(1,1)], [worldPts(4,2);worldPts(end-2,2);worldPts(1,2)],...
%             [worldPts(4,3);worldPts(end-2,3);worldPts(1,3)],'--' );
% else
%     plot3( [worldPts(6,1);worldPts(end-2,1);worldPts(7,1)], [worldPts(6,2);worldPts(end-2,2);worldPts(7,2)],...
%             [worldPts(6,3);worldPts(end-2,3);worldPts(7,3)],'--' );
% end
% plot3( [worldPts(2,1);worldPts(end-1,1);worldPts(1,1)], [worldPts(2,2);worldPts(end-1,2);worldPts(1,2)],...
%         [worldPts(2,3);worldPts(end-1,3);worldPts(1,3)],'--' );
% plot3( [worldPts(5,1);worldPts(end,1);worldPts(6,1)], [worldPts(5,2);worldPts(end,2);worldPts(6,2)],...
%         [worldPts(5,3);worldPts(end,3);worldPts(6,3)],'--' );

% rectangles
plot3( [worldPts(1:4,1);worldPts(1,1)],[worldPts(1:4,2);worldPts(1,2)],[worldPts(1:4,3);worldPts(1,3)],...
        'g','LineWidth',2 );
plot3( [worldPts(5:8,1);worldPts(5,1)],[worldPts(5:8,2);worldPts(5,2)],[worldPts(5:8,3);worldPts(5,3)],...
        'g','LineWidth',2 );
hold off

%% affine recovery
% calc plane at infinity
v_1 = worldPts(end-2,1:3)';
v_2 = worldPts(end-1,1:3)';
v_3 = worldPts(end,1:3)';

plane = [   cross(v_1-v_3,v_2-v_3);...
            -v_3'*cross(v_1,v_2)   ];
plane = plane./plane(end);

% reconstructing homography
H = [   eye(3), [0;0;0];...
        plane' ];

worldPts = ( H*worldPts' )';

worldPts = worldPts(1:len,:)./repmat( worldPts(1:len,4),1,4 );

% affine reconstructed
subplot(2,2,4);
scatter3( worldPts(1:len,1), worldPts(1:len,2), worldPts(1:len,3), 30,color,'o','filled','MarkerEdgeColor','r');
hold on
plot3( [worldPts(1:4,1);worldPts(1,1)],[worldPts(1:4,2);worldPts(1,2)],[worldPts(1:4,3);worldPts(1,3)],...
        'g','LineWidth',2 );
plot3( [worldPts(5:8,1);worldPts(5,1)],[worldPts(5:8,2);worldPts(5,2)],[worldPts(5:8,3);worldPts(5,3)],...
        'g','LineWidth',2 );
hold off

