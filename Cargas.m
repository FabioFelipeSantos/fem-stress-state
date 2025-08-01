function [CargaDist, CargaConc] = Cargas()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que armazena as cargas aplicadas sobre a estrutura.
%
%   Somente serão passadas cargas distribuídas ou concentradas.
%--------------------------------Cargas Distribuídas--------------------------------------
%   As cargas distribuídas deverão ser passadas em uma matriz que possui 6 colunas com
%   cada linha representando uma carga. As colunas representarão as seguintes informações:
%       1 - Direção da carga: Poderá ser os valores
%                             1 - Direção X, 2 - Direção Y, 3 - Direção Z.
%       2 - Valor da coordenada perpendicular à direção da carga. Se a carga for na
%       direção X então deve-se ter 0 ou L (ou seja, x = 0 ou x = h), se a carga for na 
%       direção Y então deve-se ter 0 ou h (ou seja, y = 0 ou y = L). Se a carga for na
%       direção Z ela será tratada como uma pressão uniformemente distribuída sobre a
%       superfície, portanto coloque 0 nesse caso.
%       3 - Ponto inicial de aplicação das cargas (SOMENTE PARA CARGAS NA DIREÇÃO X OU Y).
%       Deverá ser um valor numérico entre 0 e L para cargas na direção Y e um valor entre
%       0 e h para cargas na direção X. Esses valores deverão coincidir com pontos em
%       elementos do modelo discretizado.
%       4 - Ponto final de aplicação das cargas (SOMENTE PARA CARGAS NA DIREÇÃO X OU Y).
%       Deverá ser um valor numérico entre o ponto inicial e L para cargas na direção Y e 
%       um valor entre ponto inicial e h para cargas na direção X. Esses valores deverão
%       coincidir com pontos em elementos do modelo discretizado.
%       5 - Valor da carga inicial. Deverá ser um valor em N / m para cargas nas direções 
%       X ou Y e um valor em N / m^2 para cargas na direção Z.
%       6 - Valor da carga final. Deverá ser um valor em N / m para cargas nas direções X
%       ou Y. Não precisa informar valor para Z (não será lido).
%
%----------------------------------Cargas Concentradas------------------------------------
%   As cargas concentradas só poderão ser aplicadas sobre nós dos elementos do modelo
%   discretizado. Portanto deverá ser informada em forma de matriz com 3 colunas onde cada
%   linha será uma carga diferente. As colunas deverão representar:
%       1 - Nó de aplicação da carga.
%       2 - Direção de aplicação da carga: Poderá ser os valores
%                                          1 - Direção X, 2 - Direção Y, 3 - Direção Z
%       3 - Valor da carga em N.
%
%   OBSERVAÇÃO: 1 - As cargas deverão ser informadas com seus respectivos sinais, ou seja,
%   uma carga positiva é aplicada no mesmo sentido da direção do eixo de aplicação da 
%   carga enquanto uma carga negativa é aplicada no sentido oposto da direção do eixo de 
%   aplicação da carga. Este código não está programado para tratar cargas de momento de
%   nunhuma espécie;
%       2 - Só será computada uma única carga distribuída na direção Z, que será tratada
%       como uma pressão uniforme sobre a superfície de referência, então garanta que a 
%       mesma seja a primeira carga a aparecer na matriz CargaDist;
%       3 - Se a carga for distribuída na direção Z (pressão) então só serão lidos os
%       valores das colunas 1 e 5, portanto coloque qualquer outro valor nas colunas 2, 3,
%       4 e 6.
%
%   Saída da Função:
%       CargaDist - matriz com as informações sobre as cargas distribuídas;
%       CargaConc - matriz com as informações sobre as cargas concentradas.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicializa as cargas como variáveis vazias. Se caso nenhuma carga for aplicada elas
% serão passadas para o programa vazias.
CargaDist = [];
CargaConc = [];

% Cargas Concentradas
% CargaConc(1, 1) = 3;  CargaConc(1, 2) = 1; CargaConc(1, 3) = 200;
% CargaConc(2, 1) = 6;  CargaConc(2, 2) = 1; CargaConc(2, 3) = 200;
% CargaConc(3, 1) = 9;  CargaConc(3, 2) = 1; CargaConc(3, 3) = 200;
% CargaConc(4, 1) = 18; CargaConc(4, 2) = 1; CargaConc(4, 3) = 200;
% CargaConc(5, 1) = 21; CargaConc(5, 2) = 1; CargaConc(5, 3) = 200;

% Cargas Distribuídas
% CargaDist(1, 1) = 2;        % Direção Y
% CargaDist(1, 2) = 0.4;      % Valor da coordenada Y de aplicação
% CargaDist(1, 3) = 0;        % Coordenada X inicial
% CargaDist(1, 4) = 2;        % Coordenada X final
% CargaDist(1, 5) = 2e3;      % Valor inicial da carga em N/m
% CargaDist(1, 6) = 2e3;      % Valor final da carga em N/m


% CargaDist(1, 1) = 1;        % Direção X
% CargaDist(1, 2) = 2;        % Valor da coordenada X de aplicação
% CargaDist(1, 3) = 0;        % Coordenada Y inicial
% CargaDist(1, 4) = 0.4;      % Coordenada Y final
% CargaDist(1, 5) = 4e3;      % Valor inicial da carga em N/m
% CargaDist(1, 6) = 4e3;      % Valor final da carga em N/m
% 
% CargaDist(2, 1) = 2;        % Direção Y
% CargaDist(2, 2) = 0.4;      % Valor da coordenada Y de aplicação
% CargaDist(2, 3) = 0;        % Coordenada X inicial
% CargaDist(2, 4) = 2;        % Coordenada X final
% CargaDist(2, 5) = 2e3;      % Valor inicial da carga em N/m
% CargaDist(2, 6) = 2e3;      % Valor final da carga em N/m
% 
CargaDist(3, 1) = 3;        % Direção Z
CargaDist(3, 2) = -1;       % Valor não lido pelo programa
CargaDist(3, 3) = -1;       % Valor não lido pelo programa
CargaDist(3, 4) = -1;       % Valor não lido pelo programa
CargaDist(3, 5) = 0.2;      % Valor inicial da carga em N/m^2
CargaDist(3, 6) = -1;       % Valor não lido pelo programa
end