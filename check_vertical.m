function vert_inside = check_vertical(row,col, polar_flag, angle_flag,...
    up_row,    up_col, down_row,  down_col,...
    left_row,  left_col, right_row, right_col)
% checks if the point (col, row) is inside the border defined by the vectors
% up_row/col, down_row/col, etc...

index_up    = find(up_col == col);
index_down  = find(down_col == col);
index_left  = find(left_col == col);
index_right = find(right_col == col);

if(isempty(index_up) & isempty(index_down) & isempty(index_left) & isempty(index_right)) 
    vert_inside = 0;
    return; 
end;

max_row = [];
min_row = [];

if(polar_flag == -1) % down border is larger than up border
    if(~isempty(index_down) & ~isempty(index_left))
        max_row = min(down_row(index_down));
        min_row = max(left_row(index_left));
        % need to do polar case, corner between 2 borders
        if(abs(min_row - max_row) <= 1 && angle_flag)
            max_row = row + 1;
        end
    end
    if(~isempty(index_down) & ~isempty(index_right))
        max_row = min(down_row(index_down));
        min_row = max(right_row(index_right));
        % polar case, corner between 2 borders
        if(abs(min_row - max_row) <= 1 && angle_flag)
            max_row = row + 1;
        end
    end
    if(~isempty(index_down) & ~isempty(index_up))
        max_row = min(down_row(index_down));
        min_row = max(up_row(index_up));
    end
    % up border polar cases
    if(angle_flag==1)
        if(~isempty(index_up) & ~isempty(index_right))
            max_row = row + 1;
            min_row = max(right_row(index_right));
        end
        if(~isempty(index_up) & ~isempty(index_left))
            max_row = row + 1;
            min_row = max(left_row(index_left));
        end
    end
    % polar cases 
    if(angle_flag==1)
    if(~isempty(index_down) & isempty(index_up) & isempty(index_right) & isempty(index_left))
        max_row = row + 1; % max row is greater than row, so that all rows > min_row will be selected
        min_row = max(down_row(index_down));
    end
    if(isempty(index_down) & ~isempty(index_up) & isempty(index_right) & isempty(index_left))
        max_row = row + 1; % max row is greater than row, so that all rows > min_row will be selected
        min_row = max(up_row(index_up));
    end
    if(isempty(index_down) & isempty(index_up) & ~isempty(index_right) & isempty(index_left))
        max_row = row + 1; % max row is greater than row, so that all rows > min_row will be selected
        min_row = max(right_row(index_right));
    end
    if(isempty(index_down) & isempty(index_up) & isempty(index_right) & ~isempty(index_left))
        max_row = row + 1; % max row is greater than row, so that all rows > min_row will be selected
        min_row = max(left_row(index_left));
    end
    end
else % up border is larger than down border
    if(~isempty(index_up) & ~isempty(index_left))
        min_row = min(up_row(index_up));
        max_row = max(left_row(index_left));
        % polar case, corner between 2 borders
        if(abs(min_row - max_row) <= 1 && angle_flag)
            min_row = row - 1;
        end
    end
    if(~isempty(index_up) & ~isempty(index_right))
        min_row = min(up_row(index_up));
        max_row = max(right_row(index_right));
        % polar case, corner between 2 borders
        if(abs(min_row - max_row) <= 1 && angle_flag)
            min_row = row - 1;
        end
    end
    if(~isempty(index_down) & ~isempty(index_up))
        max_row = min(down_row(index_down));
        min_row = max(up_row(index_up));
    end
    % down border polar cases
    if(angle_flag==1)
        if(~isempty(index_down) & ~isempty(index_right))
            max_row = max(right_row(index_right));
            min_row = row - 1;
        end
        if(~isempty(index_down) & ~isempty(index_left))
            max_row = max(left_row(index_left));
            min_row = row - 1;
        end
    end
    % polar cases
    if(angle_flag==1)
    if(~isempty(index_down) & isempty(index_up) & isempty(index_right) & isempty(index_left))
        min_row = row - 1; % max row is greater than row, so that all rows < max_row will be selected
        max_row = min(down_row(index_down));
    end
    if(isempty(index_down) & ~isempty(index_up) & isempty(index_right) & isempty(index_left))
        min_row = row - 1; % max row is greater than row, so that all rows < max_row will be selected
        max_row = min(up_row(index_up));
    end
    if(isempty(index_down) & isempty(index_up) & ~isempty(index_right) & isempty(index_left))
        min_row = row - 1; % max row is greater than row, so that all rows < max_row will be selected
        max_row = min(right_row(index_right));
    end
    if(isempty(index_down) & isempty(index_up) & isempty(index_right) & ~isempty(index_left))
        min_row = row - 1; % max row is greater than row, so that all rows < max_row will be selected
        max_row = min(left_row(index_left));
    end    
    end
end

if(row >= min_row & row <= max_row) vert_inside = 1; % true, the point is
    % inside the upper and lower bounds
else vert_inside = 0; % false the point is not inside vertically
end
