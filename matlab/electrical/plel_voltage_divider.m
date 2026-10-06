function Vadc = plel_voltage_divider(Vin, R1, R2)
%PLEL_VOLTAGE_DIVIDER Compute resistive voltage-divider output.
%   Vadc = PLEL_VOLTAGE_DIVIDER(Vin, R1, R2) returns the divider output voltage in volts.
%
%   Vin: input voltage in volts (finite scalar, > 0)
%   R1: upper resistor in ohms (finite scalar, > 0), connected from Vin to ADC node
%   R2: lower resistor in ohms (finite scalar, > 0), connected from ADC node to reference
%   Vadc: divider output voltage in volts (finite scalar, 0 <= Vadc <= Vin)
%
%   Reference: Source §14, equations (40)-(44), physical page 12.
%   Ideal transfer: Vadc = Vin × R2 / (R1 + R2)
%   Division ratio: K = R2 / (R1 + R2)
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Resistance values must be positive

    % Validate inputs
    checkFiniteScalar(Vin, 'Vin');
    checkFiniteScalar(R1, 'R1');
    checkFiniteScalar(R2, 'R2');
    if Vin <= 0 || R1 <= 0 || R2 <= 0
        error('plel:InvalidInput', 'Input voltage and resistances must be positive values.');
    end

    % Compute divider output: Vadc = Vin × R2 / (R1 + R2)
    Vadc = Vin * R2 / (R1 + R2);
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end