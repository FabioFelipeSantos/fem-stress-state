function [K_g, F_g] = Sobreposicao(K_g, F_g, K_e, F_e, indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que realiza a sobreposi��o da Matriz de Rigidez e do Vetor de For�as do
%   elemento sobre a Matriz de Rigidez e Vetor de For�a global do modelo.
%
%   Entrada:
%       K_g - matriz de rigidez global;
%       F_g - vetor de for�as global;
%       K_e - matriz de rigidez do elemento;
%       F_e - vetor de for�as do elemento;
%       indices - vetor com os �ndices dos graus de liberdade do elemento.
%
%   Sa�da:
%       K - matriz de rigidez global;
%       F - vetor de for�as global;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C�lcula o n�mero de graus dde liberdade do elemento
ngl_elem = length(indices);

for i = 1:ngl_elem      % La�o que percorre todos os graus de liberdade do elemento
    % Recolhe o �ndice do grau de liberdade para a linha
    ii = indices(i);
    
    % Realiza a sobreposi��o do vetor de for�a
    F_g(ii) = F_g(ii) + F_e(i);
    
    for j=1:ngl_elem    % La�o que percorre todos os graus de liberdade do elemento
        % Recolhe o �ndice do grau de liberdade para a coluna
        jj = indices(j);
        
        % Realiza a sobreposi��o da matriz de rigidez
        K_g(ii, jj) = K_g(ii, jj) + K_e(i, j);
    end
end
end