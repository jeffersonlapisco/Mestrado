close all; clear all; clc; addpath('..');

%% Pr�-processamento
dados = carregaDados('iris2D.data', 4);



%% Configura��es gerais
metodo = 'QP';
fkernel = 'rbf';
atributos = [3 4];
paraC = 0.1250;
sigma = 0.5;

%% Superf�cie de decis�o
dados.x = dados.x(:, atributos);

[dadosTrein, dadosTeste] = embaralhaDados(dados, 0.8, 2)
if (strcmp('rbf', fkernel) == 1)
    
    modelo = svmtrain(dadosTrein.x, dadosTrein.y,'kernel_function',...
        fkernel,'rbf_sigma',sigma,'boxconstraint',paraC,...
        'method',metodo,'kernelcachelimit',15000, 'ShowPlot',true);
else
    modelo = svmtrain(dadosTrein.x, dadosTrein.y,'kernel_function',...
        fkernel,'boxconstraint',paraC,'method',metodo,...
        'kernelcachelimit',15000, 'ShowPlot',true);
end

xlabel(sprintf('Atributo %d', atributos(1)), 'FontSize', 16)
ylabel(sprintf('Atributo %d', atributos(2)), 'FontSize', 16)
title(sprintf('SVM/%s/%s',metodo, fkernel), 'FontSize', 20)

%% Teste
Yh = svmclassify(modelo, dadosTeste.x);

matConf = confusionmat(dadosTeste.y, Yh);
acuracia = trace(matConf) / size(Yh,1)