function Tj = plel_junction_temperature(Tsink, Pbranch, Rjc, Rcs)
%PLEL_JUNCTION_TEMPERATURE Compute MOSFET junction temperature.
%   Tj = PLEL_JUNCTION_TEMPERATURE(Tsink, Pbranch, Rjc, Rcs) returns the
%   junction temperature in Celsius under given conditions.
%
%   Tsink: heatsink temperature in Celsius (finite scalar, from plel_steady_state_sink)
%   Pbranch: power dissipation in one MOSFET branch in watts (finite scalar, >= 0)
%   Rjc: junction-to-case thermal resistance in K/W (finite scalar, > 0)
%   Rcs: case-to-sink thermal resistance in K/W (finite scalar, >= 0)
%   Tj: junction temperature in Celsius (finite scalar)
%
%   Reference: Source §19, equations (65)-(67), physical page 15.
%   Thermal network: Tj = Tsink + Pbranch × (Rjc + Rcs)
%   Junction temperature rises above the heatsink temperature according to
%   the total thermal resistance from junction to ambient via the case.
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Zero or negative thermal resistances throw plel:InvalidInput
%   - Negative power dissipation throws plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(Tsink, 'Tsink');
    checkFiniteScalar(Pbranch, 'Pbranch');
    checkFiniteScalar(Rjc, 'Rjc');
    checkFiniteScalar(Rcs, 'Rcs');
    if Rjc <= 0 || Rcs < 0 || Pbranch < 0
        error('plel:InvalidInput', 'Thermal resistances must be positive; power must be nonnegative.');
    end

    % Compute junction temperature
    % Tj = Tsink + Pbranch × (Rjc + Rcs)
    Tj = Tsink + Pbranch * (Rjc + Rcs);
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end