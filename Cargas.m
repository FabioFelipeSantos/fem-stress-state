function [CargaDist, CargaConc] = Cargas()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que armazena as cargas aplicadas sobre a estrutura.
%
%   Somente ser�o passadas cargas distribu�das ou concentradas.
%--------------------------------Cargas Distribu�das--------------------------------------
%   As cargas distribu�das dever�o ser passadas em uma matriz que possui 6 colunas com
%   cada linha representando uma carga. As colunas representar�o as seguintes informa��es:
%       1 - Dire��o da carga: Poder� ser os valores
%                             1 - Dire��o X, 2 - Dire��o Y, 3 - Dire��o Z.
%       2 - Valor da coordenada perpendicular � dire��o da carga. Se a carga for na
%       dire��o X ent�o deve-se ter 0 ou L (ou seja, x = 0 ou x = h), se a carga for na 
%       dire��o Y ent�o deve-se ter 0 ou h (ou seja, y = 0 ou y = L). Se a carga for na
%       dire��o Z ela ser� tratada como uma press�o uniformemente distribu�da sobre a
%       superf�cie, portanto coloque 0 nesse caso.
%       3 - Ponto inicial de aplica��o das cargas (SOMENTE PARA CARGAS NA DIRE��O X OU Y).
%       Dever� ser um valor num�rico entre 0 e L para cargas na dire��o Y e um valor entre
%       0 e h para cargas na dire��o X. Esses valores dever�o coincidir com pontos em
%       elementos do modelo discretizado.
%       4 - Ponto final de aplica��o das cargas (SOMENTE PARA CARGAS NA DIRE��O X OU Y).
%       Dever� ser um valor num�rico entre o ponto inicial e L para cargas na dire��o Y e 
%       um valor entre ponto inicial e h para cargas na dire��o X. Esses valores dever�o
%       coincidir com pontos em elementos do modelo discretizado.
%       5 - Valor da carga inicial. Dever� ser um valor em N / m para cargas nas dire��es 
%       X ou Y e um valor em N / m^2 para cargas na dire��o Z.
%       6 - Valor da carga final. Dever� ser um valor em N / m para cargas nas dire��es X
%       ou Y. N�o precisa informar valor para Z (n�o ser� lido).
%
%----------------------------------Cargas Concentradas------------------------------------
%   As cargas concentradas s� poder�o ser aplicadas sobre n�s dos elementos do modelo
%   discretizado. Portanto dever� ser informada em forma de matriz com 3 colunas onde cada
%   linha ser� uma carga diferente. As colunas dever�o representar:
%       1 - N� de aplica��o da carga.
%       2 - Dire��o de aplica��o da carga: Poder� ser os valores
%                                          1 - Dire��o X, 2 - Dire��o Y, 3 - Dire��o Z
%       3 - Valor da carga em N.
%
%   OBSERVA��O: 1 - As cargas dever�o ser informadas com seus respectivos sinais, ou seja,
%   uma carga positiva � aplicada no mesmo sentido da dire��o do eixo de aplica��o da 
%   carga enquanto uma carga negativa � aplicada no sentido oposto da dire��o do eixo de 
%   aplica��o da carga. Este c�digo n�o est� programado para tratar cargas de momento de
%   nunhuma esp�cie;
%       2 - S� ser� computada uma �nica carga distribu�da na dire��o Z, que ser� tratada
%       como uma press�o uniforme sobre a superf�cie de refer�ncia, ent�o garanta que a 
%       mesma seja a primeira carga a aparecer na matriz CargaDist;
%       3 - Se a carga for distribu�da na dire��o Z (press�o) ent�o s� ser�o lidos os
%       valores das colunas 1 e 5, portanto coloque qualquer outro valor nas colunas 2, 3,
%       4 e 6.
%
%   Sa�da da Fun��o:
%       CargaDist - matriz com as informa��es sobre as cargas distribu�das;
%       CargaConc - matriz com as informa��es sobre as cargas concentradas.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicializa as cargas como vari�veis vazias. Se caso nenhuma carga for aplicada elas
% ser�o passadas para o programa vazias.
CargaDist = [];
CargaConc = [];

% Cargas Concentradas
% CargaConc(1, 1) = 3;  CargaConc(1, 2) = 1; CargaConc(1, 3) = 200;
% CargaConc(2, 1) = 6;  CargaConc(2, 2) = 1; CargaConc(2, 3) = 200;
% CargaConc(3, 1) = 9;  CargaConc(3, 2) = 1; CargaConc(3, 3) = 200;
% CargaConc(4, 1) = 18; CargaConc(4, 2) = 1; CargaConc(4, 3) = 200;
% CargaConc(5, 1) = 21; CargaConc(5, 2) = 1; CargaConc(5, 3) = 200;

% Cargas Distribu�das
% CargaDist(1, 1) = 2;        % Dire��o Y
% CargaDist(1, 2) = 0.4;      % Valor da coordenada Y de aplica��o
% CargaDist(1, 3) = 0;        % Coordenada X inicial
% CargaDist(1, 4) = 2;        % Coordenada X final
% CargaDist(1, 5) = 2e3;      % Valor inicial da carga em N/m
% CargaDist(1, 6) = 2e3;      % Valor final da carga em N/m


% CargaDist(1, 1) = 1;        % Dire��o X
% CargaDist(1, 2) = 2;        % Valor da coordenada X de aplica��o
% CargaDist(1, 3) = 0;        % Coordenada Y inicial
% CargaDist(1, 4) = 0.4;      % Coordenada Y final
% CargaDist(1, 5) = 4e3;      % Valor inicial da carga em N/m
% CargaDist(1, 6) = 4e3;      % Valor final da carga em N/m
% 
% CargaDist(2, 1) = 2;        % Dire��o Y
% CargaDist(2, 2) = 0.4;      % Valor da coordenada Y de aplica��o
% CargaDist(2, 3) = 0;        % Coordenada X inicial
% CargaDist(2, 4) = 2;        % Coordenada X final
% CargaDist(2, 5) = 2e3;      % Valor inicial da carga em N/m
% CargaDist(2, 6) = 2e3;      % Valor final da carga em N/m
% 
CargaDist(3, 1) = 3;        % Dire��o Z
CargaDist(3, 2) = -1;       % Valor n�o lido pelo programa
CargaDist(3, 3) = -1;       % Valor n�o lido pelo programa
CargaDist(3, 4) = -1;       % Valor n�o lido pelo programa
CargaDist(3, 5) = 0.2;      % Valor inicial da carga em N/m^2
CargaDist(3, 6) = -1;       % Valor n�o lido pelo programa
end