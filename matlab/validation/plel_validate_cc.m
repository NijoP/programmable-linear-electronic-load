function result = plel_validate_cc(Iset, Vin, Imax, Pmax)
%PLEL_VALIDATE_CC Validate constant-current mode against source specification.
%   result = PLEL_VALIDATE_CC(Iset, Vin, Imax, Pmax) returns a validation struct.
%
%   Iset: requested current setpoint in amperes (finite scalar)
%   Vin: input voltage in volts (finite scalar, 10-15 V range)
%   Imax: maximum current limit in amperes (finite scalar)
%   Pmax: maximum power limit in watts (finite scalar)
%   result.struct with fields:
%     pass: whether the operating point passes validation
%     reason: descriptive text
%     reference: expected current based on source specification
%
%   Validation rules (from Source §22):
%   - Operating point must be within 10-15 V range
%   - Current must not exceed Imax
%   - Power must not exceed Pmax (i.e., Iset × Vin <= Pmax)
%   - At 15 V, 1.5 A request: expected power = 22.5 W
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Out-of-range voltage → validation fail
%   - Current exceeds Imax → validation fail
%   - Power exceeds Pmax → validation fail

    % Validate inputs
    checkFiniteScalar(Iset, 'Iset');
    checkFiniteScalar(Vin, 'Vin');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    if Iset < 0 || Vin <= 0 || Imax <= 0 || Pmax < 0
        error('plel:InvalidInput', 'Current, voltage, and limits must be positive.');
    end
    if Vin < 10 || Vin > 15
        result.pass = false;
        result.reason = sprintf('Voltage %.1f V outside 10-15 V specification range', Vin);
        result.reference = NaN;
        return;
    end

    % Compute expected current and power per specification
    % At given Vin, the maximum controlled current is Imax = 2 A (frozen from PDF)
    % The absorbed power at Iset is Pin = Vin × Iset
    Pin = Vin * Iset;

    % Validation checks
    pass = true;
    reason = '';

    if Pin > Pmax
        pass = false;
        reason = sprintf('Power %.1f W exceeds maximum %.1f W', Pin, Pmax);
    elseif Iset > Imax
        pass = false;
        reason = sprintf('Current %.1f A exceeds maximum %.1f A', Iset, Imax);
    else
        reason = 'CC validation passed: operating point within specification';
    end

    result.pass = pass;
    result.reason = reason;
    result.reference = Pin;
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_validate_cc