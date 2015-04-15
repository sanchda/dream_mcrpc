%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.



function s = npv(x,y)
truenegative = sum(1-max(x,y));

falsenegative = sum(x == 0)-truenegative;

s = truenegative/(truenegative+falsenegative);


end