function test_pcb_design_release_r1()
%TEST_PCB_DESIGN_RELEASE_R1 Verify the R1 release gate includes product interfaces.
    r=pcb_design_release(); assert(strcmp(r.PCB_DESIGN_RELEASE,'PASS'));
    assert(strcmp(r.HARDWARE_VALIDATION,'PENDING'));
    names=cellfun(@(x)x.item,r.checks,'UniformOutput',false);
    assert(any(strcmp(names,'Source-PDF requirements mapped')));
    assert(any(strcmp(names,'Startup and hardware power-stage inhibit')));
    assert(~isempty(r.hardware_validation_items));
    fprintf('PASS: R1 PCB release separates pre-fabrication design from hardware validation.\n');
end
