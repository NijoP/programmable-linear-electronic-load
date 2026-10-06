function Icmd = plel_cr_command(Vin, Rset, Imax, Pmax)
%PLEL_CR_COMMAND Compute constant-resistance mode command with safety limits.
%   Icmd = PLEL_CR_COMMAND(Vin, Rset, Imax, Pmax) returns the commanded current
%   in amperes, with hardware safety limits applied.
%
%   Vin: input voltage in volts (finite scalar, > 0)
%   Rset: equivalent resistance setpoint in ohms (finite scalar, > 0)
%   Imax: maximum current limit in amperes (finite scalar, > 0)
%   Pmax: maximum power limit in watts (finite scalar, >= 0)
%   Icmd: commanded current in amperes after limit clamping (finite scalar)
%
%   Reference: Source §24, equations (100)-(102).
%   Ideal: Ireq = Vin / Rset
%   Safety: Icmd = min(Imax, Pmax/Vin, Vin/Rset)
%
%   The function enforces three independent limits:
%   1. Maximum current capability (Imax)
%   2. Maximum power constraint (Pmax/Vin)
%   3. Resistance-set current constraint (Vin/Rset)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative or zero values throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(Vin, 'Vin');
    checkFiniteScalar(Rset, 'Rset');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    if Vin <= 0 || Rset <= 0 || Imax <= 0 || Pmax < 0
        error('plel:InvalidInput', 'Voltage, resistance, and current limit must be positive; power limit must be nonnegative.');
    end

    % Compute requested current from equivalent resistance
    Ireq = Vin / Rset;

    % Apply safety limits: Icmd = min(Imax, Pmax/Vin, Vin/Rset)
    Icmd = min([Imax, Pmax / Vin, Ireq]);
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_cr_command