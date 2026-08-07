function pretty_plotter_2d(k,f,ma,varargin) 

P=inputParser;
addRequired(P,'k',@isnumeric);
addRequired(P,'f',@isnumeric);
addRequired(P,'ma',@isnumeric);

if length(k)~=size(ma,1)
   error('Data and time vector must be same length');
elseif length(k)==size(ma',1)
   ma = ma';
end
if length(f)~=size(ma,2)
   error('Data and time vector must be same length');
end

defaultTitle='Wavenumber Spectrum';
addParameter(P,'plot_title',defaultTitle);

defaultPortion='all';
checkString=@(s) any(strcmp(s,{'all','right','top'}));
addParameter(P,'portion',defaultPortion,checkString);

parse(P,k,f,ma,varargin{:});
portion = P.Results.portion;
plot_title = P.Results.plot_title;



ma = log(ma);
ma(find(k==0),find(f==0))=NaN;
colors; %This is a function of pretty colors I made
figure('Name','Spectrum'); %Plot spectra with confidence intervals
    [C,h]=contourf(f, k, ma);
    h.LineColor = 'none';
    c = colorbar;
    c.Label.Interpreter = 'latex';
    c.Label.String = '$\frac{||U||^2}{N^2M^2 \Delta k \Delta f} ~ [m^3/s]$';
    cmocean('thermal','pivot',ma(end,end));
    %plot(f(2:end),ma(2:end),'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
%     hold on;
%     err_high = nu/chi2inv(.05/2,nu); %Lower 5% confidence limit based on a chi2 distribution with nu degrees of freedom
%     err_low = nu/chi2inv(1-.05/2,nu); %Upper 95% confidence limit
%     patch([f(2:end) flip(f(2:end))],[err_high*ma(2:end)' ...  
%     err_low*flip(ma(2:end))'],color.lr,'FaceAlpha',.3, ...
%     'EdgeColor','none'); %Plots the confidence limits in a lighter color
    title(plot_title);
    xlabel('$f [cpd]$','Interpreter','latex','FontSize',16); 
    ylabel('$k [m^{-1}]$','Interpreter','latex','FontSize',16); 
    %xlim([0.1 10]); % Narrow plotting range to interesting frequencies
    xlim([f(2) f(end)]); % Narrow plotting range to interesting frequencies
    
    % Plot some important frequencies
    xline(2*sind(50),'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Interial frequency
    xline(1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal lunar semidiurnal
    xline(1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal solar semidiurnal
    %xline(1/(12.65834751/24),'--b','N_2','LabelOrientation','horizontal'); %Larger lunar elliptic semidiurnal
    xline(1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    xline(1/(6.210300601/24),'--b','M_4','LabelOrientation','horizontal'); %Shallow water overtides of principal lunar
    xline(1/(25.81933871/24),'--b','O_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)-2*sind(50),'--b','M_2-f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)+2*sind(50),'--b','M_2+f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    
    
    %set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
    %set(gcf, 'Position',  [100, 100, 1920, 1080])
    if strcmp(portion,'right')
        set(gca, 'XScale', 'log'); % Sets log scale
    elseif strcmp(portion,'top')
        set(gca, 'YScale', 'log'); % Sets log scale
    end