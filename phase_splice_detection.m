% Input is a square test image. If it is RGB, then it is changed to a grayscale
% image. 
% 
% Output is a 78x2 array (maybe by 2, need to see how the Spider SVM works to see
% what the format needs to be). The values will be the 78 dimensional
% features of the test image and the predicted error image. 
% The 

function dataOut = phase_splice_detection(imgIn)
% read in the image (only handles black and gray
imgIn = imread(imgIn);

%% 1: FIND PREDICTED ERROR
[~, prediction_error] = predict_image(imgIn);

%% 2: TAKE WAVELET DECOMPOSITIONS
% use DB2 3 level decomp of the image; return the 4 subbands at each level
% subbands are approximation, horizontal, vertical, diagonal

% wavelet decomposition of image
[c ,s] = wavedec2(imgIn, 3, 'db2');

% approximation levels
approximationLevel1 = appcoef2(c,s,'db2',1);
approximationLevel2 = appcoef2(c,s,'db2',2);
approximationLevel3 = appcoef2(c,s,'db2',3);

% horizontal level details
horizontalLevel1 = detcoef2('h',c,s,1);
horizontalLevel2 = detcoef2('h',c,s,2);
horizontalLevel3 = detcoef2('h',c,s,3);

%vertical level details
verticalLevel1 = detcoef2('v',c,s,1);
verticalLevel2 = detcoef2('v',c,s,2);
verticalLevel3 = detcoef2('v',c,s,3);

% diagonal level details
diagonalLevel1 = detcoef2('d',c,s,1);
diagonalLevel2 = detcoef2('d',c,s,2);
diagonalLevel3 = detcoef2('d',c,s,3);


% wavelet decomposition of predicted_error
[cc ,ss] = wavedec2(prediction_error, 3, 'db2');

% approximation levels
approximationLevel11 = appcoef2(cc,ss,'db2',1);
approximationLevel22 = appcoef2(cc,ss,'db2',2);
approximationLevel33 = appcoef2(cc,ss,'db2',3);

% horizontal level details
horizontalLevel11 = detcoef2('h',cc,ss,1);
horizontalLevel22 = detcoef2('h',cc,ss,2);
horizontalLevel33 = detcoef2('h',cc,ss,3);

%vertical level details
verticalLevel11 = detcoef2('v',cc,ss,1);
verticalLevel22 = detcoef2('v',cc,ss,2);
verticalLevel33 = detcoef2('v',cc,ss,3);

% diagonal level details
diagonalLevel11 = detcoef2('d',cc,ss,1);
diagonalLevel22 = detcoef2('d',cc,ss,2);
diagonalLevel33 = detcoef2('d',cc,ss,3);

%% 4. HISTORGRAMS/PDF

% PDF of image
PDFimage = findPDF(imgIn);

% PDF of image wavelet decomposition
PDFapproximationLevel1 = findPDF(approximationLevel1);
PDFapproximationLevel2 = findPDF(approximationLevel2);
PDFapproximationLevel3 = findPDF(approximationLevel3);
PDFhorizontalLevel1 = findPDF(horizontalLevel1);
PDFhorizontalLevel2 = findPDF(horizontalLevel2);
PDFhorizontalLevel3 = findPDF(horizontalLevel3);
PDFverticalLevel1 = findPDF(verticalLevel1);
PDFverticalLevel2 = findPDF(verticalLevel2);
PDFverticalLevel3 = findPDF(verticalLevel3);
PDFdiagonalLevel1 = findPDF(diagonalLevel1);
PDFdiagonalLevel2 = findPDF(diagonalLevel2);
PDFdiagonalLevel3 = findPDF(diagonalLevel3);

% PDF of predicted_error image
PDFprediction_error = findPDF(prediction_error);

% PDF of predicted_error image wavelet decomposition
PDFapproximationLevel11 = findPDF(approximationLevel11);
PDFapproximationLevel22 = findPDF(approximationLevel22);
PDFapproximationLevel33 = findPDF(approximationLevel33);
PDFhorizontalLevel11 = findPDF(horizontalLevel11);
PDFhorizontalLevel22 = findPDF(horizontalLevel22);
PDFhorizontalLevel33 = findPDF(horizontalLevel33);
PDFverticalLevel11 = findPDF(verticalLevel11);
PDFverticalLevel22 = findPDF(verticalLevel22);
PDFverticalLevel33 = findPDF(verticalLevel33);
PDFdiagonalLevel11 = findPDF(diagonalLevel11);
PDFdiagonalLevel22 = findPDF(diagonalLevel22);
PDFdiagonalLevel33 = findPDF(diagonalLevel33);

%% 4.5 Build Matrix of all the things above
%
% Matrix of all the PDFs is organized as
% [original image | approximationLevel1 | approximationLevel2 | ...
% approximationLevel3 | horizontalLevel1 | horizontalLevel2 |
% horizontalLevel3 | verticalLevel1 | verticalLevel2 | verticalLevel3 |
% diagonalLevel1 | diagonalLevel2 | diagonalLevel3 | predition_error | ...
% | same flow as the beginning portion of the matrix ]
% then put the two together

ImgPDF = [PDFimage PDFapproximationLevel1 PDFapproximationLevel2 PDFapproximationLevel3 ...
    PDFhorizontalLevel1 PDFhorizontalLevel2 PDFhorizontalLevel3 PDFverticalLevel1 PDFverticalLevel2 ...
    PDFverticalLevel3 PDFdiagonalLevel1 PDFdiagonalLevel2 PDFdiagonalLevel3];

PredErrorPDF = [PDFprediction_error PDFapproximationLevel11 PDFapproximationLevel22 PDFapproximationLevel33 ...
    PDFhorizontalLevel11 PDFhorizontalLevel22 PDFhorizontalLevel33 PDFverticalLevel11 PDFverticalLevel22 ...
    PDFverticalLevel33 PDFdiagonalLevel11 PDFdiagonalLevel22 PDFdiagonalLevel33];

totalPDF = [ImgPDF PredErrorPDF];

[rows, columns] = size(ImgPDF);

%% 5. Fourier Transforms to Obtain the First Three Moments

% Each column in the matrix gives the PDF for each decomposition. The
% Moments matrices will hold the first three moments

for jj = 1:columns
    numeratorMoment = 0;
    denominatorMoment = 0;
    for ii = 1:rows
        numeratorMoment = numeratorMoment + totalPDF(ii,jj)*fft(totalPDF(ii,jj));
        denominatorMoment = denominatorMoment + fft(totalPDF(ii,jj));
    end
Moment1(jj) = numeratorMoment/denominatorMoment;
end

for jj = 1:columns
    numeratorMoment = 0;
    denominatorMoment = 0;
    for ii = 1:rows
        numeratorMoment = numeratorMoment + (totalPDF(ii,jj))^2*fft(totalPDF(ii,jj));
        denominatorMoment = denominatorMoment + fft(totalPDF(ii,jj));
    end
Moment2(jj) = numeratorMoment/denominatorMoment;
end

for jj = 1:columns
    numeratorMoment = 0;
    denominatorMoment = 0;
    for ii = 1:rows
        numeratorMoment = numeratorMoment + (totalPDF(ii,jj))^3*fft(totalPDF(ii,jj));
        denominatorMoment = denominatorMoment + fft(totalPDF(ii,jj));
    end
Moment3(jj) = numeratorMoment/denominatorMoment;
end


%% Format data for output
% format data as a row vector
dataOut = [Moment1 Moment2 Moment3];
end