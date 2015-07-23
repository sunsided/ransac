% fetch random data
data = random_data();

% simple 1D-polyfitting
p = polyfit(data(1,:), data(2,:), 1);
x = [0, 1];
y = polyval(p, x);

% plot the noise
close all;
figure; hold on;
plot(data(1,:), data(2,:), '+');
axis square;
xlim([0 1]);
ylim([0 1]);

% plot the fit
plot(x, y, 'r');

% so nice!
legend('data', 'regression');