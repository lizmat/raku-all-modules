unit module Algorithm::LBFGS::Status;

enum STATUS is export (
    # L-BFGS reaches convergence.
    LBFGS_SUCCESS => 0,
    LBFGS_CONVERGENCE => 0,
    
    LBFGS_STOP => 1,
    # The initial variables already minimize the objective function.
    LBFGS_ALREADY_MINIMIZED => 2,
    
    # Unknown error. 
    LBFGSERR_UNKNOWNERROR => -1024,
    # Logic error. 
    LBFGSERR_LOGICERROR => -1023,
    # Insufficient memory. 
    LBFGSERR_OUTOFMEMORY => -1022,
    # The minimization process has been canceled. 
    LBFGSERR_CANCELED => -1021,
    # Invalid number of variables specified. 
    LBFGSERR_INVALID_N => -1020,
    # Invalid number of variables (for SSE) specified. 
    LBFGSERR_INVALID_N_SSE => -1019,
    # The array x must be aligned to 16 (for SSE). 
    LBFGSERR_INVALID_X_SSE => -1018,
    # Invalid parameter lbfgs_parameter_t::epsilon specified. 
    LBFGSERR_INVALID_EPSILON => -1017,
    # Invalid parameter lbfgs_parameter_t::past specified. 
    LBFGSERR_INVALID_TESTPERIOD => -1016,
    # Invalid parameter lbfgs_parameter_t::delta specified. 
    LBFGSERR_INVALID_DELTA => -1015,
    # Invalid parameter lbfgs_parameter_t::linesearch specified. 
    LBFGSERR_INVALID_LINESEARCH => -1014,
    # Invalid parameter lbfgs_parameter_t::max_step specified. 
    LBFGSERR_INVALID_MINSTEP => -1013,
    # Invalid parameter lbfgs_parameter_t::max_step specified. 
    LBFGSERR_INVALID_MAXSTEP => -1012,
    # Invalid parameter lbfgs_parameter_t::ftol specified. 
    LBFGSERR_INVALID_FTOL => -1011,
    # Invalid parameter lbfgs_parameter_t::wolfe specified. 
    LBFGSERR_INVALID_WOLFE => -1010,
    # Invalid parameter lbfgs_parameter_t::gtol specified. 
    LBFGSERR_INVALID_GTOL => -1009,
    # Invalid parameter lbfgs_parameter_t::xtol specified. 
    LBFGSERR_INVALID_XTOL => -1008,
    # Invalid parameter lbfgs_parameter_t::max_linesearch specified. 
    LBFGSERR_INVALID_MAXLINESEARCH => -1007,
    # Invalid parameter lbfgs_parameter_t::orthantwise_c specified. 
    LBFGSERR_INVALID_ORTHANTWISE => -1006,
    # Invalid parameter lbfgs_parameter_t::orthantwise_start specified. 
    LBFGSERR_INVALID_ORTHANTWISE_START => -1005,
    # Invalid parameter lbfgs_parameter_t::orthantwise_end specified. 
    LBFGSERR_INVALID_ORTHANTWISE_END => -1004,
    # The line-search step went out of the interval of uncertainty. 
    LBFGSERR_OUTOFINTERVAL => -1003,
    # A logic error occurred; alternatively, the interval of uncertainty
    # became too small. 
    LBFGSERR_INCORRECT_TMINMAX => -1002,
    # A rounding error occurred; alternatively, no line-search step
    # satisfies the sufficient decrease and curvature conditions. 
    LBFGSERR_ROUNDING_ERROR => -1001,
    # The line-search step became smaller than lbfgs_parameter_t::min_step. 
    LBFGSERR_MINIMUMSTEP => -1000,
    # The line-search step became larger than lbfgs_parameter_t::max_step. 
    LBFGSERR_MAXIMUMSTEP => -999,
    # The line-search routine reaches the maximum number of evaluations. 
    LBFGSERR_MAXIMUMLINESEARCH => -998,
    # The algorithm routine reaches the maximum number of iterations. 
    LBFGSERR_MAXIMUMITERATION => -997,
    # Relative width of the interval of uncertainty is at most
    # lbfgs_parameter_t::xtol. 
    LBFGSERR_WIDTHTOOSMALL => -996,
    # A logic error (negative line-search step) occurred. 
    LBFGSERR_INVALIDPARAMETERS => -995,
    # The current search direction increases the objective function value. 
    LBFGSERR_INCREASEGRADIENT => -994,
);
