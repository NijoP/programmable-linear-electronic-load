function code = plel_dac_code(Vout, Vdd, denom)
%PLEL_DAC_CODE Compute MCP4725 DAC code for a target output voltage.
%   code = PLEL_DAC_CODE(Vout, Vdd, denom) returns the DAC digital code.
%
%   Vout: target output voltage in volts (finite scalar, >= 0)
%   Vdd: DAC supply voltage in volts (finite scalar, > 0)
%   denom: denominator for code calculation (finite scalar, > 0), typically 2^12 = 4096
%   code: DAC digital code in range [0, denom-1] (finite integer scalar)
%
%   Reference: Source §13, equation (5-1) and datasheet evidence E-001.
%   Ideal transfer: Vout = Vdd × code / denom  -->  code = Vout × denom / Vdd
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Vout > Vdd is physically impossible; error thrown
%   - Code is floored to [0, denom-1] to prevent overshooting

    % Validate inputs
    checkFiniteScalar(Vout, 'Vout');
    checkFiniteScalar(Vdd, 'Vdd');
    checkFiniteScalar(denom, 'denom');
    if Vout < 0 || Vdd <= 0 || denom <= 0
        error('plel:InvalidInput', 'Voltages and denominator must be positive values.');
    end
    if Vout > Vdd
        error('plel:InvalidInput', 'DAC output voltage cannot exceed supply voltage.');
    end

    % Compute DAC code: code = Vout × denom / Vdd
    % Floor to prevent overshooting the target voltage
    code = floor(Vout * denom / Vdd);

    % Clamp to valid code range
    if code < 0
        code = 0;
    elseif code >= denom
        code = denom - 1;
    end
end

functions
    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end
end % plel_dac_code