% Estimates the fundamental matrix from a set of stereo images and plots
% the epipolar lines.


close all
clear all

%% load images
% add two overlapping images here to see the effect of camera movement on epipolar lines.
imx = imread('images/book1a.jpg');
imxp = imread('images/book2a.jpg');

%% estimate the fundamental matrix
[F,inliersX, inliersXP] = extractF(imx,imxp);
len = length( inliersX );
if len>10
    len = 10;
end


%% calculate epipolar lines
% of image 1 due to points in image 2
epipolarL1 = epipolarLine( F', inliersXP(1:len,:) );
% of image 2 due to points in image 1
epipolarL2 = epipolarLine( F, inliersX(1:len,:) );

%% and show the results

% plot inlier points
subplot(1,2,1),imshow( imx );
hold on
plot( inliersX(1:len,1), inliersX(1:len,2),'go' );
plot( inliersX(1:len,1), inliersX(1:len,2),'g+' );
subplot(1,2,2), imshow( imxp );
hold on
plot( inliersXP(1:len,1), inliersXP(1:len,2),'go' );
plot( inliersXP(1:len,1), inliersXP(1:len,2),'g+' );


% and the epipolar lines
plottablePts1 = lineToBorderPoints( epipolarL1, size( imx ) );
plottablePts2 = lineToBorderPoints( epipolarL2, size( imxp ) );

hold on
subplot(1,2,1)  
line( plottablePts1( :,[1,3] )', plottablePts1(:,[2,4])', 'Color','cyan');
hold off

hold on
subplot(1,2,2)
line( plottablePts2( :,[1,3] )', plottablePts2(:,[2,4])', 'Color','cyan');
hold off
