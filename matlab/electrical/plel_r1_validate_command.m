function [cmd, state, reason] = plel_r1_validate_command(mode, setpoint, Vin, cfg, context)
%PLEL_R1_VALIDATE_COMMAND Validate a web request before analog control.
% Browser input never becomes a DAC code directly. Existing CC/CP/CR
% equations remain the sole command-law implementation.
    if nargin < 5, context = struct(); end
    if ~isfield(context,'startup_authorized'), context.startup_authorized=true; end
    if ~isfield(context,'fault'), context.fault=false; end
    if ~isfield(context,'thermal_shutdown'), context.thermal_shutdown=false; end
    if ~isfield(context,'communication_alive'), context.communication_alive=true; end
    cmd=0; state='REJECTED'; reason='';
    if ~context.startup_authorized, reason='startup_not_authorized'; return; end
    if context.fault, reason='fault_active'; return; end
    if context.thermal_shutdown, reason='thermal_shutdown'; return; end
    if ~context.communication_alive, reason='communication_timeout'; return; end
    if ~ischar(mode) && ~isstring(mode), reason='invalid_mode'; return; end
    mode=upper(char(mode));
    if ~isscalar(setpoint) || ~isfinite(setpoint) || setpoint < 0 || ~isscalar(Vin) || ~isfinite(Vin) || Vin <= 0
        reason='invalid_setpoint_or_voltage'; return;
    end
    try
        switch mode
            case 'CC'
                if setpoint > cfg.operating.imax_A, reason='current_limit_exceeded'; return; end
                cmd=plel_cc_command(setpoint,cfg.operating.imax_A,cfg.operating.pmax_W,Vin);
            case 'CP'
                if setpoint > cfg.operating.pmax_W, reason='power_limit_exceeded'; return; end
                cmd=plel_cp_command(setpoint,cfg.operating.imax_A,cfg.operating.pmax_W,Vin);
            case 'CR'
                if setpoint <= 0, reason='invalid_resistance'; return; end
                cmd=plel_cr_command(Vin,setpoint,cfg.operating.imax_A,cfg.operating.pmax_W);
            case 'BATTERY'
                % Battery test uses a validated CC limit as its first release mode.
                if setpoint > cfg.operating.imax_A, reason='current_limit_exceeded'; return; end
                cmd=plel_cc_command(setpoint,cfg.operating.imax_A,cfg.operating.pmax_W,Vin);
            otherwise
                reason='invalid_mode'; return;
        end
    catch
        reason='command_calculation_error'; return;
    end
    state='VALIDATED'; reason='bounded_by_electrical_limits';
end
