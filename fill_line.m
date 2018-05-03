function [col, row] = fill_line(col, row, im_w)

i=1;
while(i<=length(col)-1)
    if(abs(col(i)-col(i+1))>1 && abs(col(i)-col(i+1))<im_w/2)
       if(col(i+1)>col(i)) col = [col(1:i) col(i)+1 col(i+1:end)];
       else                col = [col(1:i) col(i)-1 col(i+1:end)];
       end
       row = [row(1:i) row(i) row(i+1:end)];
    end 
    i=i+1;
end
end