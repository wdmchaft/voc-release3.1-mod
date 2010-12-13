%function comp = edgesegm(img)
function main
   
   if ~exist('img0')
        img0 = imread('000061_cropped.jpg');
   end 
   
   img = double(img0) ./ 255;   
   [w,h,ch] = size(img);
   
   % compute gradient of the grayscale image
   gimg = rgb2gray(img);    
   d_x = gimg(2:end,2:end) - gimg(1:end-1,2:end);
   d_y = gimg(2:end,2:end) - gimg(2:end,1:end-1);
   % deal with top-left border pixels
   d_x = [d_x(1,:); d_x]; d_y = [d_y(1,:); d_y];
   d_x = [d_x(:,1) d_x]; d_y = [d_y(:,1) d_y];
  
   % downsample image
   %img = imfilter(img,fspecial('gaussian',4,4));
   d_factor = 8; % downsampling factor
   img = imresize(img,      [w h] / d_factor, 'bilinear');  
   d_x = imresize(d_x,  [w h] / d_factor, 'bilinear');
   d_y = imresize(d_y, [w h] / d_factor, 'bilinear');
   
    % Representing gradients as orientation and magnitude
   [grad_or,grad_mag] = cart2pol(d_x,d_y);
      
   [w0, h0, ch] = size(img);

   
   %% Computing features for each pixel   
     
      % coordinates
   [c_x, c_y] = meshgrid(1:h0, 1:w0);   
   
   % color channel values
   r = img(:,:,1);
   g = img(:,:,2);
   b = img(:,:,3);
    
   % concatenate all features together
   X = cat(3,c_x,c_y,grad_or,grad_mag);
   % and flatten    
   X = reshape(X, w0 * h0, size(X,3) );
   
   %% Defining distance measure
   
    function d = cdist(x,Y)
        a1 = 5.0;        
        a2 = 10.0;     
      
        dd = ones(size(Y,1),1)*x(1:2) - Y(:,1:2);      
        d1 = sqrt(sum((dd) .^ 2, 2));       
        d2 = a1 * min(abs(x(3) - Y(:,3)), abs(x(3) + 2*pi - Y(:,3))) + a2 * abs(x(4) - Y(:,4));      
        d =  d1+ d2;
        %d = log(dist(x(1:2),y(1:2))) + a1 * abs(x(3) - y(3)) + a2 * abs(x(4) - y(4));       
    end  
   
   
   %% Segmentation by clustering
   
   %k = 50; % fixed number of output segments
   %idx = kmeans(X,k);
   
   idx = clusterdata(X,'distance',@cdist, 'linkage', 'single', 'cutoff', 1.153);
   
   % transform back to image space   
   xy_idx = reshape(idx, w0, h0);
   
   % Upsampling segmentation back to original resolution
   xy_idx = imresize(xy_idx, [w h], 'nearest');      
   
   %% Visualization
   max(xy_idx(:))
   clust_map = zeros(w,h,max(xy_idx(:)));
  
   for i = 1:max(xy_idx(:))
        clust_map(:,:,i) = (xy_idx == i) * 0.4;
   end
   
   fig = figure;
   imshow(img0);   
   hold on
   green = imshow(cat(3, zeros(w,h), ones(w,h), zeros(w,h)));
   set(green, 'AlphaData', zeros(w,h));
   hold off 
   
   set(fig, 'WindowButtonMotionFcn', @OnMouseMove);
   cur_clust = 0; % currently displayed cluster
   t = timer('TimerFcn', @DisplaySegment, 'StartDelay', 0.1);
   
   function OnMouseMove(varargin)
        
        pt = round( get(gca, 'CurrentPoint') ); 
        mouse_x = pt(1,2);
        mouse_y = pt(1,1);
        if ( mouse_x <= 0 || mouse_y <= 0 || mouse_x > w || mouse_y > h)
            stop(t);
            cur_clust = 0;
            return
        end        
        
        c = xy_idx(mouse_x,mouse_y);                
        if c ~= cur_clust            
            stop(t);
            start(t);                       
        end        
        cur_clust = c;
   end

   function DisplaySegment(varargin)
       set(green, 'AlphaData', clust_map(:,:,cur_clust));
       % bwmorph(xy_idx == c, 'remove')); % for outline
   end    

   
end

