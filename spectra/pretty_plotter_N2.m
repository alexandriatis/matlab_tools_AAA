function pretty_plotter_N2(f,ma,nu,plot_title,lat,N2) 

colors; %This is a function of pretty colors I made
%figure('Name','Spectrum'); %Plot spectra with confidence intervals
    plot(f(2:end),ma(2:end),'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
    hold on;
    err_high = nu/chi2inv(.05/2,nu); %Lower 5% confidence limit based on a chi2 distribution with nu degrees of freedom
    err_low = nu/chi2inv(1-.05/2,nu); %Upper 95% confidence limit
    patch([f(2:end) flip(f(2:end))],[err_high*ma(2:end)' ...  
    err_low*flip(ma(2:end))'],color.lr,'FaceAlpha',.3, ...
    'EdgeColor','none'); %Plots the confidence limits in a lighter color
    title(plot_title);
    ylabel('$\frac{||U||^2}{N^2 \Delta f} ~ [m^2/s^2 cpd]$','Interpreter','latex','FontSize',16);
    xlabel('f [cpd]'); 
    %xlim([0.1 10]); % Narrow plotting range to interesting frequencies
    Ncpd = sqrt(N2)*86400/(2*pi); % Buoyancy cycles per day
    xlim([f(2) Ncpd*1.1]); % Narrow plotting range to interesting frequencies
    %ylim([1e-5 1e-1]); 
    
    coriol = sw_f(lat)*86400/(2*pi); %coriolis frequency
    xline(coriol,'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Inertial frequency
    xline(Ncpd,'--b','N','LabelOrientation','horizontal','LabelHorizontalAlignment','left','LabelVerticalAlignment','middle'); %Buoyancy frequency
    xline(1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal lunar semidiurnal
    xline(1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal solar semidiurnal
    xline(1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    
    %coriol = sw_f(lat)*86400/(2*pi); %coriolis frequency
    % Plot some important frequencies
    %xline(coriol,'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Inertial frequency
    %xline(1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal lunar semidiurnal
    %xline(1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal solar semidiurnal
    %xline(1/(12.65834751/24),'--b','N_2','LabelOrientation','horizontal'); %Larger lunar elliptic semidiurnal
    %xline(1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    %xline(1/(6.210300601/24),'--b','M_4','LabelOrientation','horizontal'); %Shallow water overtides of principal lunar
    %xline(1/(25.81933871/24),'--b','O_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    %xline(1/(12.4206012/24)-2*sind(lat),'--b','M_2-f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    %xline(1/(12.4206012/24)+coriol,'--b','M_2+f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    
    % Calculate noise floor
    %n_level = mean(ma(end-floor(end*0.1):end));
    %noise = sqrt(n_level*f(end));
    %pars_str = 'Noise floor +/- %0.3f m/s \n';
    %noise_floor = sprintf(pars_str, noise);
    %yline(n_level,'--k',noise_floor,'LabelHorizontalAlignment','left');
    
    set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
    %set(gcf, 'Position',  [100, 100, 1920, 1080])
