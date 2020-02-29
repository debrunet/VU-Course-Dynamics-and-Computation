function [numbers] = extract_dtmf(sampleData, fs, playSound, showPlot, debug)
%extract_dtmf Find DTMF signals and give corresponding numeric keypad
%values.
%   NUMBERS=EXTRACT_DTMF(SAMPLEDATA,FS,PLAYSOUND,SHOWPLOT,DEBUG) tries to
%   find DTMF signals in the input SAMPLEDATA, which is a vector consisting
%   of sampled data at sample rate FS, in Hertz.
%   The function uses Fast Fourier Transform to find the two peak
%   frequencies of DTMF in a window. A window is defined by a peak in
%   amplitude in the sound diagram. This function heavily relies on
%   amplitude.
%   The function will return a row vector consisting of all the digits as a
%   character.
%   It is optional to hear the sound by setting the input variable
%   PLAYSOUND to true. To show a plot of the input, set variable SHOWPLOT
%   to true. To show debug information, set DEBUG to true. All these
%   parameters are optional and off by default.
%   The plots will show a visualisation of the sound input and mark the
%   different windows it found, presumably containing DTMF signals. It will
%   then show the FFT frequencies found in another figure. To show the
%   mapping of these frequencies to numeric keypad digits, please enable
%   DEBUG.

if nargin < 5
    % Showing debug information is off by default.
    debug = false;
end
if nargin < 4
    % Showing plot is off by default.
    showPlot = false;
end
if nargin < 3
    % Playing sound is off by default.
    playSound = false;
end

if playSound
    % If wanted, the sound can be played.
    sound(sampleData,fs);
end

% Find location indices in the raw data where a peak is displayed, this is
% most probably a tone.
toneLocations = find(abs(sampleData)>.5*max(sampleData));

% Every tone has time between them. If between the found location indices
% above there is a gap of one tenth of the sampling frequency - or one
% tenth of a second - this is considered a different tone. The first tone
% starts at place 1 of the toneLocations. (See for-loop down below why it
% starts at 0 here). It ends at the first pause seen. Same with the last
% tone: it starts at the first jump and ends at the end of toneLocations.
toneIndices = [0; find(diff(toneLocations)>fs/10); length(toneLocations)];

if showPlot
    % Close all current figures.
    close all;
    % Change figure sizes and position.
    figure(1);
    set(gcf,'Position',[0,100,600,600])
    figure(2);
    % Set the amount of subplots to fit the amount of tones.
    amountOfTonePlots = floor(length(toneIndices)/2);
    set(gcf,'Position',[600,100,600,600])
    
    % Switch to figure 1.
    figure(1);
    % Convert the data to seconds and plot it.
    dt = 1/fs;
    t  = 0:dt:(length(sampleData)*dt)-dt;
    plot(t,sampleData,'k');
    % Add plot title and axis labels.
    title('Raw Sample Data with Function-Found Tone Data');
    xlabel('Time (Seconds)');
    ylabel('Amplitude');
    % Create hidden line for use in legend, as rectangle does not show.
    rectangleLegend = line(NaN,NaN,'LineWidth',10,'Color',[1 0 0 .1]);
    % Add the legend.
    legend('Raw Sample Data','Function-Found Tone Data');
end

if debug
    % Print the length of the input and the amount of tones found.
    fprintf(['The length of the input is ' num2str(length(sampleData)/fs) ...
        ' seconds. Found ' num2str(length(toneIndices)-1) ' tones.\n' ...
        'Using ' num2str(round(100*length(toneLocations)/length(sampleData),2)) ...
        '%% of the input data.\n\n']);
end

% Save the DTMF data and create a numeric keypad.
freqLow  = [ 697     770     852     941  ];
freqHigh = [ 1209    1336    1477    1633 ];
numpad   = ['123A'; '456B'; '789C'; '*0#D'];

% Loop over every tone.
for i=1:length(toneIndices)-1
    % The toneIndices vector starts at location 0. The first location in
    % the vector is 1. It ends at the next tone indice. 
    % The next tone will start at the previous tone location+1 and end at
    % the next. This continues for all tones. Then extract the data from
    % the original input.
    currentToneBegin = toneLocations(toneIndices(i)+1);
    currentToneEnd   = toneLocations(toneIndices(i+1));
    currentToneData  = sampleData(currentToneBegin:currentToneEnd);
    
    if showPlot
        % Switch to plot 1.
        figure(1);
        % Create a red transparent rectangle over the used data in the
        % original sample.
        rectangle('FaceColor',[1 0 0 .1], ...
        'Position',[currentToneBegin/fs,-1,...
        (currentToneEnd-currentToneBegin)/fs,2]);
        text('Position',[currentToneBegin/fs,0],...
            'string',i,'Color','red','FontSize',24);
    end
    
    % Apply FFT to the found tone data and only use real values.
    fftData = abs(fft(currentToneData,fs));
    % FFT is 'mirrored,' so only use the first half.
    fftData = fftData(1:end/2);
    
    % Find the two peak frequencies in the FFT diagram and their respective
    % amplitudes.
    [amplitude, freq] = findpeaks(fftData,'MinPeakHeight',.25*max(fftData),'MinPeakDistance',168);
    % The first frequency will always be the lowest, and the second the
    % highest. Find the closest match to DTMF frequencies.
    [~, row]  = min(abs(freqLow-freq(1)));
    [~, col]  = min(abs(freqHigh-freq(2)));
    % Map the column and row to a button on the numeric keypad, create row
    % vector.
    numbers(i) = numpad(row,col);
    
    if showPlot
        % Switch to figure 2 and subplot i.
        figure(2);
        subplot(amountOfTonePlots,2,i);
        % Plot the peaks found above.
        findpeaks(fftData,'MinPeakHeight',.25*max(fftData),'MinPeakDistance',168);
        % Add text to the peaks with the corresponding frequency.
        text('Position',[freq(1)+20,amplitude(1)-20],'string',[num2str(freq(1)) ' Hz'],...
            'Color',[0 0.4470 0.7410],'FontSize',10);
        text('Position',[freq(2)+20,amplitude(2)-20],'string',[num2str(freq(2)) ' Hz'],...
            'Color',[0 0.4470 0.7410],'FontSize',10);
        % Add plot title and axis labels.
        title(['Fast Fourier Transform Peaks of Tone ' num2str(i)]);
        xlabel('Frequency (Hertz)');
        ylabel('Amplitude');
    end
    
    if debug
        % Print the found peak frequency and the closest DTMF frequency.
        % Then print the corresponding button of the numeric keypad.
        fprintf(['Tone ' num2str(i) ': Found FFT peak frequencies of ' num2str(freq(1)) ' Hz and ' num2str(freq(2)) ' Hz.\n']);
        fprintf(['These are closest to DTMF freqencies of ' num2str(freqLow(row)) ' Hz and ' num2str(freqHigh(col)) ' Hz.\n']);
        fprintf(['This corresponds to value ' num2str(numbers(i)) ' on the numeric keypad.\n\n']);
    end
end