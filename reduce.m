function [reduced_x, reduced_y] = reduce(x, y)
% takes in 2 vectors x and y that define the x and y coordinates of a line.
% if the same point is repeted, the repition is removed.
% for example if x = [1 1 1 1 3 3 4 5 6]
% and            y = [2 2 3 4 5 6 9 9 9]
% the points 1 and 2 are the same, so would be removed from the two
% vectors.

reduced_x = x;
reduced_y = y;

count = 1;
while (count < length(reduced_x))
    if ((reduced_x(count) == reduced_x(count+1)) && (reduced_y(count) == reduced_y(count+1)))
        reduced_x(count+1) = [];
        reduced_y(count+1) = [];
    else count = count+1;
    end
end

