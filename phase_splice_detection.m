function imgOut = phase_splice_detection(imgIn)

%% 0: RUNTIME LOG
lastToc = 0, tic;
LOG = makeLog
if ischar(imgIn)
    LOG = makeLog(strcat('phase_splice_detection', char(imgIn)));
else
    LOG = makeLog('phase_splice_detection');   % LOG FILENAME
end

    function timingStr = logTime(functionStr) %logs runtime of function
        
        assert(ischar(functionStr), ...
            'functionStr should be a character array')
        t = toc-lastToc;
        timingStr = sprintf('%s completed w/ runtime of %g seconds', ...
            functionStr, t);
        lastToc = toc;
    end

    function logIt(FILENAME, STR)% logs STRING to specified FILENAME
        log = fopen(FILENAME, 'a');
        fprintf(log, '\n');
        fprintf(log, STR);
        fprintf(log, '\n');
        fclose(log);
    end
toRow = @(A) reshape(A, 1, []);
toCol = @(A) reshape(A, [], 1);


%% 1: INPUT HANDLING

imgIn = import_image(imgIn);
% grayscale if necessary
if size(img, 3) == 3
    imgIn = rgb2gray(imgIn);
    logIt(LOG, 'image is RGB: grayscaling')
else
    logIt(LOG, 'image is grayscale')
end

%% 1: FIND PREDICTED ERROR
[~, prediction_error] = predict_image(imgIn);
x
%% 2: TAKE WAVELET DECOMPOSITIONS

% wavelet decomposition of image

% wavelet decomposition of predicted_error

%% 3. HISTORGRAMS

% histogram of image

% histogram of wavelet

% histeogram of predicted_error

%% 4. Fourier Transforms