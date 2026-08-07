%% Calculates spectra with error bars for a variable
% Calculates normalized spectra (squared magnitude of the FFT) using
% segments of 50% overlaping data with a hanning window (the standard 
% practice of 221A (Data I))

% For variable Y and timeseries T call 
%[f,S,eh,el] = spectrum(Y,T) which returns the spectrum S and frequency
%axis f with upper and lower error bounds eh and el

%The length of f will depend on the size of M, the number of points per
%segment, and the timestep used in the timeseries T. 

function [f,ma,ma1, ma2, nu, pars] = spectrum_comp(variable,variable_i,time,varargin) 
f=[]; ma1 =[]; nu=[]; ma2 =[]; pars=[]; ma =[];

P=inputParser;
addRequired(P,'variable',@isnumeric);
addRequired(P,'variable_i',@isnumeric);
addRequired(P,'time',@isnumeric);
if length(variable)~=length(time)
    error('Data and time vector must be same length');
end
if size(variable)~=size(variable_i)
    error('Real and imagniary parts of data must be same size');
end

defaultSegLength = length(time);
addParameter(P,'seglength',defaultSegLength,@isnumeric);

defaultNumSeg = 1;
addParameter(P,'numseg',defaultNumSeg,@isnumeric);

defaultWindow = 'none';
checkString=@(s) any(strcmp(s,{'none','hanning','triangle'}));
addParameter(P,'window',defaultWindow,checkString);

defaultOverlap=0;
addParameter(P,'overlap',defaultOverlap,@isnumeric);

defaultMakeplot = 'none';
checkString=@(s) any(strcmp(s,{'none','combined','separate'}));
addParameter(P,'makeplot',defaultMakeplot,checkString);

parse(P,variable, variable_i, time,varargin{:});
variable = P.Results.variable;
variable_i = P.Results.variable_i;
time = P.Results.time;
seglength = P.Results.seglength;
numseg = P.Results.numseg;
window = P.Results.window;
overlap = P.Results.overlap;
makeplot = P.Results.makeplot;

if seglength == length(time) && numseg==1
    s = variable;
    si = variable_i;
    if size(s,1)==1
        s = s';
        si = si';
    end
    %disp('Full timeseries spectrum');
elseif seglength ~= length(time) && numseg ==1
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    si = buffer(variable_i,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(s(:,end))
        s(:,end)=[]; % Removes the last vector since it might be partially empty
        si(:,end)=[]; % Removes the last vector since it might be partially empty
    end
    %disp('Segmenting according to seglength');
    seglength = size(s,1);
    numseg = size(s,2);
elseif seglength == length(time) && numseg ~=1
    seglength = ceil(length(time)/(numseg*(1-overlap)+overlap));
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    si = buffer(variable_i,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(s(:,end))
        s(:,end)=[]; % Removes the last vector since it might be partially empty
        si(:,end)=[]; % Removes the last vector since it might be partially empty
    end
    %disp('Segmenting according to numseg');
    seglength = size(s,1);
    numseg = size(s,2);
elseif seglength ~=length(time) && numseg ~=1
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    si = buffer(variable_i,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    s = s(:,1:numseg);
    si = si(:,1:numseg);
    %disp('Segmenting according to seglength and numseg');
    seglength = size(s,1);
    numseg = size(s,2);
end

s = detrend(s,1);
si = detrend(si,1);
vart = mean(sum(s.^2)/size(s,1))+mean(sum(si.^2)/size(si,1)); 

if strcmp(window,'hanning')
    hannwin = hanning(seglength)*ones(1,size(s,2)); %Hanning window, a data analysis tool to emphasize central values, reducing spectral noise from mismatched segments
    s = s.*hannwin; %Scales the data by the hanning window
    si = si.*hannwin; %Scales the data by the hanning window
    %disp('Hanning window applied');
elseif ~strcmp(window,'none')
    error('Window not recognized');
else
    %disp('No windowing');
end

scomp = s + 1i*si;
S = fft(scomp); %Fourier transform of data
S = fftshift(S);
p = size(S,1); %Vector of points in the frequency space
N = size(S,2); %Size

if mod(p,2)==0
    k=0:(p/2-1); %Use only half of the fourier transform since it's symetric about its middle value
else
    k=0:(p-1)/2;
end

deltat=mode(diff(time)); %Size of timestep between consecutive measurements
T=p*deltat; %Total length of record
f = k/T; %Frequency axis

a = abs(S).^2;%Magnitude squared of coefficient
a = a/p^2;%Normalize by number of points
a = a*T;%Normalize by frequency increment 1/df = Ndt
if strcmp(window,'hanning')
    a = a*8/3; %Normalize by the degree of freedom contribution due to the hanning window
    nu = dof_calculator(seglength,numseg,window,overlap)/2;
    %disp('Hanning window normalization')
elseif strcmp(window,'none') && overlap~=0
    nu = dof_calculator(seglength,numseg,'boxcar',overlap)/2;
    %disp('Degrees of freedom for overlaping square segments')
elseif overlap==0
    nu = N; %for no overlap
    %disp('Degrees of freedom for non-overlaping square segments')
end
ma = mean(a,2); %Mean across all segments
varf = sum(ma)/T;
pars = abs(varf - vart)/vart;
pars_rat = vart/varf; %should be 1
pars_str = 'Parsevals theorem: Timeseries variance is %0.5f; Spectral sum is %0.5f; Fraction difference is %0.5f; Ratio is %0.5f \n';
%fprintf(pars_str,vart, varf, pars, pars_rat);

% Calculating error bars
err_high = nu/chi2inv(.05/2,nu); %Lower 5% confidence limit based on a chi2 distribution with nu degrees of freedom
err_low = nu/chi2inv(1-.05/2,nu); %Upper 95% confidence limit
ratio = err_high/err_low; %Ratio of errors, not used in the rest of the calculation

if mod(p,2)==0
    ma2 = ma(p/2+1:end);
    ma1 = flip(ma(2:p/2+1));
else
    ma2 = ma((p+1)/2:end);
    ma1 = flip(ma(1:(p+1)/2));
end

if strcmp(makeplot,'combined')
     colors; %This is a function of pretty colors I made
     figure('Name','Rotational Spectrum'); %Plot spectra with confidence intervals
        
        ma(ceil(length(ma)/2))=NaN;
        fline = [flip(-f(2:end)) f(1:end-1)];
        plot(fline,ma,'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
        patch([fline flip(fline)],[err_high*ma' ...  
             err_low*flip(ma)'],color.lr,'FaceAlpha',.3, ...
             'EdgeColor','none'); %Plots the confidence limits in a lighter color
         title('Rotational Spectrum');
         ylabel('$\frac{||U||^2}{N^2 \Delta f} ~ [m^2/s^2 cpd]$','Interpreter','latex','FontSize',16);
         xlabel('f [cpd]'); 
        xlim([-f(end) f(end)]);
        
            % Plot some important frequencies
    xline(2*sind(50),'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Inertial frequency
    xline(1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal lunar semidiurnal
    xline(1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal solar semidiurnal
    %xline(1/(12.65834751/24),'--b','N_2','LabelOrientation','horizontal'); %Larger lunar elliptic semidiurnal
    xline(1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(6.210300601/24),'--b','M_4','LabelOrientation','horizontal'); %Shallow water overtides of principal lunar
    xline(1/(25.81933871/24),'--b','O_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)-2*sind(50),'--b','M_2-f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)+2*sind(50),'--b','M_2+f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
        % Plot some important frequencies
    xline(-2*sind(50),'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Inertial frequency
    xline(-1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal lunar semidiurnal
    xline(-1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal solar semidiurnal
    %xline(-1/(12.65834751/24),'--b','N_2','LabelOrientation','horizontal'); %Larger lunar elliptic semidiurnal
    xline(-1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    xline(-1/(6.210300601/24),'--b','M_4','LabelOrientation','horizontal'); %Shallow water overtides of principal lunar
    xline(-1/(25.81933871/24),'--b','O_1','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    xline(-1/(12.4206012/24)-2*sind(50),'--b','M_2-f','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    xline(-1/(12.4206012/24)+2*sind(50),'--b','M_2+f','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    
         hold off;
        %set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
         set(gca,'YScale','log'); % Sets log scale
        %close
        
elseif strcmp(makeplot,'separate')
     colors; %This is a function of pretty colors I made
     figure('Name','Rotational Spectrum'); %Plot spectra with confidence intervals
        hold on;
        f = f(1:end-1);
        plot(f(2:end),ma1(2:end),'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
        patch([f(2:end) flip(f(2:end))],[err_high*ma1(2:end)' ...  
             err_low*flip(ma1(2:end))'],color.lr,'FaceAlpha',.3, ...
             'EdgeColor','none'); %Plots the confidence limits in a lighter color
        plot(f(2:end),ma2(2:end),'Color',color.b); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
        patch([f(2:end) flip(f(2:end))],[err_high*ma2(2:end)' ...  
             err_low*flip(ma2(2:end))'],color.lb,'FaceAlpha',.3, ...
             'EdgeColor','none'); %Plots the confidence limits in a lighter color
         
         title('Rotational Spectrum');
         ylabel('$\frac{||U||^2}{N^2 \Delta f} ~ [m^2/s^2 cpd]$','Interpreter','latex','FontSize',16);
         xlabel('f [cpd]')
         xlim([-f(end) f(end)]);
         
             % Plot some important frequencies
    xline(2*sind(50),'--b','f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Inertial frequency
    xline(1/(12.4206012/24),'--b','M_2','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Principal lunar semidiurnal
    xline(1/(12/24),'--b','S_2','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Principal solar semidiurnal
    %xline(1/(12.65834751/24),'--b','N_2','LabelOrientation','horizontal'); %Larger lunar elliptic semidiurnal
    xline(1/(23.93447213/24),'--b','K_1','LabelOrientation','horizontal','LabelHorizontalAlignment','right'); %Lunar diurnal
    xline(1/(6.210300601/24),'--b','M_4','LabelOrientation','horizontal'); %Shallow water overtides of principal lunar
    xline(1/(25.81933871/24),'--b','O_1','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)-2*sind(50),'--b','M_2-f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    xline(1/(12.4206012/24)+2*sind(50),'--b','M_2+f','LabelOrientation','horizontal','LabelHorizontalAlignment','left'); %Lunar diurnal
    
         hold off;
         set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
         legend('S-','','S+','');
        %close
end 
