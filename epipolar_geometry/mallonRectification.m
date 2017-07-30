im1 = imread('images/table1a.jpg');
im2 = imread('images/table2a.jpg');


%% estimate fundamental matrix
epi = Epipolar( im1, im2 );

%% find initial rectification matrices
H = [   1                       0       0;...
        -epi.eP1(2)/epi.eP1(1)  1       0;...
        -1/epi.eP1(1)       0       1];
  
B = [   -1      0       0       0      0       0       -epi.F(1,3);...
        0       -1      0       0      0       0       -epi.F(2,3);...
        0       0       -1      0      0       0       -epi.F(3,3);...
        0       0       0      1       0       0       -epi.F(1,2);...
        0       0       0       0       1      0       -epi.F(2,2);...
        0       0       0       0       0       1      -epi.F(3,2);...
        -H(3,1) 0       0       H(2,1)  0       0      -epi.F(1,1);...
        0       -H(3,1) 0       0       H(2,1)  0      -epi.F(2,1);...
        0       0       -H(3,1) 0       0       H(2,1) -epi.F(3,1)];
    
[~,~,V] = svd(B);

Hp = [ [1 0 0]' -V(1:3,end) V(4:6,end) ];
Hp = [  1           0           0;...
        -epi.F(1,3) -epi.F(2,3) -epi.F(3,3);...
        epi.F(1,2) epi.F(2,2) epi.F(3,2)];
    

[r,c,~] = size( im1 );

pts = [ 0 0 1;...
        r 0 1;...
        0 c 1;...
        r c 1];
H = minimizeDistortion( H, pts, 0 );
Hp = minimizeDistortion( Hp, pts, 0 );

[im1p, im2p] = rectify( im1, im2, H, Hp );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% image 1
figure
subplot(1,2,1),imshow( im1p );
yPos = get(gca,'ylim')/2;
hold on
refline(0, yPos(2) );
hold off

%% image 2
subplot(1,2,2),imshow( im2p );
yPos = get(gca,'ylim')/2;
hold on
refline(0,yPos(2));
hold off

%% disparity
% disparityMap = disparity( rgb2gray(im1p), rgb2gray(im2p), 'DisparityRange',[0 16] );
% figure, imshow( disparityMap, [0 16] );


%% helper functions

function [im1, im2] = rectify( I1, I2, H1, H2 )
    % find common transformed area
    [r,c,~] = size(I1);
    mbr1 = MBR( H1, r,c );
    [r,c,~] = size(I2);
    mbr2 = MBR( H2, r,c );
    xmin = ceil( max( mbr1(1,1), mbr2(1,1) ) );
    xmax = floor( min( mbr1(2,1), mbr2(2,1) ) );
    ymin = ceil( max( mbr1(1,2), mbr2(1,2) ) );
    ymax = floor( min( mbr1(2,2), mbr2(2,2) ) );
    
    width = xmax-xmin;
    height = ymax-ymin;
    
    xLim = [ xmin-0.5,xmax+0.5 ];
    yLim = [ ymin-0.5,ymax+0.5 ];
    
    tform1 = projective2d( H1' );
    tform2 = projective2d( H2' );
    
    outputView = imref2d([height, width], xLim, yLim);
    im1 = imwarp(I1, tform1, 'OutputView', outputView );
    im2 = imwarp(I2, tform2, 'Outputview', outputView );
end

function mbr = MBR( H,r,c )
    
    a = [ [1 1 1]', [c 1 1]', [c r 1]', [1 r 1]' ];
    a = H*a;
    a = a./repmat(a(3,:),3,1);
    
    minx = min( a(1,:) );
    maxx = max( a(1,:) );
    miny = min( a(2,:) );
    maxy = max( a(2,:) );
    
    mbr = [ minx, miny;...
            maxx, maxy];
end
    
            


