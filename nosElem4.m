function [coordenadas4,iconec4] = nosElem4()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que realiza a construção da malha retangular de elementos finitos com 4 pontos
%   (malha retangular linear).
%
%   Entrada:
%       Não há entrada de variáveis.
%
%   Saída:
%       coordenadas4 - matriz de coordenadas x e y da malha retangular. Cada linha um nó;
%       iconec - matriz de conectividade dos elementos. Cada linha representa um elemento.
%
%	Variável Global:
%       InfoMesh - struct com as informações da malha de EF.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global InfoMesh

% Realiza a retirada dos dados da struct InfoMesh
numDeNos = InfoMesh.nosCanto;
numDeElem = InfoMesh.numDeElem;
numDeSubDivX = InfoMesh.numDeSubDivX;
numDeSubDivY = InfoMesh.numDeSubDivY;
compX = InfoMesh.compX;
compY = InfoMesh.compY;


coordenadas4 = zeros(numDeNos, 2);       % Cria a matriz de coordenadas
% Variáveis auxiliares para o cálculo dos nós
aux1 = 0;
aux2 = 0;       
%--------------------------------------------
% Cálculo dos valores das coordenadas de cada nó
for i = 1:numDeNos
    coordenadas4(i, 1) = compX * aux1;
    coordenadas4(i, 2) = compY * aux2;
    
    aux1 = aux1 + 1;
    if aux1 == numDeSubDivX + 1
        aux1 = 0;
        aux2 = aux2 + 1;
    end
end
% Criação da matriz de Conectivadade
iconec4 = zeros(numDeElem, 4);       % Matriz de Conectividade

% Variáveis auxiliares para o cálculo da conectividade
aux1 = 0;
aux2 = 1;
k = 1;
%-----------------------------------------------------
% Cálculo da conectividade de cada elemento
% Para os nós de conectividade inferiores
for i = 1:(numDeSubDivY)
    for j = 1:(numDeSubDivX)
        % Conectividades Inferiores
        iconec4(k,1) = j + aux1 * (numDeSubDivX + 1);
        iconec4(k,2) = iconec4(k,1) + 1;
        
        % Conectividades Superiores
        iconec4(k,4) = j + aux2 * (numDeSubDivX + 1);
        iconec4(k,3) = iconec4(k,4) + 1;
        k = k + 1;
    end
    aux1 = aux1 + 1;
    aux2 = aux2 + 1;
end