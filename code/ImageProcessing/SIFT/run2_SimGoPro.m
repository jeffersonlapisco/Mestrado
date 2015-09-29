clear all; close all; clc;
p = path; path(p, '../'); path(p, '../utils/');


%% General configurations
numRep = 10;
nnThreshold = 0.8;
nameImgs = 'sim_gopro';
k = 1;


%% Load the images
load(sprintf('../dados/desc_sift_%s', nameImgs));
data.imgs = imgsDescr;
data.labels = labels;
averageTimExte = mean(timeExt);

% Initializes variables
numClass = length(unique(labels));
matConfPorc = zeros(numClass,numClass,numRep);
metrics = zeros(numClass, 6, numRep);
generalMetrics = zeros(numRep, 6);
confMatTest = zeros(numClass, numClass, numRep);
timeTest = zeros(1, numRep);
timeTrain = zeros(1, numRep);

%% Steps
for i = 1 : numRep
    %% Shuffle the imagens
    [trainData, testData] = shuffleImgs(data, k);        
    
    %% Test
    fprintf('SIFT - step %d.\n', i);
    tic
    [Y, t] = testSIFT(trainData, testData, k, nnThreshold);
    timeTest(i) = mean(t);
    confMatTest(:,:,i) = confusionmat(testData.labels', Y');
    
    
    %% Metrics
    matConfPorc(:,:,i) = (confMatTest(:,:,i)./length(testData.labels)).*100;
    [metrics(:,:,i), generalMetrics(i,:)] = metricasMatConf(confMatTest(:,:,i));
    
    save(sprintf('sift_gray_%s', nameImgs));
end

% Resultado geral
result.metricasGeralMedia = mean(generalMetrics);

result.matConfTeste = confMatTest;
result.matConfPorc = matConfPorc;
result.metricas = metrics;
result.metricasGeral = generalMetrics;

% Procura a matriz de confus�o mais pr�xima da acc m�dia
acc = generalMetrics(:,end);
mediaAcc = mean(acc);
[~, pos] = sort( abs ( mediaAcc - acc) );

result.matConfTesteMedia2 = confMatTest(:,:,pos(1));
result.stdAcc = std(acc);

result.timeTest = timeTest;
result.timeTrain = timeTrain;

save(sprintf('sift_gray_%s', nameImgs));

path(p)