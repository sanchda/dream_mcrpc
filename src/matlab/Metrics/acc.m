%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.



function s = acc(x,y)
truenegative = sum(1-max(x,y));

truepositive = sum(x.*y);



s = (truenegative+truepositive)/length(x);


end
