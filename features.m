function F = features(img, sbin)
% Computing feature vectors for the whole img for a given cell size
% This is a reimplementation of features.cc in Matlab

% unit vectors corresponding to gradient orientation bins
nbins = 9;
or = [0.0:(pi/nbins):pi*(1 - 1/nbins)]'; %orientations in radians
uv = [cos(or) sin(or)]; % each unit vector is a row

if (ndims(img) != 3 || size(img,3) != 3 || ~isa(img,'double'))
    error('Invalid input');
end

% memory for caching orientation histograms & their norms
blocks = [round( size(img,1)/sbin )     round( size(img,2)/sbin )  ];

feat = zeros(blocks(1)-2, blocks(2)-2, 27+4);

visible = [blocks(1)*sbin   blocks(2)*sbin];

for x = 2:visible(2)-2
    for y = 2:visible(1)-2
    % TODO: border conditions
    
    dx = zeros(3); dy = zeros(3); v = zeros(3);
        for c = 1:3
            % finite-difference apporximation of gradient
            dx(c) = img(x+1,y,c) - img(x-1,y,c);
            dy(c) = img(x,y+1,c) - img(x,y-1,c);
            v(c) = dx^2 + dy^2;            
        end
        
        [dummy, imax] = max(v);
        dx = dx(imax);
        dy = dy(imax);
        v = v(imax);       
        
        % snap to one of 18 orientations
        
        dots = uv * [dx; dy];
        dots_2pi = [dots; -dots];        
        [best_dot, best_o] = max(dots_2pi);
        
        % add to 4 histograms around pixel using linear interpolation
        
        p = ([x y] + 0.5)/sbin - 0.5;
        ip = floor(p);           
        v0 = p - ip;
        v1 = 1.0 - v0;
        v = sqrt(v);
        
        
        
        if (ip >= [0 0])
            ph = ip;           
        end        
        if ( ip(1) + 1 < blocks[])
            
            hist(ip(1), ip(2), best_o) = v1(1)*v1(2)*v;
            
    
    end    
end





end

