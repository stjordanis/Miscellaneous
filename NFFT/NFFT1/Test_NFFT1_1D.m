% --- From uniform to non-uniform

clc
clear all
close all

lambda = 1;
beta = 2 * pi / lambda;

c = 2;                                                      % --- Oversampling factor >=1 (typically 2)
K = 6;                                                      % --- 2K+1 interpolation samples (N should be >> K)

Tab = [2 3 1.2; 2 6 1.1; 1.5 3 1.5; 1.5 6 1.1];

for k = 1 : 4,
    if ((c == Tab(k, 1)) && (K == Tab(k, 2)))
        SBP_factor = Tab(k, 3);
    end
end

SB_Product                      = SBP_factor * ((2 * pi - pi / c) * K);
Max_Num_PFs                     = ceil(2 * SB_Product / pi);                          % --- Maximum number of PFs
% --- Half-size
a = 20 * lambda;

% --- Number of (even) radiators
N = ceil(2 * a / (lambda / 2));
if (mod(N, 2) ~= 0) N = N + 1; end

% --- Aperture discretization
x = -N / 2 : (N / 2 - 1);

Num_tests = 100;

rms_Opt_NFFT        = zeros(1, Num_tests);
rms_NFFT            = zeros(1, Num_tests);
rms_Gaussian_NFFT   = zeros(1, Num_tests);

err_Opt_NFFT        = zeros(1, Num_tests);
err_NFFT            = zeros(1, Num_tests);
err_Gaussian_NFFT   = zeros(1, Num_tests);

for tt = 1 : Num_tests,

    % --- Output spectral points
    u = 2 * beta * (rand(1, N) - 0.5);
    u = sort(u);

    data = randn(1, N) + 1i * randn(1, N);
%     data = ones(1, N);

    result_NFFT_BLAS                = NFFT1_1D_BLAS(data, pi * u / (N / 2));
    result_NFFT_Matlab              = NFFT1_1D(data, u, c, K);
    result_Gaussian_NFFT_Matlab     = NFFT1_Gaussian_1D(data, u, c, K);
    result_Opt_NFFT_Matlab          = NFFT1_1D_Opt(data, u, c, K, Max_Num_PFs, SBP_factor);

    rms_NFFT(tt)                    = 100*sqrt(sum(abs(result_NFFT_Matlab           - result_NFFT_BLAS.') .^2 ) / sum(abs(result_NFFT_BLAS) .^ 2));
    rms_Gaussian_NFFT(tt)           = 100*sqrt(sum(abs(result_Gaussian_NFFT_Matlab  - result_NFFT_BLAS.') .^2 ) / sum(abs(result_NFFT_BLAS) .^ 2));
    rms_Opt_NFFT(tt)                = 100*sqrt(sum(abs(result_Opt_NFFT_Matlab       - result_NFFT_BLAS.') .^ 2) / sum(abs(result_NFFT_BLAS) .^ 2));
    
    err_NFFT(tt)                    = max(abs(result_NFFT_Matlab           - result_NFFT_BLAS.'));
    err_Gaussian_NFFT(tt)           = max(abs(result_Gaussian_NFFT_Matlab  - result_NFFT_BLAS.'));
    err_Opt_NFFT(tt)                = max(abs(result_Opt_NFFT_Matlab       - result_NFFT_BLAS.'));

    tt / Num_tests

end

mean(rms_NFFT)
mean(rms_Gaussian_NFFT)
mean(rms_Opt_NFFT)

max(err_NFFT)
max(err_Gaussian_NFFT)
max(err_Opt_NFFT)

figure(1)
semilogy(rms_NFFT,'LineWidth',2)
hold on
semilogy(rms_Opt_NFFT,'r','LineWidth',2)
semilogy(rms_Gaussian_NFFT,'g','LineWidth',2)
hold off
xlabel('Realization')
ylabel('Percentage rms error')
legend('Kaiser-Bessel','Optimized','Gaussian')

% —- For drawings only
set(gca,'FontSize',13)
set(findall(gcf,'type','text'),'FontSize',13)

