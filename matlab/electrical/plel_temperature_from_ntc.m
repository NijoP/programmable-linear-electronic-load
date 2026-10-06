function T_K = plel_temperature_from_ntc(R, R0, beta, T0_K)
%PLEL_TEMPERATURE_FROM_NTC Compute temperature from NTC resistance.
%   T_K = PLEL_TEMPERATURE_FROM_NTC(R, R0, beta, T0_K) returns the temperature
%   in kelvin measured by the NTC thermistor.
%
%   R: NTC resistance in ohms at unknown temperature (finite scalar, > 0)
%   R0: nominal resistance in ohms at reference temperature T0 (finite scalar, > 0)
%   beta: beta coefficient in kelvin (finite scalar, > 0)
%   T0_K: reference temperature in kelvin (finite scalar, > 0)
%   T_K: temperature in kelvin (finite scalar)
%
%   Reference: Source §26, equation (109), physical page 19.
%   Inverse beta model: T_K = 1 / (1/T0 - (1/B) × ln(R/R0))
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Invalid resistance ratio (R/R0 produces undefined temperature) throws error
%   - Zero or negative values throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(R, 'R');
    checkFiniteScalar(R0, 'R0');
    checkFiniteScalar(beta, 'beta');
    checkFiniteScalar(T0_K, 'T0_K');
    if R <= 0 || R0 <= 0 || beta <= 0 || T0_K <= 0
        error('plel:InvalidInput', 'Resistance and reference values must be positive.');
    end

    % Compute inverse beta model
    % T_K = 1 / (1/T0 - (1/B) × ln(R/R0))
    lnRatio = log(R / R0);
    if beta == 0
        error('plel:InvalidInput', 'Beta coefficient must be nonzero.');
    end
    invT_K = 1/T0_K - lnRatio / beta;

    % Check for valid temperature (positive kelvin)
    if invT_K <= 0
        error('plel:InvalidInput', 'NTC resistance ratio produces undefined temperature (physical limit exceeded).');
    end

    T_K = 1 / invT_K;
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end