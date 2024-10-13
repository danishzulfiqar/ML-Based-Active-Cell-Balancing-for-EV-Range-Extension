delete(gcp ('nocreate'));
parpool ('local',4) ;

tic;
parfor idx = 1: numel(compositeNumbers)
factors (idx,:) = factor(compositeNumbers(idx));
end
toc