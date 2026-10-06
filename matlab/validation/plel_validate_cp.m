function result = plel_validate_cp(Pset, Vin, Imax, Pmax)
%PLEL_VALIDATE_CP Validate constant-power mode against source specification.
%   result = PLEL_VALIDATE_CP(Pset, Vin, Imax, Pmax) returns a validation struct.
%
%   Pset: requested power setpoint in watts (finite scalar)
%   Vin: input voltage in volts (finite scalar, 10-15 V range)
%   Imax: maximum current limit in amperes (finite scalar)
%   Pmax: maximum power limit in watts (finite scalar)
%   result.struct with fields:
%     pass: whether the operating point passes validation
%     reason: descriptive text
%     reference_I: expected current based on source specification (A)
%
%   Validation rules (from Source §23):
%   - Operating point must be within 10-15 V range
%   - Requested current Ireq = Pset/Vin must not exceed Imax
%   - Requested power must not exceed the effective maximum at given voltage
%   - At 15 V, 20 W: expected current = 1.333 A
%   - At 12 V, 20 W: expected current = 1.667 A
%   - At 10 V, 20 W: 2 A is the maximum (current limit prevents true 20 W)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Out-of-range voltage → validation fail
%   - Current exceeds Imax → validation fail

    % Validate inputs
    checkFiniteScalar(Pset, 'Pset');
    checkFiniteScalar(Vin, 'Vin');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    if Pset < 0 || Vin <= 0 || Imax <= 0 || Pmax < 0
        error('plel:InvalidInput', 'Power, voltage, and limits must be positive.');
    end
    if Vin < 10 || Vin > 15
        result.pass = false;
        result.reason = sprintf('Voltage %.1f V outside 10-15 V specification range', Vin);
        result.reference_I = NaN;
        return;
    end

    % Compute requested current from power setpoint
    Ireq = Pset / Vin;

    % Validation checks
    pass = true;
    reason = '';

    % Check current limit
    if Ireq > Imax
        pass = false;
        reason = sprintf('Requested current %.3f A exceeds maximum %.1f A', Ireq, Imax);
    % Check power limit at given voltage
    elseif Pset > Pmax
        pass = false;
        reason = sprintf('Power %.1f W exceeds maximum %.1f W', Pset, Pmax);
    else
        pass = true;
        reason = 'CP validation passed: operating point within specification';
    end

    result.pass = pass;
    result.reason = reason;
    result.reference_I = Ireq;
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_validate_cp