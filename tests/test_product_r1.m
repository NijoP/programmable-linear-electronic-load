function test_product_r1()
%TEST_PRODUCT_R1 Verify the product strategy is represented in the baseline.
    cfg=plel_hardware_config();
    assert(strcmp(cfg.product.revision,'PLEL R1'));
    assert(~cfg.product.oled_fitted && ~cfg.product.encoder_fitted && ~cfg.product.ordinary_buttons_fitted);
    assert(cfg.product.emergency_stop_fitted && ~cfg.product.cloud_enabled);
    assert(strcmp(cfg.product.websocket_endpoint,'/ws'));
    fprintf('PASS: PLEL R1 web-controlled product strategy is represented.\n');
end
