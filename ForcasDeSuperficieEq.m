function [N_e, C_e] = ForcasDeSuperficieEq(noel, ngl_elem, N, P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o respons�vel por montar o vetor de for�as aplicadas nos n�s do elemento devido a
%   a��o de tra��o na superf�cie (cargas distribu�das)
%
%   Entrada:
%       ngl_elem - n�mero de graus de liberdade do elemento
%       N - fun��es de forma do elemento;
%       CargaConc - cargas concentradas aplicadas na estrutura;
%       CargaDist - cargas distribui�das aplicadas sobre a estrutura.
%
%   Sa�da:
%       F_e - vetor com as for�as aplicadas no elemento
%
%   Vari�veis Globais:
%       InfoMesh - informa��es sobre a malha do modelo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcula o n�mero de graus de liberdade por n�
ngl_no = ngl_elem / noel;

% Inicializa o vetor de cargas nos n�s do elemento
C_e = zeros(ngl_elem, 1);

% Monta a matriz de fun��es de forma para c�lculo das for�as equivalentes
N_e = zeros(ngl_no, ngl_elem);      % Inicializa a matriz
ind = zeros(1, ngl_no);             % Vari�vel auxiliar que guardar� os graus de liberdade
for i = 1:noel          % La�o para os n�s do elemento
    ind(1) = (i - 1) * ngl_no + 1;      % Primeiro grau de liberdade
    
    for j = 1:(ngl_no - 1)              % La�o para os demais graus de liberdade
        ind(j + 1) = ind(j) + 1;        % (j+1)-�simo grau de liberdade
    end
    
    for k = 1:ngl_no                    % La�o para os graus de liberdade por n�
        N_e(k, ind(k)) = N(i);          % Armazena a fun��o de forma na matriz
    end
end
end