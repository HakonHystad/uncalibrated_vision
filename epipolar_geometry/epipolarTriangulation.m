% Shows triangulation of two images to recover depth information.


close all
clear all

normalization = true;

%% load images
imx = imread('images/3plane_1.jpg');
imxp = imread('images/3plane_2.jpg');

while 1% while bad F
    %% estimate the fundamental matrix
    [F,inliersX, inliersXP] = extractF(imx,imxp);
    
    if normalization
        len = length( inliersX );
        [ inliersX, Tx ] = normalize( [ inliersX,ones(len,1)] );
        [ inliersXP, Txp ] = normalize( [inliersXP,ones(len,1)] );
    else
        Tx = eye(3);
        Txp = eye(3);
    end
    
    %% get camera matrices
    % epipole in image 2.
    F = inv(Txp)'*F*inv(Tx);
    epipoleXP = null(F');
    epipoleXP = epipoleXP./norm(epipoleXP);
    if ~isempty(epipoleXP)
        break;
    end
end

% Let camera 1 be origio, Hartley/Zisserman and  p.256 Canonical
% decomposition
PX = [eye(3),[  0   0   1   ]'];
PXP = [ Skew(epipoleXP)*F, epipoleXP];
[worldPts, error] = triangulate(inliersX(:,1:2), inliersXP(:,1:2),PX',PXP');
error = mean( error(:) );
fprintf('Reprojection error: %.2f\n', error );


if normalization
    inliersX = (inv(Tx)*inliersX')';
    inliersXP = (inv(Txp)*inliersXP')';
end

imshow( imx );
% hold on
% nIt = 2;
% plot(inliersX(1:nIt,1), inliersX(1:nIt,2), 'go' );
% for i=1:nIt
%     distTxt = sprintf('(%.2f,%.2f,%.2f', worldPts(i,1),worldPts(i,2),worldPts(i,3));
%     text( double( inliersX(i,1) ), double( inliersX(i,2) ), distTxt, 'Color', 'cyan' );
% end
% hold off
 hold on
color = worldPts(:,3);
[maxDepth,maxIdx] = max( color );
[minDepth, minIdx] = min( color );
color = color - minDepth;
color = color/maxDepth;
scatter( inliersX(:,1), inliersX(:,2), [], color,'filled' ); 
plot( inliersX(minIdx,1), inliersX(minIdx,2), 'rs','MarkerSize',10 );
plot( inliersX(maxIdx,1), inliersX(maxIdx,2), 'ys','MarkerSize',10 );
hold off
