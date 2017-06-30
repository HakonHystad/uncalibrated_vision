clear all
close all

%% load images
imx = imread('images/shelf1.jpg');
imxp = imread('images/shelf2.jpg');

%% estimate the fundamental matrix and triangulate
epi = Epipolar(imx,imxp);
worldPts = epi.triangulate();

%% show results
imshow( imx );

hold on

% make a color map from 0-1
color = worldPts(:,3);
[maxDepth,maxIdx] = max( color );
[minDepth, minIdx] = min( color );
fprintf('Depth span: %.2f\n', maxDepth-minDepth );
color = color - minDepth;
color = color/maxDepth;

% mark extremes in depths
distTxt = sprintf('(%.2f,%.2f,%.2f)', worldPts(minIdx,1),worldPts(minIdx,2),worldPts(minIdx,3));
text( double( epi.in1(minIdx,1) ), double( epi.in1(minIdx,2) ), distTxt, 'Color', 'red','BackgroundColor','white' );
distTxt = sprintf('(%.2f,%.2f,%.2f)', worldPts(maxIdx,1),worldPts(maxIdx,2),worldPts(maxIdx,3));
text( double( epi.in1(maxIdx,1) ), double( epi.in1(maxIdx,2) ), distTxt, 'Color', 'yellow','BackgroundColor','white' );
plot( epi.in1(minIdx,1), epi.in1(minIdx,2), 'rs','MarkerSize',10 );
plot( epi.in1(maxIdx,1), epi.in1(maxIdx,2), 'ys','MarkerSize',10 );

% plot inliers with depth gradient on top of image
scatter( epi.in1(:,1), epi.in1(:,2), [], worldPts(:,3),'filled' ); 
hold off

% make a 3d plot of triangulated positions
figure, scatter3( worldPts(:,1), worldPts(:,2), worldPts(:,3), 15, worldPts(:,3),'filled');
xlabel('x');
ylabel('y');
zlabel('z');


