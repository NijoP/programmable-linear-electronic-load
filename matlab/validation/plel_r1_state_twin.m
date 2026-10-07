function out = plel_r1_state_twin(events)
%PLEL_R1_STATE_TWIN Simulate startup/fault/communication supervisory states.
    if nargin<1, events={'POWER_ON','SELF_TEST_OK','START','HEARTBEAT_TIMEOUT','RESET'}; end
    state='POWER_ON'; command=0; enable=false; rows=cell(numel(events),1);
    for k=1:numel(events)
        e=upper(events{k});
        switch e
            case 'POWER_ON', state='SELF_TEST'; command=0; enable=false;
            case 'SELF_TEST_OK', state='STANDBY'; command=0; enable=false;
            case 'START', state='ACTIVE'; command=1; enable=true;
            case {'STOP','HEARTBEAT_TIMEOUT','FAULT','BROWNOUT','RESET','MCU_OFF','BOOT'}, state='FAULT'; command=0; enable=false;
            otherwise, state='FAULT'; command=0; enable=false;
        end
        rows{k}=struct('event',e,'state',state,'command',command,'power_stage_enable',enable);
    end
    out=struct('events',{events},'timeline',{rows},'provenance','SIMULATED; hardware timing remains pending');
end
