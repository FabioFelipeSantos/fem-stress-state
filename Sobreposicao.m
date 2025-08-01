function [K_g, F_g] = Sobreposicao(K_g, F_g, K_e, F_e, indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que realiza a sobreposição da Matriz de Rigidez e do Vetor de Forças do
%   elemento sobre a Matriz de Rigidez e Vetor de Força global do modelo.
%
%   Entrada:
%       K_g - matriz de rigidez global;
%       F_g - vetor de forças global;
%       K_e - matriz de rigidez do elemento;
%       F_e - vetor de forças do elemento;
%       indices - vetor com os índices dos graus de liberdade do elemento.
%
%   Saída:
%       K - matriz de rigidez global;
%       F - vetor de forças global;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cálcula o número de graus dde liberdade do elemento
ngl_elem = length(indices);

for i = 1:ngl_elem      % Laço que percorre todos os graus de liberdade do elemento
    % Recolhe o índice do grau de liberdade para a linha
    ii = indices(i);
    
    % Realiza a sobreposição do vetor de força
    F_g(ii) = F_g(ii) + F_e(i);
    
    for j=1:ngl_elem    % Laço que percorre todos os graus de liberdade do elemento
        % Recolhe o índice do grau de liberdade para a coluna
        jj = indices(j);
        
        % Realiza a sobreposição da matriz de rigidez
        K_g(ii, jj) = K_g(ii, jj) + K_e(i, j);
    end
end
end