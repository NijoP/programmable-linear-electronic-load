function out = plel_r1_dac_twin(cfg, voltage)
%PLEL_R1_DAC_TWIN MCP4725 code/voltage quantization model.
    if nargin<2, voltage=linspace(0,cfg.twin.dac_reference_V,101); end
    maxv=cfg.twin.dac_reference_V; levels=2^cfg.twin.dac_bits-1;
    clamped=min(max(voltage,0),maxv); code=round(clamped/maxv*levels); actual=code/levels*maxv;
    out=struct('requested_V',voltage,'clamped_V',clamped,'code',code,'actual_V',actual, ...
        'lsb_V',maxv/levels,'provenance','DATASHEET/CALCULATED');
end
