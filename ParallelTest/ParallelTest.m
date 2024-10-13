% Generate prime numbers up to 2^19
primeNumbers = primes(uint64(2^19));

% Generate composite numbers by multiplying each prime number with a randomly permuted prime number
compositeNumbers = primeNumbers .* primeNumbers(randperm(numel(primeNumbers)));

% Pre-allocate the factors array to hold two factors for each composite number
factors = zeros(numel(compositeNumbers), 2);

% Start timing
tic;

% Loop through each composite number and find its factors
for idx = 1:numel(compositeNumbers)
    factorList = factor(compositeNumbers(idx));
    
    % Ensure the factors array can store two factors (it should only have two since the number was made by multiplying two primes)
    if numel(factorList) == 2
        factors(idx, :) = factorList;
    else
        % Handle cases where factorization doesn't yield exactly two factors (shouldn't happen in this context)
        factors(idx, :) = [NaN, NaN];
    end
end

% Stop timing
toc;
