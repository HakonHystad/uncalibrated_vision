clear all
close all

im1 = imread( 'rectifiedImage1.png' );
im2 = imread( 'rectifiedImage2.png' );
load( 'disparityValues.mat' );% disparityMap, disparityRange


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
in2(:,1) = in2(:,1) - disparityMap( objectIm>0 );



