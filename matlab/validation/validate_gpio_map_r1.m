function result = validate_gpio_map_r1(cfg)
%VALIDATE_GPIO_MAP_R1 Validate R1 GPIO assignments and freed R0 UI pins.
    m=plel_r1_gpio_map();
    pass=isequal([m.i2c_sda m.i2c_scl m.adc_current m.adc_voltage m.adc_ntc], [21 22 35 34 39]) && ...
        m.web_run_enable==25 && m.estop_monitor==33 && m.fan_control==26 && m.fault_input==27;
    value=struct('map',m,'constraints','ADC34/35/39 input-only; GPIO0 strap; EN reset; GPIO25 default-low; E-stop NC hardware-dominant');
    if pass, s='PASS'; else, s='BLOCKED'; end
    result=plel_validation_result('PLEL R1 ESP32 GPIO map',s,value,true,true, ...
        'FROZEN_FROM_PDF/DESIGN_TARGET','docs/ESP32_GPIO_MAP_R1.md and plel_r1_gpio_map.m',false, ...
        'GPIO assignments and service/safety interfaces defined');
end
