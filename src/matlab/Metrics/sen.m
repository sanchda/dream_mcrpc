%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.


%Sensitivity

function s = sen(x,y)
truepositive = sum(x.*y);

positive = sum(y == 1);

s = truepositive/positive;


end