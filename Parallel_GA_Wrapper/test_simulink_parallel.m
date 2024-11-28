% First, verify Simulink model can be simulated in parallel
function test_simulink_parallel()
    % Disable warnings temporarily
    warning('off', 'all');
    
    % Check Simulink Parallel Simulation Readiness
    try
        % Verify model can load
        load_system('Range_ext_TCST_NoSDKF');
        
        % Check model configuration
        cfg = getActiveConfigSet('Range_ext_TCST_NoSDKF');
        disp('Model Configuration:');
        disp(cfg);
        
        % Attempt parallel simulation
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool('local');
        end
        
        % Parallel simulation test
        spmd
            tf = 19000;
            simout = sim('Range_ext_TCST_NoSDKF', tf);
        end
        
        disp('Parallel Simulation Test Successful');
    catch ME
        disp('Parallel Simulation Diagnostics:');
        disp(ME.message);
        getReport(ME)
    end
    
    % Restore warnings
    warning('on', 'all');
end