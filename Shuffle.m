function shuffled = Shuffle( in1darray )
% randomly permutes the order of items in the array

randidx = randperm(numel(in1darray));
shuffled = in1darray(randidx);

end
