addpath('vlfeat/toolbox');vl_setup;
clear; close all; clc;
p = path; path(p, '../'); path(p, '../../utils/');

%% General configurations
numRep = 10;
nnThreshold = 0.8;
nameImgs = 'real_gopro';
numK = 1;
routes{1} = [8 7 3 4];
routes{2} = [1 6 10 9];
routes{3} = [5 2 11 12];
routes{4} = [5 1 6 9 10];
routes{5} = [8 7 2 11 12];
routes{6} = [13 15 3 4 5 1];
routes{7} = [8 7 3 2 11 12];
routes{8} = [9 8 7 2 11 15 3];
routes{9} = [2 11 14 13 15 3];
routes{10} = [12 11 15 3 4 5 1 6 10];


%% Load the images
load(sprintf('../../../data/descInd_%s', nameImgs));
data.imgs = imgsInd;
data.labels = labels;

% Initializes variables
numClass = length(unique(labels));

%% Steps
for i = 1 : length(routes)
    for j = 1 : numRep
        %% Shuffle the imagens
        [trainData, testData] = shuffleImgs(data, numK, false);

        testAux.imgs = [];
        for k = 1 : length(routes{i})
            inds = find(testData.labels == routes{i}(k));
            
            testAux.imgs = [testAux.imgs; testData.imgs(inds(randperm(length(inds), 1)))];
        end
        testAux.labels = routes{i}';
        testData = testAux; clear testAux;
        

        %% Train
        fprintf('SIFT (Treino): %d - %d\n', i, j);
        tic
        [model] = trainSIFT_route(trainData, nameImgs);
        toc
        
        %% Test
        fprintf('SIFT (Teste): %d - %d\n', i, j);
        [Y, ~, y_] = testSIFT(model, testData, numK, nnThreshold, nameImgs);

        hit(j) = (sum(Y == testData.labels') == length(Y));
        if hit(j)
            hitRej(j) = hit(j);
        else
            indNotHit = find((Y == testData.labels') == 0);
            
            Y(indNotHit) = y_(indNotHit, 2)';
            
            hitRej(j) = (sum(Y == testData.labels') == length(Y));
        end
        
        save(sprintf('sift_route_%s', nameImgs));
    end
    
    % Result by route
    route{i}.hit = double(hit);
    route{i}.hitRej = double(hitRej);
    
    save(sprintf('sift_route_%s', nameImgs));

end
clear model labels
result.routes = route;
save(sprintf('sift_route_%s', nameImgs));

path(p);