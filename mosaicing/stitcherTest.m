stitcher = Mosaic('images/book3a.jpg');

%imshow( stitcher.getPanoramaImage() )
%size(stitcher.getPanoramaImage())


try
    stitcher.setTileImage('images/book2a.jpg');
catch
    disp('too large')
end

%imtool( stitcher.getRefImage() );
%imtool( stitcher.getTileImage() );

%figure, imshow( stitcher.getTileImage() );
% 
% stitcher.setRefPoints(1, [2383,217]);
% stitcher.setRefPoints(2, [3949,204]);
% stitcher.setRefPoints(3, [4012,1038]);
% stitcher.setRefPoints(4, [2380,1038]);
% 
% stitcher.setTilePoints(1, [376,177]);
% stitcher.setTilePoints(2, [2067,243]);
% stitcher.setTilePoints(3, [2067,1107]);
% stitcher.setTilePoints(4, [300,1087]);

% book3a
stitcher.setRefPoints(1, [1270,276]);
stitcher.setRefPoints(2, [2002,233]);
stitcher.setRefPoints(3, [2031,624]);
stitcher.setRefPoints(4, [1270,628]);



% book2a
stitcher.setTilePoints(1, [774,248]);
stitcher.setTilePoints(2, [1470,235]);
stitcher.setTilePoints(3, [1486,615]);
stitcher.setTilePoints(4, [758,616]);


stitcher.stitch();

% next tile, ref with panorama (but the same as im1 here)

imshow( stitcher.getPanoramaImage() );

stitcher.setTileImage('images/book1a.jpg');

% book1a
stitcher.setTilePoints(1, [87,245]);
stitcher.setTilePoints(2, [871,281]);
stitcher.setTilePoints(3, [873,668]);
stitcher.setTilePoints(4, [38,664]);

stitcher.stitch();

figure,imshow( stitcher.getPanoramaImage() );


