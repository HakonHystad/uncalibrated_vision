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
compFig = figure;
imshow(comp);

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

% show 3D affine recovery
figure, scatter3( in1(:,1), in2(:,2), z, 10, pixels, '.' );

% obsolite
if false

figure( compFig );
pts = [ in1(:,1:2), z, ones(len,1) ];

[plane, inliers] = ransac(  @fitPlane, @distance,{pts}, ...
                            'threshold', 1e-5, 'samplesize',3 );
plane = plane./plane(end);

%% find planes

nrOfPlanes = 10;
 planes = cell(nrOfPlanes,1);
 hold on
 normal = plane(1:3)./norm( plane(1:3) );
 planes{1} = normal;
 h = plot( pts(inliers,1), pts(inliers,2), 'r.' );
 fprintf('%d: %d\n', 1, length(inliers) );
 drawnow
 planePlot = cell( nrOfPlanes,1);
 planePlot{1} = h;
 pts( inliers,:) = [];
 
 for i=2:nrOfPlanes
    planeMatch = false;
      
    [plane, inliers] = ransac(  @fitPlane, @distance,{pts}, ...
                            'threshold', 1e-5, 'samplesize',3 );
                        plane = plane./plane(end);
    
    fprintf('%d: %d\n', i, length(inliers) );
    
    foundPlanes = sum( ~cellfun('isempty',planes));
    
    for j=1:foundPlanes
        normal = plane(1:3)./norm( plane(1:3) );
        diff =  abs( planes{j}'*normal );
        if diff>0.8
            h = plot(   pts(inliers,1), pts(inliers,2),'.');
            h.Color = planePlot{j}.Color;
            planeMatch = true;
            break;
        end
    end
 
    if ~planeMatch
          h = plot(   pts(inliers,1), pts(inliers,2),'.');
          normal = plane(1:3)./norm( plane(1:3) );
          planes{ foundPlanes+1 } = normal;
          planePlot{ foundPlanes+1 } = h;
    end
      
    drawnow

    pts( inliers,:) = [];
    
%     input('waiting..');
 end
 
 hold off
 fprintf('Covered %.2f%% of pixels with %d planes \n',100*(1-length(pts)/len), foundPlanes );

end% if show

%% helpers

function plane = fitPlane( pt )

    plane = [   cross( pt{1}(1,1:3)'-pt{1}(3,1:3)', pt{1}(2,1:3)'-pt{1}(3,1:3)' );...
                -pt{1}(3,1:3)*cross( pt{1}(1,1:3)',pt{1}(2,1:3)' ) ];
end
                        
function dist = distance( plane, pts)
    dist = abs( (plane'*pts{1}')./norm( plane(1:3)' ) );
end


