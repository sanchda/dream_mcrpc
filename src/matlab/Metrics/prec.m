%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.


%Precision

function s = prec(x,y)
truepositive = sum(x.*y);

falsepositive = sum(x == 1)-truepositive;

s = truepositive/(truepositive+falsepositive);


end
