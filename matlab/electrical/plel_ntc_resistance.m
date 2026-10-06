function R = plel_ntc_resistance(R0, beta, T0_K, T_K)
%PLEL_NTC_RESISTANCE Compute NTC resistance via the beta model.
%   R = PLEL_NTC_RESISTANCE(R0, beta, T0_K, T_K) returns the NTC resistance
%   in ohms at temperature T_K.
%
%   R0: nominal resistance in ohms at reference temperature T0 (finite scalar, > 0)
%   beta: beta coefficient in kelvin (finite scalar, > 0)
%   T0_K: reference temperature in kelvin (finite scalar, > 0)
%   T_K: temperature in kelvin at which to compute resistance (finite scalar, > 0)
%   R: NTC resistance in ohms at temperature T_K (finite scalar)
%
%   Reference: Source §26, equation (109), physical page 19.
%   Beta model: R(T) = R0 × exp[B × (1/T - 1/T0)]
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Zero or negative values throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(R0, 'R0');
    checkFiniteScalar(beta, 'beta');
    checkFiniteScalar(T0_K, 'T0_K');
    checkFiniteScalar(T_K, 'T_K');
    if R0 <= 0 || beta <= 0 || T0_K <= 0 || T_K <= 0
        error('plel:InvalidInput', 'Resistance, beta, and temperatures must be positive values.');
    end

    % Compute NTC resistance via beta model
    % R(T) = R0 × exp[B × (1/T - 1/T0)]
    R = R0 * exp(beta * (1/T_K - 1/T0_K));
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end