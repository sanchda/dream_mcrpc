%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.



%Specificity

function s = spec(x,y)

truenegative = sum(1-max(x,y));
negative = sum(y == 0);

s = truenegative/negative;
end