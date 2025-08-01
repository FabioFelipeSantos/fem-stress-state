function [B_f, B_c] = MatrizB(tipo, noel, ngl_no, N, dN_dx, dN_dy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que calcula a matriz B baseada nas derivadas de forma da função. Essa matriz
%   irá depender do tipo de estrutura a ser analisada e do número de graus de liberdade a
%   que está sujeito cada nó do modelo. Há dois tipos de matriz B: a de flexão e a de
%   cisalhamento, B_f e B_c, respectivamente.
%
%   Entradas:
%       tipo - tipo de estrutura sendo analisada;
%       noel - número de nós por elemento do modelo;
%       ngl_no - número de graus de liberdade de cada nó do elemento;
%       dN_dx - valor numérico da derivada em relação à x da função de forma;
%       dN_dy - valor numérico da derivada em relação à y da função de forma.
%
%   Saída:
%       B_f - matriz B de flexão com as derivadas das funções de forma;
%       B_c - matriz B de cisalhamento com as derivadas das funções de forma;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch tipo
    case 'viga'
        % Inicialização das Matrizes
        B_f = zeros(3, noel * ngl_no);  % Matriz B de flexão
        B_c = 0;                        % Matriz B de cisalhamento (nula para viga)
        
        for i = 1:noel      % Laço para os nós do elemento
            i1 = (i - 1) * ngl_no + 1;        % Colhe o primeiro grau de liberdade do nó
            i2 = i1 + 1;                      % Colhe o segundo grau de liberdade do nó
            
            % Armazena as derivadas na matriz
            B_f(1, i1) = dN_dx(i);
            B_f(2, i2) = dN_dy(i);
            B_f(3, i1) = dN_dy(i);
            B_f(3, i2) = dN_dx(i);
        end
    case 'placa'
        % Inicialização das Matrizes
        B_f = zeros(6, noel * ngl_no);  % Matriz B de flexão
        B_c = zeros(2, noel * ngl_no);  % Matriz B de cisalhamento
        
        for i = 1:noel      % Laço para os nós do elemento
            i1 = (i - 1) * ngl_no + 1;       % Colhe o primeiro grau de liberdade do nó
            i2 = i1 + 1;                     % Colhe o segundo grau de liberdade do nó
            i3 = i2 + 1;                     % Colhe o terceiro grau de liberdade do nó
            i4 = i3 + 1;                     % Colhe o quarto grau de liberdade do nó
            i5 = i4 + 1;                     % Colhe o quinto grau de liberdade do nó
            
            % Monta a matriz B para flexão
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