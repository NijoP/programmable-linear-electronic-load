function [Q_Ah, Q_C] = plel_battery_charge(I, dt, method)
%PLEL_BATTERY_CHARGE Compute accumulated charge from current samples.
%   [Q_Ah, Q_C] = PLEL_BATTERY_CHARGE(I, dt, method) returns charge in ampere-hours
%   and coulombs.
%
%   I: current vector in amperes (finite numeric vector, >= 0 element-wise)
%   dt: time interval vector in seconds (finite numeric vector, > 0 element-wise)
%       length(I) == length(dt) or length(dt) == length(I) - 1
%   method: integration method, 'trapezoidal' (default) or 'rectangular'
%   Q_Ah: accumulated charge in ampere-hours (finite scalar)
%   Q_C: accumulated charge in coulombs (finite scalar)
%
%   Reference: Source §30, equations (119)-(120), physical page 22.
%   For sampled values: Q = ∫ I(t) dt
%   For uniform sampling: Q = I × t / 3600 (I in A, t in s)
%
%   Method 'rectangular' (left Riemann sum):
%     Q = Σ I[k] × Δt[k]
%
%   Method 'trapezoidal':
%     Q = Σ (I[k] + I[k+1])/2 × Δt[k] / 2
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative current or time → error
%   - Vector length mismatch → error

    % Validate inputs
    checkFiniteVector(I, 'I');
    checkFiniteVector(dt, 'dt');
    if any(I < 0) || any(dt <= 0)
        error('plel:InvalidInput', 'Current must be nonnegative and time intervals must be positive.');
    end

    % Validate lengths
    if numel(I) ~= numel(dt) && numel(I) ~= numel(dt) + 1
        error('plel:InvalidInput', 'Length of I must equal length of dt or length of dt plus one.');
    end

    n = min(numel(I), numel(dt));

    % Compute charge in coulombs based on method
    if strcmp(method, 'rectangular')
        % Left Riemann sum: Q = Σ I[k] × dt[k]
        Q_C = sum(I(1:n) .* dt(1:n));
    else % trapezoidal (default)
        % Trapezoidal rule
        if numel(I) == numel(dt)
            % Uniform: Q = Σ (I[k] + I[k+1])/2 × dt[k] / depends on interpretation
            % Standard trapezoidal: Q = Σ (I[k] + I[k+1])/2 × dt[k]
            Q_C = sum((I(1:n) + I(2:n+1))/2 .* dt(1:n));
        else
            % I has one more element than dt (time intervals between samples)
            % Q = Σ I[k] × dt[k] (rectangular) or trapezoidal variant
            Q_C = sum(I(1:n) .* dt(1:n));
        end
    end

    % Convert to ampere-hours: Q_Ah = Q_C / 3600
    Q_Ah = Q_C / 3600;
end

functions
    function checkFiniteVector(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isvector(val) || ~isfinite(val)'
            error('plel:InvalidInput', '%s must be a finite numeric vector.', name);
        end
    end
end % plel_battery_charge