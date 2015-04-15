%Hey Oleg, here's a couple of performance measures for you to process.


%First argument is predictions, second is correct guesses.  0
%for living, 1 for dead.


function s = fone(x,y)
truenegative = sum(1-max(x,y));

truepositive = sum(x.*y);

falsepositive = sum(x == 1)-truepositive;

falsenegative = sum(x == 0)-truenegative;

s = (2*truepositive)/(2*truepositive+falsepositive+falsenegative);


end