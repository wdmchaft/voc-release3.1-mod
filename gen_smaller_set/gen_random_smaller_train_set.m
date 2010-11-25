function gen_random_smaller_train_set(cls, frac)
% Randomly chooses a smaller subset of training images of an existing
% class 'cls', preserving the ratio of positive examples while reducing
% the size by 'frac'. The order of elements in 'train' and 'val' is 
% preserved, as well as in 'trainval' for which we rely on assumptions
% that 1) it is sorted by file ids 2) it is a union of first two sets.
% New sets' descriptions are written to files located in the same directory
% (ImageSets/Main) and named in similar fashion with an '_R***' appended
% to the class name where *'s are digits that can be used to identify
% subsets from of the same random sample and size


% MODIFY THIS ACCORDING TO YOUR CURRENT DIR AND VOC DEVKIT LOCATION:
VOC_DEVKIT_PATH = '~/deform-part-model/pascal-voc2007/VOCdevkit/';

current_dir = cd; 
cd(VOC_DEVKIT_PATH);
addpath('VOCcode/');
run('VOCinit');
cd(current_dir);

suffixes = {'train', 'val'};
ss_ids = cell(2,1);

for i=1:2
    
    suf = char(suffixes{i});
    set_name = strcat(cls,'_',suf);   
    ids=textscan(fopen(sprintf([VOCopts.imgsetpath],set_name)),'%s %d');

    n = length(ids{1});
    ind = 1:n;       
    % indexes of positive and negative examples in this set
    ind_pos = lfilter(ind, @(i) ids{2}(i) == 1); 
    ind_neg = lfilter(ind, @(i) ids{2}(i) == -1);
    n_pos = length(ind_pos);

    fprintf('\"%s\": \t\t%d\\%d\n',set_name,n_pos,n);
     
    n_ss = round(n * frac);
    n_pos_ss = round(n_pos * frac);   
    fprintf('subset: \t\t%d\\%d\n',n_pos_ss,n_ss);      
    
    ss = sort(cell2mat([random_subset(ind_pos, n_pos_ss) random_subset(ind_neg, n_ss - n_pos_ss)]));
       
    fname = get_filename(cls, suf, VOCopts.imgsetpath)
    ss_ids{i} = get_ids(ids, ss);   
    write_set(ss_ids{i}, fname);    
end
ss_union_ids = { vertcat(ss_ids{1}{1}, ss_ids{2}{1}), vertcat(ss_ids{1}{2}, ss_ids{2}{2})};
[ss_union_ids{1}, ix] = sort(ss_union_ids{1});
ss_union_ids{2} = ss_union_ids{2}(ix);

write_set(ss_union_ids, get_filename(cls,'trainval', VOCopts.imgsetpath))
clear get_filename

% HELPER FUNCTIONS

function ss_ids = get_ids(all, subset_ind)
    m = length(subset_ind);
    ids = cell(m,1);
    vals = zeros(m,1);
    for i=1:m
          ids(i) = all{1}(subset_ind(i));          
          vals(i) = all{2}(subset_ind(i));          
    end
    ss_ids = {ids, vals}; % OK

function write_set(ids, fname)    
    disp(['Writing ' fname])    
    fid=fopen(fname, 'w');
    for i=1:length(ids{1})
        fprintf(fid, '%s ',     char(ids{1}(i)) );
        fprintf(fid, '%d\n',    ids{2}(i)       );
    end
    fclose(fid);
        
function fn = get_filename(cls, suf, path)
    persistent seed
        
    if isempty(seed)
        while (1)
            seed = randi(10^3);        
            if ~was_seed_used(seed)
                break;
            end                
        end      
    end     
    fn = sprintf(path, sprintf('%s_R%.3d_%s',cls,seed,suf));

function q = was_seed_used(s)
    persistent used_seeds
    if isempty(used_seeds)
        used_seeds = [];
    end        
    if ismember(s,used_seeds)
        q = 1;
    else
        q = 0;
        used_seeds = [used_seeds s];
    end