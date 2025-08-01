function [N_e, C_e] = ForcasDeSuperficieEq(noel, ngl_elem, N, P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função responsável por montar o vetor de forças aplicadas nos nós do elemento devido a
%   ação de tração na superfície (cargas distribuídas)
%
%   Entrada:
%       ngl_elem - número de graus de liberdade do elemento
%       N - funções de forma do elemento;
%       CargaConc - cargas concentradas aplicadas na estrutura;
%       CargaDist - cargas distribuiídas aplicadas sobre a estrutura.
%
%   Saída:
%       F_e - vetor com as forças aplicadas no elemento
%
%   Variáveis Globais:
%       InfoMesh - informações sobre a malha do modelo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcula o número de graus de liberdade por nó
ngl_no = ngl_elem / noel;

% Inicializa o vetor de cargas nos nós do elemento
C_e = zeros(ngl_elem, 1);

% Monta a matriz de funções de forma para cálculo das forças equivalentes
N_e = zeros(ngl_no, ngl_elem);      % Inicializa a matriz
ind = zeros(1, ngl_no);             % Variável auxiliar que guardará os graus de liberdade
for i = 1:noel          % Laço para os nós do elemento
    ind(1) = (i - 1) * ngl_no + 1;      % Primeiro grau de liberdade
    
    for j = 1:(ngl_no - 1)              % Laço para os demais graus de liberdade
        ind(j + 1) = ind(j) + 1;        % (j+1)-ésimo grau de liberdade
    end
    
    for k = 1:ngl_no                    % Laço para os graus de liberdade por nó
        N_e(k, ind(k)) = N(i);          % Armazena a função de forma na matriz
    end
end
end