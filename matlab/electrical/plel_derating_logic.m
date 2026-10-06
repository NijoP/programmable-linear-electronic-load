function [Icmd, state, reason] = plel_derating_logic(Icmd, T_C, T_shutdown_C, T_derating_C, T_fan_high_C)
%PLEL_DERATING_LOGIC Apply thermal derating and protection logic.
%   [Icmd, state, reason] = PLEL_DERATING_LOGIC(Icmd, T_C, T_shutdown_C, ...
%       T_derating_C, T_fan_high_C) returns the clamped current command,
%   the operating state, and the reason string.
%
%   Icmd: commanded current in amperes (finite scalar, >= 0) — will be clamped
%   T_C: case/magnitude temperature in Celsius (finite scalar)
%   T_shutdown_C: shutdown temperature threshold in Celsius (finite scalar, > 0)
%   T_derating_C: derating start temperature in Celsius (finite scalar, > 0)
%   T_fan_high_C: high fan speed temperature in Celsius (finite scalar, > 0)
%   Icmd: possibly reduced commanded current in amperes (finite scalar)
%   state: operating state text ('active', 'derating', 'fan_high', 'shutdown')
%   reason: human-readable reason string
%
%   Logic (from Source §26, equations 110-113, physical page 20):
%     T < 60°C:   normal cooling, no action
%     60°C ≤ T < 75°C:   fan at high speed
%     75°C ≤ T < 85°C:   power derating (reduce current command)
%     T ≥ 85°C:   shutdown (force Icmd = 0)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative thresholds throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(Icmd, 'Icmd');
    checkFiniteScalar(T_C, 'T_C');
    checkFiniteScalar(T_shutdown_C, 'T_shutdown_C');
    checkFiniteScalar(T_derating_C, 'T_derating_C');
    checkFiniteScalar(T_fan_high_C, 'T_fan_high_C');
    if T_shutdown_C <= 0 || T_derating_C <= 0 || T_fan_high_C <= 0
        error('plel:InvalidInput', 'Temperature thresholds must be positive values.');
    end
    if Icmd < 0
        error('plel:InvalidInput', 'Current command must be nonnegative.');
    end

    % Apply thermal protection logic
    if T_C >= T_shutdown_C
        % Shutdown: force current to zero
        Icmd = 0;
        state = 'shutdown';
        reason = sprintf('Temperature %.1f°C >= shutdown threshold %.1f°C', T_C, T_shutdown_C);
    elseif T_C >= T_derating_C
        % Power derating: reduce current command proportionally
        % Derate from 100% at derating start to 0% at shutdown
        derate_factor = (T_shutdown_C - T_C) / (T_shutdown_C - T_derating_C);
        derate_factor = max(0, min(1, derate_factor)); % Clamp to [0,1]
        Icmd = Icmd * derate_factor;
        if Icmd > 0
            state = 'derating';
            reason = sprintf('Temperature %.1f°C in derating region (%%%.1f remaining)', ...
                T_C, derate_factor * 100);
        else
            Icmd = 0;
            state = 'shutdown';
            reason = sprintf('Temperature %.1f°C >= derating threshold %.1f°C, current reduced to zero', ...
                T_C, T_derating_C);
        end
    elseif T_C >= T_fan_high_C
        % Fan at high speed: no current reduction, just informational
        state = 'fan_high';
        reason = sprintf('Temperature %.1f°C >= fan high speed threshold %.1f°C', ...
            T_C, T_fan_high_C);
    else
        % Normal operation
        state = 'active';
        reason = sprintf('Temperature %.1f°C within normal operating range', T_C);
    end
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end