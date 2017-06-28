% Estimates the fundamental matrix from a set of stereo images and plots
% the epipolar lines.
% NOTE: the fundamental matrix estimation is tricky and might place the epipole wrong.
% The results change for every run because of RANSAC.

%% load images
% add two overlapping images here to see the effect of camera movement on epipolar lines.
im1 = imread('images/building.jpg');
im2 = imread('images/building2.jpg');

% it = 10;
% meanF = zeros(3);
% for i=1:it
%    
% eGeometry = Epipolar( im1, im2 );
% meanF = meanF + eGeometry.F;
% 
% end
% 
% meanF = meanF./it
% 
% eGeometry.F = meanF;


eGeometry = Epipolar( im1, im2 );
test = eGeometry.F
len = length( eGeometry.eL1 );
if len>10
    len = 10;
end

figure('units','normalized','outerposition',[0 0 1 1])

%% image 1
subplot(1,2,1),imshow( im1 );
hold on
% plot inlier points of image 1
eGeometry.plotInlierFeatures(1,len);
% plot epipolar lines of image 1 due to points in image 2
eGeometry.plotEpiLine(1,len);
hold off

%% image 2
subplot(1,2,2),imshow( im2 );
hold on
% plot inlier points of image 2
eGeometry.plotInlierFeatures(2,len);
% plot epipolar lines of image 1 due to points in image 2
eGeometry.plotEpiLine(2,len);
hold off
