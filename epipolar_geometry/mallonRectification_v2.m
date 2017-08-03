clear all

% im1 = imread('images/building1a.jpg');
% im2 = imread('images/building2a.jpg');
im1 = imread('images/view0.png');
im2 = imread('images/view1.png');
% im1 = imread('images/view0a.png');
% im2 = imread('images/view1a.png');


for i=1:100% try until good rectification (or count)
    fprintf('Rectifying, trial %d\n',i)
    [r, status] = Rectify( im1, im2 );

    if status
        break;
    end

end

im = [ r.rectIm1, r.rectIm2 ];
figure,imshow(im);
yPos = get(gca,'ylim')/2;
hold on
refline(0,yPos(2));
hold off

%% visualize disparity
figure,imshow(stereoAnaglyph(r.rectIm1,r.rectIm2));
diff = abs( r.in1(:,1) - r.in2(:,1) );
[maxDiff,idx] = max( diff );
hold on
plot( r.in1(:,1),r.in1(:,2),'ro');
plot( r.in2(:,1),r.in2(:,2),'co');
% mark the greatest difference in x-direction
plot( r.in1(idx,1),r.in1(idx,2),'go','MarkerFaceColor','r');
plot( r.in2(idx,1),r.in2(idx,2),'go','MarkerFaceColor','c');
plot(   [r.in1(idx,1), r.in2(idx,1)],...
            [r.in1(idx,2), r.in2(idx,2)],'LineWidth',2,'Color','g' );

hold off

%% find disparity
[disparityMap, disparityRange] = r.calcDisparity();
figure,imshow( disparityMap, disparityRange );
colormap jet
colorbar

rectIm1 = r.rectIm1;
rectIm2 = r.rectIm2;
