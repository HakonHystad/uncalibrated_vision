% Estimate the fundamental matrix and draw epipolar lines.

close all
clear all

%% load images
im1rgb = imread('images/book1a.jpg');
im2rgb = imread('images/book2a.jpg');

im1 = rgb2gray( im1rgb );
im2 = rgb2gray( im2rgb );

im1 = wiener2(im1,[5,5]);
im2 = wiener2(im2,[5,5]);

%% detect corresponding features
pt1 = detectSURFFeatures( im1 );
pt2 = detectSURFFeatures( im2 );

[ft1, validPt1] = extractFeatures( im1, pt1 );
[ft2, validPt2] = extractFeatures( im2, pt2 );

sharedIndex = matchFeatures( ft1, ft2 );

mtchPt1 = validPt1( sharedIndex(:,1), : );
mtchPt2 = validPt2( sharedIndex(:,2), : );



%% estimate fundamental matrix 
[ F, inlierIndex ] = estimateFundamentalMatrix( mtchPt1, mtchPt2 );
len = floor( length(inlierIndex)/8 );

subplot(1,2,1),imshow( im1rgb );
hold on
plot( mtchPt1(inlierIndex(1:len)) );
subplot(1,2,2), imshow( im2rgb );
hold on
plot( mtchPt2(inlierIndex(1:len)) );

%% calculate epipolar lines
% of image 1 due to points in image 2
epipolarL1 = epipolarLine( F', mtchPt2(inlierIndex(1:len),:).Location );
% of image 2 due to points in image 1
epipolarL2 = epipolarLine( F, mtchPt1(inlierIndex(1:len),:).Location );

%% and show the results
plottablePts1 = lineToBorderPoints( epipolarL1, size( im1 ) );
plottablePts2 = lineToBorderPoints( epipolarL2, size( im2 ) );

hold on
subplot(1,2,1)
line( plottablePts1( :,[1,3] )', plottablePts1(:,[2,4])');
hold off

hold on
subplot(1,2,2)
line( plottablePts2( :,[1,3] )', plottablePts2(:,[2,4])');
hold off



