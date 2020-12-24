close all
clear all

% Read the source RGB image
x = imread('balls.jpg');
figure; imshow(x)
[r,c,s] = size(x);

% Initialize storage for each sample region
classes = { 'red','black','blue','yellow','green','background' };
nClasses = length(classes);
sample_regions = false([r c nClasses]);

% Select each sample region.
f = figure;
for count = 1:nClasses
    set(f, 'name', ['Select sample region for ' classes{count}]);
    sample_regions(:,:,count) = roipoly(x);
end
close(f);

% Display sample regions.
for count = 1:nClasses
   figure
   imshow(sample_regions(:,:,count))
   title(['Sample Region for ' classes{count}]);
end

% Convert the RGB image into an L*A*B* image
cform = makecform('srgb2lab');
lab_x = applycform(x, cform);

% Calculate the mean 'a*'and 'b*' value for each ROI area
a = lab_x(:,:,2);
b = lab_x(:,:,3);
color_markers = repmat(0, [nClasses, 2]);

for count = 1:nClasses
    color_markers(count, 1) = mean2(a(sample_regions(:,:,count)));
    color_markers(count, 2) = mean2(b(sample_regions(:,:,count)));
end

% Step 3: Classify Each Pixel Using the Nearest Neighbor Rule
% Each color marker now has an 'a*' and a 'b*' value. You can classify each
% pixel
% in the |lab_x| image by calculating the Euclidean distance between that
% pixel and each color marker. The smallest distance will tell you that the
% pixel most closely matches that color marker. For example, if the
% distance 
% between a pixel and the red color marker is smallest, then the pixel
% would
% be labeled as a red pixel.

color_labels = 0:nClasses-1;
a = double(a);
b = double(b);
distance = repmat(0,[size(a), nClasses]);

% Perform Classification

for count = 1:nClasses
   distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
                        (b - color_markers(count,2)).^2 ).^0.5;
end


[value, label] = min(distance, [], 3);
label = color_labels(label);

% Clear value distance;

colors = [255 0 0; 0 255 0; 0 0 255; 255 255 0; 255 0 255; 0 255 255];
y = zeros(size(x));
l = double(label)+1;
for m = l : r
    for n = l : c
        y(m,n,:) = colors(l(m,n),:);
    end
end

figure; imshow(y)
colorbar


% scatter plot for the nearest neighbor classification

purple = [119/255 73/255 152/255];
plot_labels = { 'k','r','g', purple ,'m','y'};

figure
for count = 1:nClasses
    plot(a(label==count-1),b(label==count-1),'.','MarkerEdgeColor', ...
        plot_labels{count}, 'MarkerFaceColor', plot_labels{count});
    hold on;
end

title('Scatterplot of the segmented pixels in ''a*b*'' space');
xlabel('''a*''values');
ylabel('''b*''values');










