function test_web_command_validation()
%TEST_WEB_COMMAND_VALIDATION Web requests remain bounded electrical commands.
    cfg=plel_hardware_config();
    [i,s]=plel_r1_validate_command('CC',1,15,cfg); assert(strcmp(s,'VALIDATED')); assert(abs(i-1)<1e-12);
    [i,s]=plel_r1_validate_command('CP',20,15,cfg); assert(strcmp(s,'VALIDATED')); assert(abs(i-20/15)<1e-12);
    [i,s]=plel_r1_validate_command('CR',15,15,cfg); assert(strcmp(s,'VALIDATED')); assert(abs(i-1)<1e-12);
    [i,s,r]=plel_r1_validate_command('CC',2.1,15,cfg); assert(i==0 && strcmp(s,'REJECTED') && strcmp(r,'current_limit_exceeded'));
    [i,s,r]=plel_r1_validate_command('CP',31,15,cfg); assert(i==0 && strcmp(s,'REJECTED') && strcmp(r,'power_limit_exceeded'));
    c=struct('startup_authorized',false,'fault',false,'thermal_shutdown',false,'communication_alive',true);
    [i,s,r]=plel_r1_validate_command('CC',1,15,cfg,c); assert(i==0 && strcmp(s,'REJECTED') && strcmp(r,'startup_not_authorized'));
    fprintf('PASS: R1 web command validation bounds CC/CP/CR and rejects unsafe state.\n');
end
