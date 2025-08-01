function indices = GrausLiberdade(nos, noel, ngl_no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Fun��o respons�vel por calcular os �ndices dos graus de liberdade do elemento sendo
%	analisado.
%
%   Entrada:
%       nos - numera��o dos n�s do elemento;
%       noel - n�mero de n�s por elemento;
%       ngl_no - n�mero de graus de liberdade por elemento
%
%   Sa�da:
%       indices - vetor contendo os �ndices dos GL.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicializa o vetor de �ndices
indices = zeros(1, noel * ngl_no);

% Vari�vel que controla o elemento do vetor de �ndices 
k = 0;
for i = 1:noel      % La�o que percorres os n�s do elemento  
    % Vari�vel auxiliar para o c�lculo
    start = (nos(i) - 1) * ngl_no;
    
    for j = 1:ngl_no        % La�o que percorre os graus de liberdade
        k = k+1;            % Atualiza a posi��o do vetor
        indices(k) = start + j;     % Armazena os �ndices
    end
end