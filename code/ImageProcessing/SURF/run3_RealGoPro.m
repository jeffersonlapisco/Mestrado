clear all; close all; clc;
p = path; path(p, '../'); path(p, '../utils/');

%% General configurations
numRep = 4;
nameImgs = 'real_gopro';
pathData = sprintf('/Users/leandrobm/Documents/dados/SURF_%s/desc_surf_%s_', nameImgs, nameImgs);
k = 1;


%% Load the images
load(sprintf('../../../data/descInd_%s', nameImgs));
data.imgs = imgsInd;
data.labels = labels;

% Initializes variables
numClass = length(unique(labels));
matConfPorc = zeros(numClass,numClass,numRep);
metrics = zeros(numClass, 6, numRep);
generalMetrics = zeros(numRep, 6);
confMatTest = zeros(numClass, numClass, numRep);
timeTest = zeros(1, numRep);

%% Steps
for i = 1 : numRep
    %% Shuffle the imagens
    [trainData, testData] = shuffleImgs(data, k, false);      
    
    %% Train
    [model] = trainSURF(trainData, pathData);
    
    %% Test
    fprintf('SURF - step %d.\n', i);
    tic
    [Y, t] = testSURF_ind(model, testData, k, pathData);
    timeTest(i) = mean(t);
    confMatTest(:,:,i) = confusionmat(testData.labels', Y');
    
    
    %% Metrics
    matConfPorc(:,:,i) = (confMatTest(:,:,i)./length(testData.labels)).*100;
    [metrics(:,:,i), generalMetrics(i,:)] = metricasMatConf(confMatTest(:,:,i));
    
    save(sprintf('surf_gray_%s', nameImgs));
end

% Resultado geral
result.metricasGeralMedia = mean(generalMetrics);

result.matConfTeste = confMatTest;
result.matConfPorc = matConfPorc;
result.metricas = metrics;
result.metricasGeral = generalMetrics;

% Procura a matriz de confus?o mais pr?xima da acc m?dia
acc = generalMetrics(:,end);
mediaAcc = mean(acc);
[~, pos] = sort( abs ( mediaAcc - acc) );

result.matConfTesteMedia2 = confMatTest(:,:,pos(1));
result.stdAcc = std(acc);

result.timeTest = timeTest;

save(sprintf('surf_gray_%s', nameImgs));

path(p);