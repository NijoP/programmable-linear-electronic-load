function Vsh = plel_shunt_voltage(I, Rsh)
%PLEL_SHUNT_VOLTAGE Compute shunt voltage Vsh = I × Rsh.
%   Vsh = PLEL_SHUNT_VOLTAGE(I, Rsh) returns the shunt voltage in volts.
%
%   I: load current in amperes (finite scalar, > 0)
%   Rsh: shunt resistance in ohms (finite scalar, > 0)
%   Vsh: shunt voltage in volts (finite scalar)
%
%   Reference: Source §11, equation (21)-(22), physical page 11.
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative or zero values throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(I, 'I');
    checkFiniteScalar(Rsh, 'Rsh');
    if I <= 0 || Rsh <= 0
        error('plel:InvalidInput', 'Current and resistance must be positive values.');
    end

    % Compute shunt voltage: Vsh = I × Rsh
    Vsh = I * Rsh;
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_shunt_voltage