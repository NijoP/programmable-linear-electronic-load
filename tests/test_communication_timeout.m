function test_communication_timeout()
 cfg=plel_hardware_config(); r=plel_r1_communication_twin(cfg,[1 2 3]); assert(~r.communication_fault(1)); assert(r.communication_fault(2)&&r.communication_fault(3)); fprintf('PASS: communication timeout twin.\n');
end
