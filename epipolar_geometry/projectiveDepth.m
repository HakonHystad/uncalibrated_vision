%projectiveDepth

% im1 = imread('images/building1a.jpg');
% im2 = imread('images/building2a.jpg');
im1 = imread('images/table1a.jpg');
im2 = imread('images/table2a.jpg');


% estimate fundamental matrix
epi = Epipolar( im1, im2 );

epi.correctInliers();
len = length( epi.in1 );
in1 = [ epi.in1(:,1:2), ones(len, 1) ];
in2 = [ epi.in2(:,1:2), ones(len, 1) ];

ind = randperm( length(in1), 4 );



%% find homography   
v1 = in1(ind,:);
v2 = in2(ind,:);
H = plane2Homography( v1,v2, epi.F, epi.eP2 );

% H = homography(v1,v2);
    
d = norm(H'*epi.F+epi.F'*H);% compatability check

% % add plane
plane = [   in1(ind(1),1), in1(ind(1),2),...
            in1(ind(2),1), in1(ind(2),2),...
            in1(ind(3),1), in1(ind(3),2)];
im1 = insertShape(im1, 'FilledPolygon', plane );

imshow(im1);
hold on
pDepth = zeros(len,1);
color = zeros( len,3);
for i=1:len
      trans = (H*in1(i,:)')';
      trans = trans./trans(3);
      pDepth(i) = (in2(i,:)-trans)*epi.eP2;

    
    if pDepth(i)<0
        plot( in1(i,1), in1(i,2),'ro','MarkerFaceColor','red' );
        color(i,:) = [ 1 0 0 ]; 
    else
        plot( in1(i,1), in1(i,2),'go','MarkerFaceColor','green' );
        color(i,:) = [ 0 1 0 ]; 
    end
    
    
end% for i

plot( in1(ind(1:3),1), in1(ind(1:3),2),'co','MarkerFaceColor','cyan' );
hold off
    
% fprintf('Min: %.2f, Max: %.2f\n', min(pDepth), max(pDepth) );
% figure, plot( pDepth, 'r*' );
figure, scatter3( in1(:,1), in1(:,2), pDepth, [], color, 'filled' );
hold on
scatter3( in1(ind(1:3),1), in1(ind(1:3),2), pDepth( ind(1:3) ), [], 'cyan', 'filled' );
