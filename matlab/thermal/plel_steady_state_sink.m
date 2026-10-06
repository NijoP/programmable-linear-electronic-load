function Tsink = plel_steady_state_sink(Ta, Ptotal, Rsa)
%PLEL_STEADY_STATE_SINK Compute steady-state heatsink temperature.
%   Tsink = PLEL_STEADY_STATE_SINK(Ta, Ptotal, Rsa) returns the heatsink temperature
%   in Celsius under steady-state conditions.
%
%   Ta: ambient temperature in Celsius (finite scalar, > -273.15)
%   Ptotal: total power dissipation in watts (finite scalar, >= 0)
%   Rsa: heatsink-to-ambient thermal resistance in K/W (finite scalar, > 0)
%   Tsink: heatsink temperature in Celsius (finite scalar)
%
%   Reference: Source §19, equations (65)-(73), physical pages 15-16.
%   Thermal network: Tsink = Ta + Ptotal × Rsa
%   This represents the case-to-ambient thermal path for a shared heatsink.
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative or zero values for Rsa and Ptotal throw plel:InvalidInput
%   - Ambient temperature below absolute zero throws plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(Ta, 'Ta');
    checkFiniteScalar(Ptotal, 'Ptotal');
    checkFiniteScalar(Rsa, 'Rsa');
    if Rsa <= 0 || Ptotal < 0 || Ta < -273.15
        error('plel:InvalidInput', 'Thermal resistance must be positive; power must be nonnegative; ambient temperature must be above absolute zero.');
    end

    % Compute steady-state heatsink temperature
    % Tsink = Ta + Ptotal × Rsa
    Tsink = Ta + Ptotal * Rsa;
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end