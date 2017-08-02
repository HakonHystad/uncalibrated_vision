clear all

im1 = imread('images/building1a.jpg');
im2 = imread('images/building2a.jpg');
% im1 = imread('images/lunch1.png');
% im2 = imread('images/lunch2.png');

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

% figure,imshow(stereoAnaglyph(r.rectIm1,r.rectIm2));

[disparityMap, disparityRange] = r.calcDisparity();
figure,imshow( disparityMap, disparityRange );
colormap jet
colorbar
