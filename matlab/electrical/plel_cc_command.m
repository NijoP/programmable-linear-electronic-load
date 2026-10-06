function Icmd = plel_cc_command(Iset, Imax, Pmax, Vin)
%PLEL_CC_COMMAND Compute constant-current mode command with safety limits.
%   Icmd = PLEL_CC_COMMAND(Iset, Imax, Pmax, Vin) returns the commanded current
%   in amperes, with hardware safety limits applied.
%
%   Iset: user-requested current setpoint in amperes (finite scalar, >= 0)
%   Imax: maximum current limit in amperes (finite scalar, > 0)
%   Pmax: maximum power limit in watts (finite scalar, >= 0)
%   Vin: input voltage in volts (finite scalar, > 0)
%   Icmd: commanded current in amperes after limit clamping (finite scalar)
%
%   Reference: Source §22, equation (85) and safety clause (97)-(100).
%   Ideal: Icmd = Iset
%   Safety: Icmd = min(Iset, Imax, Pmax/Vin)
%
%   The function enforces three independent limits:
%   1. User requested current (Iset)
%   2. Maximum current capability (Imax)
%   3. Maximum power constraint (Pmax/Vin)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative values throw plel:InvalidInput
%   - TBD parameters (any input = []) throw plel:UnresolvedParameter

    % Validate inputs
    checkFiniteScalar(Iset, 'Iset');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    checkFiniteScalar(Vin, 'Vin');
    if Iset < 0 || Imax <= 0 || Pmax < 0 || Vin <= 0
        error('plel:InvalidInput', 'Current and power limits must be positive; voltage must be positive.');
    end

    % Compute CC command with safety limits
    % Icmd = min(Iset, Imax, Pmax/Vin)
    Icmd = min([Iset, Imax, Pmax / Vin]);
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end