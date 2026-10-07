function test_web_mcu_output_analysis()
%TEST_WEB_MCU_OUTPUT_ANALYSIS Verify quantitative web-to-electrical review output.
    r=generate_web_mcu_output_analysis(); assert(r.graph_count==15);
    c=r.chain_15V_1p5A; assert(c.dac_code==1861); assert(abs(c.shunt_voltage_V-0.015)<1e-12);
    assert(abs(c.ina180_output_V-1.5)<1e-12); assert(abs(c.load_power_W-22.5)<1e-12);
    fprintf('PASS: 15 quantitative web-to-MCU-to-electrical plots and chain values generated.\n');
end
