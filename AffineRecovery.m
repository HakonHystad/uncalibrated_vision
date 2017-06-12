%% affine recovery class
% A child of the recovery class, uses a line at infinity to recover affine properties.
% 
%% class definition

classdef AffineRecovery < Recovery
    
    %% properties
    properties
        recoveredImage
    end% properties
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function recover(obj)
            % TODO
        end% recovery
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getRecoveredImage(obj)
            im = 0;% tODO
        end% getRecoveredImage
        
        
    end% methods
end% AffineRecovery