function Vsense = plel_sense_voltage(I, Rsh, gain)
%PLEL_SENSE_VOLTAGE Compute current-sense amplifier output voltage.
%   Vsense = PLEL_SENSE_VOLTAGE(I, Rsh, gain) returns the sense voltage in volts.
%
%   I: load current in amperes (finite scalar, > 0)
%   Rsh: shunt resistance in ohms (finite scalar, > 0)
%   gain: INA180A3 gain in V/V (finite scalar, > 0)
%   Vsense: sense voltage in volts (finite scalar)
%
%   Reference: Source §12, equations (25)-(27), physical page 11.
%   Ideal transfer: Vsense = gain × I × Rsh
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - TBD parameters (gain = []) throw plel:UnresolvedParameter

    % Validate inputs
    checkFiniteScalar(I, 'I');
    checkFiniteScalar(Rsh, 'Rsh');
    checkFiniteScalar(gain, 'gain');
    if I <= 0 || Rsh <= 0 || gain <= 0
        error('plel:InvalidInput', 'Current, resistance, and gain must be positive values.');
    end

    % Compute sense voltage: Vsense = gain × I × Rsh
    Vsense = gain * I * Rsh;
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_sense_voltage