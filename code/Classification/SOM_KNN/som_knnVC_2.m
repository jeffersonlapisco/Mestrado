function [ results ] = som_knnVC_2(dados, params, conf)

save('resultadoSOM-KNN_VC');
for i = 1 : conf.rodadas,    
    %% Embaralhando os dados
    [trainData{i}, testData{i}] = embaralhaDados(dados, conf.ptrn, 2);
    save('resultadoSOM-KNN_VC', '-append');

    %% Valida��o cruzada
    fprintf('Buscando a melhor topologia...\n')
    tic
    [optParams{i}, Evc{i}] = otimizadorSOMKNN(trainData{i}, params, conf.folds);
    
    %% Treinamento da SOM
    fprintf('Treinando a SOM_K-NN...\nRodada %d\n', i)
    [modelo{i}] = trainVC(trainData{i}, optParams{i}, conf.treinos, conf.ptrn);
    tempoTrein(i) = toc
    
    %% Testando a SOM
    fprintf('Testando a SOM...\nRodada %d\n\n', i)
    tic
    [Yh] = testeSOM_KNN(modelo{i}, testData{i});
    
    %% Matriz de confusao e acur�cia    
    confusionMatrices{i} = confusionmat(testData{i}.y, Yh);
    accuracy(i) = trace(confusionMatrices{i}) / length(find(Yh ~= 0))
    tempoTeste = toc
    save('resultadoSOM-KNN_VC', '-append');
end

meanAccuracy = mean(accuracy);

%% Procurando a matriz de confus�o mais pr�xima da acur�cia m�dia
[~, posicoes] = sort( abs ( meanAccuracy - accuracy ) );


%%
results.mean = meanAccuracy;
results.std = std(accuracy);
results.matrizConfuzaoMedia = confusionMatrices{posicoes(1)};
results.matrizConfuzao = confusionMatrices;

results.accuracy = accuracy;
results.optParams = optParams;
results.ErroVC = Evc;
results.modelos = modelo;
results.trainData = trainData;
results.testData = testData;
results.tempoTrein = tempoTrein;
results.tempoTeste = tempoTeste;

save('resultadoSOM-KNN_VC', '-append');

end
