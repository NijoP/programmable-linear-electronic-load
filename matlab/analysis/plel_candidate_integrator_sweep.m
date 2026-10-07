function report = plel_candidate_integrator_sweep()
%PLEL_CANDIDATE_INTEGRATOR_SWEEP Proposed circuit, NOT the released BOM.
% U1 OUT -> 10k -> filtered node (100n to GND) -> U2B follower
% U2B OUT -> 100k -> U2A IN-; 1uF from U2A OUT to IN-; VSET -> IN+.
% Crossover comes from unity loop gain, not an assigned plant pole.
% A=A0/(1+s*A0/wt); K=A/(1+s*Rin*Ccomp*(1+A)).
% Four matched gm branches with individual ballast and common shunt:
% G0=4*gm/(1+gm*Rb+4*gm*Rsh).
% Simplified Ciss envelope excludes nonlinear Miller/load interactions.
% gm, A0, GBW envelope are explicit exploratory assumptions, not guarantees.
    f=logspace(-4,7,6000); s=1j*2*pi*f;
    gm_values=[0.05 0.2 1 5 20 50];
    C_values=[1.5e-9 8e-9]; % upper corner deliberately beyond test-point Ciss
    GBW_values=[0.6e6 1.2e6]; A0_values=[2e4 1e5];
    Rg_values=3300*[0.99 1.01]; Rb_values=0.1*[0.99 1.01];
    gain_values=100*[0.99 1.01]; RC_scale=[0.891 1.111];
    rows=zeros(1536,11); k=0;
    for gm=gm_values
    for Ciss=C_values
    for GBW=GBW_values
    for A0=A0_values
    for Rg=Rg_values
    for Rb=Rb_values
    for gain=gain_values
    for scale=RC_scale
        k=k+1;
        A=A0./(1+s*A0/(2*pi*GBW));
        K=A./(1+s*100e3*1e-6*scale.*(1+A));
        buffer=A./(1+A);
        plant=4*gm/(1+gm*Rb+4*gm*0.01);
        gate=(100e3/(Rg+100e3))./(1+s*(1/(1/Rg+1/100e3))*Ciss);
        switchPole=1./(1+s*10*4*Ciss); % 10 ohm switch scenario, not selected limit
        sense=gain*0.01./(1+s/(2*pi*150e3));
        filter=1./(1+s*10e3*100e-9*scale);
        L=K.*plant.*gate.*switchPole.*sense.*filter.*buffer;
        db=20*log10(abs(L)); ph=unwrap(angle(L))*180/pi;
        crossings=find(db(1:end-1)>=0 & db(2:end)<0);
        assert(~isempty(crossings),'No unity-gain crossing in model range');
        pm=Inf; fc=NaN;
        for j=crossings
            alpha=-db(j)/(db(j+1)-db(j));
            phase=ph(j)+alpha*(ph(j+1)-ph(j));
            margin=180+phase;
            if margin<pm
                pm=margin; fc=10^(log10(f(j))+alpha*log10(f(j+1)/f(j)));
            end
        end
        j=find(ph(1:end-1)>-180 & ph(2:end)<=-180,1);
        gmdb=Inf;
        if ~isempty(j)
            alpha=(-180-ph(j))/(ph(j+1)-ph(j));
            gmdb=-(db(j)+alpha*(db(j+1)-db(j)));
        end
        rows(k,:)=[gm Ciss GBW A0 Rg Rb gain scale fc pm gmdb];
    end
    end
    end
    end
    end
    end
    end
    end
    rows=rows(1:k,:);
    [pm,index]=min(rows(:,10));
    report=struct('purpose','Exploratory exact integrator subcircuit, not BOM approval', ...
        'columns',{{'gm_S','Ciss_F','GBW_Hz','A0','Rg_ohm','Rb_ohm','sense_gain','RC_scale','crossover_Hz','PM_deg','GM_dB'}}, ...
        'corners',rows,'worst_phase_margin_deg',pm, ...
        'worst_gain_margin_dB',min(rows(:,11)), ...
        'crossover_range_Hz',[min(rows(:,9)) max(rows(:,9))], ...
        'worst_corner',rows(index,:), ...
        'envelope_numeric_check',pm>=60 && min(rows(:,11))>=10, ...
        'BOM_MODEL_MATCH',false,'OUTPUT_HEADROOM_PROVEN',false, ...
        'limitations','No guaranteed gm-vs-current-temperature map, nonlinear Miller model, supply sequencing, anti-windup, headroom or DC operating-point proof');
    fprintf('Corners=%d; PMmin=%.3f deg; GMmin=%.3f dB; fc=%.3f..%.3f Hz\n', ...
        k,pm,min(rows(:,11)),min(rows(:,9)),max(rows(:,9)));
end
