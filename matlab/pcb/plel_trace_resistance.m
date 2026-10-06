function R = plel_trace_resistance(L, w, t, rho)
%PLEL_TRACE_RESISTANCE Compute trace resistance from geometric parameters.
%   R = PLEL_TRACE_RESISTANCE(L, w, t, rho) returns the trace resistance in ohms.
%
%   L: trace length in meters (finite scalar, > 0)
%   w: trace width in meters (finite scalar, > 0)
%   t: trace thickness in meters (finite scalar, > 0)
%   rho: copper resistivity in ohm-meters (finite scalar, > 0)
%   R: trace resistance in ohms (finite scalar)
%
%   Reference: Source §33, equations (125)-(127), physical page 24.
%   Plane-surface conductor resistance: R = ρ × L / (w × t)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Zero or negative dimensions throw plel:InvalidInput

    % Validate inputs
    checkFiniteScalar(L, 'L');
    checkFiniteScalar(w, 'w');
    checkFiniteScalar(t, 't');
    checkFiniteScalar(rho, 'rho');
    if L <= 0 || w <= 0 || t <= 0 || rho <= 0
        error('plel:InvalidInput', 'All geometric dimensions and resistivity must be positive.');
    end

    % Compute trace resistance: R = rho × L / (w × t)
    R = rho * L / (w * t);
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end