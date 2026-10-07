function test_gpio_map_r1()
%TEST_GPIO_MAP_R1 Verify freed R0 UI pins and R1 safety/control assignments.
    m=plel_r1_gpio_map(); assert(m.i2c_sda==21 && m.i2c_scl==22);
    assert(m.adc_current==35 && m.adc_voltage==34 && m.adc_ntc==39);
    assert(m.web_run_enable==25 && m.estop_monitor==33 && m.fan_control==26 && m.fault_input==27);
    assert(isequal(m.freed_from_r0,{18,19,23}));
    fprintf('PASS: R1 GPIO map is deterministic and removes physical UI assignments.\n');
end
