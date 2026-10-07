function test_emergency_stop_logic()
%TEST_EMERGENCY_STOP_LOGIC Verify the hardware-inhibit truth table model.
    [off,s]=plel_r1_emergency_stop_logic(true,true,true,false); assert(~off && strcmp(s,'POWER_STAGE_ENABLED'));
    [off,s]=plel_r1_emergency_stop_logic(false,true,true,false); assert(off && strcmp(s,'POWER_STAGE_OFF'));
    [off,s]=plel_r1_emergency_stop_logic(true,false,true,false); assert(off);
    [off,s]=plel_r1_emergency_stop_logic(true,true,false,false); assert(off);
    [off,s]=plel_r1_emergency_stop_logic(true,true,true,true); assert(off);
    fprintf('PASS: R1 emergency STOP is independent of web/software command path.\n');
end
