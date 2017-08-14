clear all
close all

im1 = imread( 'rectifiedImage1_1.png' );
im2 = imread( 'rectifiedImage2_1.png' );
load( 'disparityValues_1.mat' );% disparityMap, disparityRange
% figure,imshow(im1);


%% segment object from background
objectIm = disparityMap;
objectIm( disparityMap<(disparityRange(2)/2)*1.3 ) = 0;% background

gs = rgb2gray(im1);
segIm = gs;
segIm( (objectIm==0) ) = 0;% pick only out pixels inside disparity object
% find intensity threshold (Otsu's method) and convert to binary image
thres = graythresh(gs);
bw = imbinarize( segIm, thres);
% figure, imshow(bw),title('Binary Otsu');

segIm( bw ) = 0;% based on intensity since ground plane is white
objectIm( bw ) = 0;


% figure, imshow( objectIm, disparityRange );
% figure,imshow(segIm);

idx = zeros(size(im1,1), size(im1,2), 3,'logical');
idx(:,:,1) = objectIm==0;
idx(:,:,2) = objectIm==0;
idx(:,:,3) = objectIm==0;
rgb = im1;
rgb( idx ) = 0;
% figure,subplot(2,1,1);
% imshow(im1);
% subplot(2,1,2);
% imshow( rgb );


%% results of segmentation
comp = imfuse( im1, rgb  );
figure, imshow(comp);

total = size(im1,1)*size(im1,2);
i = objectIm>0;
objectSize = sum( i(:) );

fprintf(    'Total nr of pixels: %d\nNr of object pixels: %d\nReduction: %.2f\n',...
            total, objectSize, (1-objectSize/total) );

%% get correlating points of object
[Y,X] = find( objectIm>0 );

len = length(X);
in1 = [ X, Y, ones(len,1) ];
in2 = in1;
idx = objectIm>0;
in2(:,1) = in2(:,1) - disparityMap( idx );
z = 1./disparityMap( idx );
pixels = gs( idx );

figure, scatter3( in1(:,1), in2(:,2), z, 10, pixels, '.' );
% 
% 
% 
% nrOfPlanes = 10;
% homographies = cell(nrOfPlanes,1);
% hold on
% [inliers,H]= findPlane( in1, in2, 1, 250 );
%     homographies{1} = H;
%     h = plot( in1(inliers,1), in1(inliers,2), 'r.' );
%     fprintf('%d: %d\n', 1, length(inliers) );
%     drawnow
%     homographies{1} = H;
%     planes = cell( nrOfPlanes,1);
%     planePlot = cell( nrOfPlanes,1);
%   
%     planes{1} = H;
%     planePlot{1} = h;
% 
%     in1( inliers,:) = [];
%     in2( inliers,:) = [];
%     
% 
% for i=2:nrOfPlanes
%     planeMatch = false;
%     
%     [inliers,H]= findPlane( in1, in2, 1, 250 );
%     homographies{i} = H;
%     fprintf('%d: %d\n', i, length(inliers) );
% %     h = plot( in1(inliers,1), in1(inliers,2), '.' );
% 
%     foundPlanes = sum( ~cellfun('isempty',planes));
%     for j=1:foundPlanes
%         diff = norm(homographies{j}(1:2,1:2) - H(1:2,1:2) )
%         
%         if diff<1e-1
%             h = plot(   in1(inliers,1), in1(inliers,2),'.');
%             h.Color = planePlot{j}.Color;
%             planeMatch = true;
%             disp('Found!')
%             break;
%         end
%     end
%     
%     if ~planeMatch
%         h = plot(   in1(inliers,1), in1(inliers,2),'.');
%         planes{ foundPlanes+1 } = H;
%         planePlot{ foundPlanes+1 } = h;
%     end
%         
%     drawnow
% %     input('waiting');
%     
%     in1( inliers,:) = [];
%     in2( inliers,:) = [];
%     
% end
% hold off
% fprintf('Covered %.2f of pixels with %d planes \n',1-length(in1)/len, nrOfPlanes );
% 
% 
function dist = distance( Htest, s,p )
%% find difference between data with a homography in between
        tPoints = ( Htest*p' )';
        tPoints = tPoints./repmat(tPoints(:,3),1,3);% normalize
        
        invPoints = (Htest\s')';
        invPoints = invPoints./repmat(invPoints(:,3),1,3);% normalize
        
        % symmetric distance
        dist = sum((p-invPoints).^2,2) + sum((s-tPoints).^2,2);
end


