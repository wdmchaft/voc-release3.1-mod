function f = lfilter(a, cond)
    f = {};
    for i=1:length(a)
        if (cond(a(i)) == 1)
            f(end+1) = {a(i)};
        end
    end
   