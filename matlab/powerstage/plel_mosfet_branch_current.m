function I_branch = plel_mosfet_branch_current(I_total, N_mosfets)
%PLEL_MOSFET_BRANCH_CURRENT Compute ideal branch current from total current.
%   I_branch = PLEL_MOSFET_BRANCH_CURRENT(I_total, N_mosfets) returns the
%   ideal shared current per MOSFET branch in amperes.
%
%   I_total: total load current in amperes (finite scalar, >= 0)
%   N_mosfets: number of parallel MOSFETs (finite scalar, positive integer)
%   I_branch: ideal current per branch in amperes (finite scalar)
%
%   Reference: Source §16, equation (54), physical page 14.
%   Ideal equal sharing: I_branch = I_total / N_mosfets
%
%   Error handling:
%   - Nonfinite or non-scalar inputs throw plel:InvalidInput
%   - Non-positive values throw plel:InvalidInput
%   - N_mosfets must be a positive integer

    % Validate inputs
    checkFiniteScalar(I_total, 'I_total');
    checkFiniteScalar(N_mosfets, 'N_mosfets');
    if I_total < 0 || N_mosfets <= 0 || floor(N_mosfets) ~= N_mosfets
        error('plel:InvalidInput', 'Total current must be nonnegative and number of MOSFETs must be a positive integer.');
    end

    % Compute ideal branch current: I_branch = I_total / N_mosfets
    I_branch = I_total / N_mosfets;
end

    function checkFiniteScalar(val, name)
        if ~isnumeric(val) || ~isreal(val) || ~isscalar(val) || ~isfinite(val)
            error('plel:InvalidInput', '%s must be a finite numeric scalar.', name);
        end
    end