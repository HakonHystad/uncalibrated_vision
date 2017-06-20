% Using RANSAC on a function to calculate the best fitting model from 2
% sets of points

function H = homographyRANSAC( s, p, varargin )
    H = eye(3);
    len = length( s );
    
    thresh = 0.1;% threshold
    nit = 2000;% iterations
    ssz = 4;% sample size
    
    
    % parse arguments
    for i = 1:length( varargin )-1
        switch varargin{i}
            case 'threshold'
                thresh = varargin{i+1};
            case 'iterations' 
                nit = varargin{i+1};
            case 'samplesize'
                ssz = varargin{i+1};
        end% switch
    end% for i 
    
    nmaxInlier = 3;
    condCount = 0;
    
    for i = 1:nit
        %% get a random sample of ssize points
        sIndex = randperm( len, ssz );
        % s
        spts = ones( ssz, 3 );
        ppts = spts;
        
        spts(:,1:2) = s( sIndex, 1:2 );
        ppts(:,1:2) = p( sIndex, 1:2 );
        
        
        %% compute the homography of the samples
        [Htest,~] = homography( spts, ppts );
        
        % check singularity
        if rcond(Htest)<1e-6
            condCount = condCount +1;
            continue;
        end
        
        %% find difference between data with a homography in between
        tPoints = ( Htest*p' )';
        %tPoints = tPoints./repmat(tPoints(:,3),1,3);% non-homogeneous
        
        invPoints = (Htest\s')';
        RinvPoints = p;
        %invPoints = invPoints./repmat(invPoints(:,3),1,3);% non-homogeneous
        
        %(p-invPoints)
        
        % symmetric distance
        dist = sum((p-invPoints).^2,2) + sum((s-tPoints).^2,2);
        
        %dist = sum( ( p-tPoints ).^2, 2 );% square sum each row (each point)
        
        %% find inliers within threshold
        inlier = find( dist<thresh );
        
        %% if this is the most inliers so far calc the homography
        if length( inlier ) > nmaxInlier
            %dist
            H = homography( s(inlier,:), p(inlier,:) );
            nmaxInlier = length( inlier );
        end
    end% for i
    nmaxInlier
    condCount
    
    
end% homographyRANSAC
        

