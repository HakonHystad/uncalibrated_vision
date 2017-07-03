clear all
close all


sampleIx =[...
    0.6360    0.6549;...
    1.2225    0.5724;...
    1.7173    0.7457;...
    0.9502    0.9331]*1000;

sampleIxp =[...
    0.7687    0.6121;...
    1.3747    0.6429;...
    1.4145    0.8904;...
    0.4710    0.8251]*1000;


%% load images
imx = imread('images/table1a.jpg');
imxp = imread('images/table2a.jpg');


%% estimate the fundamental matrix and triangulate
epi = Epipolar(imx,imxp);


epi.in1 = [epi.in1;sampleIx];
epi.in2 = [epi.in2;sampleIxp];

worldPts = epi.triangulate('optimal');

%% show results
imshow( imx );

hold on

ref = 3;
color = worldPts(1:end-4,ref);
% color = distributeColor( worldPts(:,ref) );
%color = distributeColor( sqrt( sum( worldPts.^2, 2) ) );%worldPts(:,ref) );
[maxDepth,maxIdx] = max( worldPts(:,ref) );
[minDepth, minIdx] = min( worldPts(:,ref) );
fprintf('Depth span: %.2f\n', maxDepth-minDepth );

% color( color>mean( color ) ) = mean(color);

% mark extremes in depths
distTxt = sprintf('(%.2f,%.2f,%.2f)', worldPts(minIdx,1),worldPts(minIdx,2),worldPts(minIdx,3));
text( double( epi.in1(minIdx,1) ), double( epi.in1(minIdx,2) ), distTxt, 'Color', 'red','BackgroundColor','white' );
distTxt = sprintf('(%.2f,%.2f,%.2f)', worldPts(maxIdx,1),worldPts(maxIdx,2),worldPts(maxIdx,3));
text( double( epi.in1(maxIdx,1) ), double( epi.in1(maxIdx,2) ), distTxt, 'Color', 'yellow','BackgroundColor','white' );
plot( epi.in1(minIdx,1), epi.in1(minIdx,2), 'rs','MarkerSize',10 );
plot( epi.in1(maxIdx,1), epi.in1(maxIdx,2), 'ys','MarkerSize',10 );

% plot( [epi.in1(minIdx,1),epi.in1(maxIdx,1)], [epi.in1(minIdx,2),epi.in1(maxIdx,2)],...
%         'lineWidth',2,'Color','r');
    


% plot inliers with depth gradient on top of image
scatter( epi.in1(1:end-4,1), epi.in1(1:end-4,2), [], color,'filled');%worldPts(:,3),'filled' ); 

c = [   1   1   0;...
            1   0   1;...
            0   1   1;...
            1   0   0];
scatter( epi.in1(end-3:end,1), epi.in1(end-3:end,2),30,c,'+' );
hold off

% make a 3d plot of triangulated positions
figure, scatter3( worldPts(1:end-4,1), worldPts(1:end-4,2), worldPts(1:end-4,3), 15, color,'filled');% worldPts(:,3),'filled');
hold on
scatter3( worldPts(end-3:end,1), worldPts(end-3:end,2), worldPts(end-3:end,3), 30,c,'+');
xlabel('x');
ylabel('y');
zlabel('z');


function c = distributeColor( ref )% to make a uniformly spaced gradient
    len = length( ref  );
    c = zeros(len,1);
    [list, sortMap] = sort( ref );
    
    color = 0;
    prev = list(1);
    c(sortMap(1)) = color;
    for i=2:len
        if ( list(i)-prev )<1e-6
            c(sortMap(i)) = color;
        else
            color = color+1;
            c(sortMap(i)) = color;
        end
    end% for
end% distributeColor

