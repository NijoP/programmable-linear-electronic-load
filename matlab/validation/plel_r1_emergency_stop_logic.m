function [power_stage_off, state] = plel_r1_emergency_stop_logic(estop_closed, mcu_run, reset_ok, fault)
%PLEL_R1_EMERGENCY_STOP_LOGIC Model the independent hardware inhibit truth table.
% NC E-stop is closed only during normal operation. Any unsafe input opens
% the analog gate-control path; software is not required to turn it off.
    safe_enable = estop_closed && mcu_run && reset_ok && ~fault;
    power_stage_off = ~safe_enable;
    if power_stage_off
        state='POWER_STAGE_OFF';
    else
        state='POWER_STAGE_ENABLED';
    end
end
