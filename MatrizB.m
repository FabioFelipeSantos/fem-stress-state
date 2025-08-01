function [B_f, B_c] = MatrizB(tipo, noel, ngl_no, N, dN_dx, dN_dy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que calcula a matriz B baseada nas derivadas de forma da fun��o. Essa matriz
%   ir� depender do tipo de estrutura a ser analisada e do n�mero de graus de liberdade a
%   que est� sujeito cada n� do modelo. H� dois tipos de matriz B: a de flex�o e a de
%   cisalhamento, B_f e B_c, respectivamente.
%
%   Entradas:
%       tipo - tipo de estrutura sendo analisada;
%       noel - n�mero de n�s por elemento do modelo;
%       ngl_no - n�mero de graus de liberdade de cada n� do elemento;
%       dN_dx - valor num�rico da derivada em rela��o � x da fun��o de forma;
%       dN_dy - valor num�rico da derivada em rela��o � y da fun��o de forma.
%
%   Sa�da:
%       B_f - matriz B de flex�o com as derivadas das fun��es de forma;
%       B_c - matriz B de cisalhamento com as derivadas das fun��es de forma;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch tipo
    case 'viga'
        % Inicializa��o das Matrizes
        B_f = zeros(3, noel * ngl_no);  % Matriz B de flex�o
        B_c = 0;                        % Matriz B de cisalhamento (nula para viga)
        
        for i = 1:noel      % La�o para os n�s do elemento
            i1 = (i - 1) * ngl_no + 1;        % Colhe o primeiro grau de liberdade do n�
            i2 = i1 + 1;                      % Colhe o segundo grau de liberdade do n�
            
            % Armazena as derivadas na matriz
            B_f(1, i1) = dN_dx(i);
            B_f(2, i2) = dN_dy(i);
            B_f(3, i1) = dN_dy(i);
            B_f(3, i2) = dN_dx(i);
        end
    case 'placa'
        % Inicializa��o das Matrizes
        B_f = zeros(6, noel * ngl_no);  % Matriz B de flex�o
        B_c = zeros(2, noel * ngl_no);  % Matriz B de cisalhamento
        
        for i = 1:noel      % La�o para os n�s do elemento
            i1 = (i - 1) * ngl_no + 1;       % Colhe o primeiro grau de liberdade do n�
            i2 = i1 + 1;                     % Colhe o segundo grau de liberdade do n�
            i3 = i2 + 1;                     % Colhe o terceiro grau de liberdade do n�
            i4 = i3 + 1;                     % Colhe o quarto grau de liberdade do n�
            i5 = i4 + 1;                     % Colhe o quinto grau de liberdade do n�
            
            % Monta a matriz B para flex�o
            B_f(1, i1) = dN_dx(i);
            B_f(2, i2) = dN_dy(i);
            B_f(3, i1) = dN_dy(i);
            B_f(3, i2) = dN_dx(i);
            B_f(4, i4) = dN_dx(i);
            B_f(5, i5) = dN_dy(i);
            B_f(6, i4) = dN_dy(i);
            B_f(6, i5) = dN_dx(i);
            
            % Monta a matriz B para cisalhamento
            B_c(1, i3) = dN_dy(i);
            B_c(1, i5) = N(i);
            B_c(2, i3) = dN_dx(i);
            B_c(2, i4) = N(i);
        end
end