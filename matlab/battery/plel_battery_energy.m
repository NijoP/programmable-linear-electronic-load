function [E_Wh, E_J] = plel_battery_energy(V, I, dt, method)
%PLEL_BATTERY_ENERGY Compute accumulated energy from voltage/current samples.
%   [E_Wh, E_J] = PLEL_BATTERY_ENERGY(V, I, dt, method) returns energy in watt-hours
%   and joules.
%
%   V: voltage vector in volts (finite numeric vector, >= 0 element-wise)
%   I: current vector in amperes (finite numeric vector, >= 0 element-wise)
%   dt: time interval vector in seconds (finite numeric vector, > 0 element-wise)
%       length(V) == length(I) == length(dt) or length(dt) == length(V) - 1
%   method: integration method, 'trapezoidal' (default) or 'rectangular'
%   E_Wh: accumulated energy in watt-hours (finite scalar)
%   E_J: accumulated energy in joules (finite scalar)
%
%   Reference: Source §30, equations (121)-(122), physical page 22.
%   For sampled values: E = ∫ V(t)I(t) dt
%   For uniform conditions: E = V × I × t / 3600 (V in V, I in A, t in s)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Negative voltage, current, or time → error
%   - Vector length mismatch → error

    % Validate inputs
    checkFiniteVector(V, 'V');
    checkFiniteVector(I, 'I');
    checkFiniteVector(dt, 'dt');
    if any(V < 0) || any(I < 0) || any(dt <= 0)
        error('plel:InvalidInput', 'Voltage and current must be nonnegative and time intervals must be positive.');
    end

    % Validate lengths
    if numel(V) ~= numel(I) || numel(V) ~= numel(dt) && numel(V) ~= numel(dt) + 1
        error('plel:InvalidInput', 'Length of V, I, and dt must be consistent.');
    end

    n = min(numel(V), numel(I), numel(dt));

    % Compute power and energy based on method
    P = V(1:n) .* I(1:n); % instantaneous power

    if strcmp(method, 'rectangular')
        % Left Riemann sum: E = Σ P[k] × dt[k]
        E_J = sum(P(1:n) .* dt(1:n));
    else % trapezoidal (default)
        % Trapezoidal rule on power
        if numel(V) == numel(dt)
            % Standard trapezoidal on power
            P_pair = (P(1:n) + P(2:n+1))/2;
            E_J = sum(P_pair .* dt(1:n));
        else
            % V has one more element than dt
            P_pair = (P(1:n) + P(2:n+1))/2;
            E_J = sum(P_pair .* dt(1:n));
        end
    end

    % Convert to watt-hours: E_Wh = E_J / 3600
    E_Wh = E_J / 3600;
end

functions
    function checkFiniteVector(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isvector(val) || ~isfinite(val)'
            error('plel:InvalidInput', '%s must be a finite numeric vector.', name);
        end
    end
end % plel_battery_energy