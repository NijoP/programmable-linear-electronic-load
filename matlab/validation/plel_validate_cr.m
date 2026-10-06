function result = plel_validate_cr(Vin, Rset, Imax, Pmax)
%PLEL_VALIDATE_CR Validate constant-resistance mode against source specification.
%   result = PLEL_VALIDATE_CR(Vin, Rset, Imax, Pmax) returns a validation struct.
%
%   Vin: input voltage in volts (finite scalar, 10-15 V range)
%   Rset: equivalent resistance setpoint in ohms (finite scalar, > 0)
%   Imax: maximum current limit in amperes (finite scalar)
%   Pmax: maximum power limit in watts (finite scalar)
%   result.struct with fields:
%     pass: whether the operating point passes validation
%     reason: descriptive text
%     reference_I: expected current based on source specification (A)
%
%   Validation rules (from Source §24):
%   - Operating point must be within 10-15 V range
%   - Requested current Ireq = Vin/Rset must not exceed Imax
%   - Power must not exceed Pmax (Vin × Ireq <= Pmax)
%   - At 15 V, 15 ohm: expected current = 1 A
%   - At 12 V, 15 ohm: expected current = 0.8 A
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Out-of-range voltage → validation fail
%   - Non-positive resistance → validation fail
%   - Current exceeds Imax → validation fail
%   - Power exceeds Pmax → validation fail

    % Validate inputs
    checkFiniteScalar(Vin, 'Vin');
    checkFiniteScalar(Rset, 'Rset');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    if Vin < 10 || Vin > 15
        result.pass = false;
        result.reason = sprintf('Voltage %.1f V outside 10-15 V specification range', Vin);
        result.reference_I = NaN;
        return;
    end
    if Rset <= 0
        result.pass = false;
        result.reason = 'Resistance must be positive.';
        result.reference_I = NaN;
        return;
    end

    % Compute requested current from equivalent resistance
    Ireq = Vin / Rset;
    Pin = Vin * Ireq;

    % Validation checks
    pass = true;
    reason = '';

    if Ireq > Imax
        pass = false;
        reason = sprintf('Requested current %.3f A exceeds maximum %.1f A', Ireq, Imax);
    elseif Pin > Pmax
        pass = false;
        reason = sprintf('Power %.1f W exceeds maximum %.1f W', Pin, Pmax);
    else
        pass = true;
        reason = 'CR validation passed: operating point within specification';
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
end % plel_validate_cr