function Icmd = plel_cp_command(Pset, Imax, Pmax, Vin)
%PLEL_CP_COMMAND Compute constant-power mode command with safety limits.
%   Icmd = PLEL_CP_COMMAND(Pset, Imax, Pmax, Vin) returns the commanded current
%   in amperes, with hardware safety limits applied.
%
%   Pset: user-requested power setpoint in watts (finite scalar, >= 0)
%   Imax: maximum current limit in amperes (finite scalar, > 0)
%   Pmax: maximum power limit in watts (finite scalar, >= 0)
%   Vin: input voltage in volts (finite scalar, > 0)
%   Icmd: commanded current in amperes after limit clamping (finite scalar)
%
%   Reference: Source §23, equations (94)-(99).
%   Ideal: Ireq = Pset / Vin
%   Safety: Icmd = min(Imax, Pmax/Vin, Pset/Vin)
%
%   The function enforces three independent limits:
%   1. Maximum current capability (Imax)
%   2. Maximum power capability (Pmax/Vin)
%   3. User requested power converted to current (Pset/Vin)
%
%   Important: At voltages below 10 V, the 2 A maximum prevents true
%   20 W constant-power operation (per source §23).
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative values throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(Pset, 'Pset');
    checkFiniteScalar(Imax, 'Imax');
    checkFiniteScalar(Pmax, 'Pmax');
    checkFiniteScalar(Vin, 'Vin');
    if Pset < 0 || Imax <= 0 || Pmax < 0 || Vin <= 0
        error('plel:InvalidInput', 'Power limits and setpoint must be positive; voltage must be positive.');
    end

    % Compute requested current from power setpoint
    Ireq = Pset / Vin;

    % Apply safety limits: Icmd = min(Imax, Pmax/Vin, Pset/Vin)
    % Note: Pmax/Vin is the maximum current from power limit; Ireq is the user setpoint current
    Icmd = min([Imax, Pmax / Vin, Ireq]);
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end