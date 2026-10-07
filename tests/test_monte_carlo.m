function test_monte_carlo()
 cfg=plel_hardware_config(); r=plel_r1_monte_carlo(cfg); assert(r.trials==cfg.twin.mc_trials); assert(isfinite(r.worst_branch_power_summary.max)); fprintf('PASS: system Monte Carlo twin.\n');
end
