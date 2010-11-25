function ss = random_subset(s, m)

    r = randi(length(s), m, 1);
    ss = cell(1,m);    
    for i=1:m
        ss(i) = s(r(i));        
    end

