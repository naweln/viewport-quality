function discretized = discrete(vect_cont, vect_disc);
% takes in a vector that has continuous values and discretizes them to the
% closest  values in discrete vector

dim = length(vect_cont);
discretized = zeros(1,dim);
for index = 1:dim
    mindiff = min(abs(vect_cont(index)-vect_disc));
    i = find(vect_cont(index)-vect_disc <= mindiff,1);
    discretized(index) = vect_disc(i);
end
    