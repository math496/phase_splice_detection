function [predicted_image, prediction_error] = predict_image(img)
% predicts the values of an image by using it's neighboring pixels'
% channel values, as noted on page 3 of 'IMage Splicing Detection Using 2-D
% phase congruency and statistical moments of characteristic function', by
% Wen CHen, Yun Q. Shi, & We Su.

[rows, cols, dim3] = size(img);

A = zeros(rows, cols, dim3);
B = zeros(rows, cols, dim3);
C = zeros(rows, cols, dim3);

A(1:(rows-1), :, :) = img(2:rows, :, :);
B(:, 1:(cols-1), :) = img(:, 2:cols, :);
C(1:(rows-1), 1:(cols-1), :) = img(2:rows, 2:cols, :);

max_AB = max(A, B);
min_AB = min(A, B);

predicted_image =                 ...
    (C <= min_AB) .* max_AB +   ...
    (C > max_AB) .* min_AB +    ...
    and( C > min_AB, C < max_AB) .* A+B-C;

prediction_error = uint8(double(img)-(predicted_image));

end