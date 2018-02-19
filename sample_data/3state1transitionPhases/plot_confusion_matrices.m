%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% University of Leeds
% School of Mechanical Engineering
% Institute of Design, Robotics and Optimisation (iDRO)
%
% author: Uriel Martinez-Hernandez
% program name: plot_confusion_matrices.m
% date: February 2018
% version: 1.0
%
% This program is part of the project 'Wearable soft robotics for
% independent living' funded by EPSRC.
%
% Description:
% This program plots the results obtained from the Bayesian classifier
% employed for recognition of sit-to-stand activity and transition during
% sit to stand. The results are shown using confusion matrices in white
% (0% accuracy) and black (100% accuracy) colours.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

hist_value = 50;

myData = load(['output_histBin_' num2str(hist_value) '_testing.mat']);

numOfThresholds = size(myData.output_all,2);

threshold_value = numOfThresholds;

%% For class
classMat = myData.output_all{1,threshold_value}.confusion_mat_class;

tMat = zeros(size(classMat));
tMat_fullValues = zeros(1, size(classMat,1));
accMat = 0;

for i=1:size(classMat,1)
    tMat_fullValues(1,i) = sum(classMat(i,:));
end

for i=1:size(classMat,1)
    for j=1:size(classMat,2)
        tMat(i,j) = (classMat(i,j)*100)/tMat_fullValues(1,i);
    end
end

for i=1:size(classMat,1)
    accMat = accMat + tMat(i,i);
end

accMat = accMat/size(classMat,1);


hf1 = figure(1);
imagesc(tMat)
colormap bone
colormap(flipud(colormap));
axis([0.5 (size(classMat,1)+0.5) 0.5 (size(classMat,1)+0.5)]);

axis square
title(['State recognition'], 'fontsize',16, 'fontname', 'times');
set(gca, 'xticklabel', '', 'yticklabel', '', 'fontname', 'times', 'fontsize', 13)

% x axis
text(0.95, 3.59, 'sit', 'color', 'k', 'fontname', 'times', 'fontsize', 13);
text(1.85, 3.59, 'stand', 'color', 'k', 'fontname', 'times', 'fontsize', 13);
text(2.75, 3.59, 'transition', 'color', 'k', 'fontname', 'times', 'fontsize', 13);
text(1.65, 3.77, 'predicted state', 'color', 'k', 'fontname', 'times', 'fontsize', 13);

% y axis
text(0.37, 1.08, 'sit', 'color', 'k', 'fontname', 'times', 'fontsize', 13, 'rotation',90);
text(0.37, 2.17, 'stand', 'color', 'k', 'fontname', 'times', 'fontsize', 13, 'rotation',90);
text(0.37, 3.25, 'transition', 'color', 'k', 'fontname', 'times', 'fontsize', 13, 'rotation',90);
text(0.16, 2.3, 'actual state', 'color', 'k', 'fontname', 'times', 'fontsize', 13, 'rotation',90);

for i=1:size(tMat,1)
    for j=1:size(tMat,2)
        if( tMat(j,i) <= 50 )
            if( tMat(j,i) == 0 )
                text(i-0.05, j, [num2str(tMat(j,i),3) '%'], 'Color', 'k', 'FontName', 'times', 'FontSize', 12)
            else
                text(i-0.15, j, [num2str(tMat(j,i),3) '%'], 'Color', 'k', 'FontName', 'times', 'FontSize', 12)
            end
        else
            if( tMat(j,i) == 0 )
                text(i-0.05, j, [num2str(tMat(j,i),3) '%'], 'Color', 'w', 'FontName', 'times', 'FontSize', 12)
            else
                text(i-0.15, j, [num2str(tMat(j,i),3) '%'], 'Color', 'w', 'FontName', 'times', 'FontSize', 12)
            end
        end
    end
end
cc = colorbar;
cc.Label.String = 'accuracy (%)';
cc.Label.FontSize = 14;
cc.Label.FontName = 'times';



%% For subclass

subClassMat = myData.output_all{1,threshold_value}.confusion_mat_subclass;

stMat = zeros(size(subClassMat));
stMat_fullValues = zeros(1, size(subClassMat,1));
accStMat = 0;

for i=1:size(subClassMat,1)
    stMat_fullValues(1,i) = sum(subClassMat(i,:));
end

for i=1:size(subClassMat,1)
    for j=1:size(subClassMat,2)
        stMat(i,j) = (subClassMat(i,j)*100)/stMat_fullValues(1,i);
    end
end

for i=1:size(subClassMat,1)
    accStMat = accStMat + stMat(i,i);
end
accStMat = accStMat/size(subClassMat,1);

hf2 = figure(2);
imagesc(stMat)
colormap bone
colormap(flipud(colormap));
axis([0.5 (size(subClassMat,1)+0.5) 0.5 (size(subClassMat,1)+0.5)]);
title(['Stand-to-sit (subphases) - ' num2str(accStMat) '%'], 'fontsize',14);
set(gca, 'xtick',[1:1:size(subClassMat,1)], 'ytick',[1:1:size(subClassMat,1)])
xlabel('target state','fontsize',12);
ylabel('output state','fontsize',12);

