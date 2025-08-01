function indices = GrausLiberdade(nos, noel, ngl_no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Função responsável por calcular os índices dos graus de liberdade do elemento sendo
%	analisado.
%
%   Entrada:
%       nos - numeração dos nós do elemento;
%       noel - número de nós por elemento;
%       ngl_no - número de graus de liberdade por elemento
%
%   Saída:
%       indices - vetor contendo os índices dos GL.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicializa o vetor de índices
indices = zeros(1, noel * ngl_no);

% Variável que controla o elemento do vetor de índices 
k = 0;
for i = 1:noel      % Laço que percorres os nós do elemento  
    % Variável auxiliar para o cálculo
    start = (nos(i) - 1) * ngl_no;
    
    for j = 1:ngl_no        % Laço que percorre os graus de liberdade
        k = k+1;            % Atualiza a posição do vetor
        indices(k) = start + j;     % Armazena os índices
    end
end