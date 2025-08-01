function F_eq = Forcas(noel, xx, yy, ngl_elem, CargaDist, t, nQuadFle, dim)
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

% Matriz de funções de forma para cálculo das forças equivalentes
N_e = zeros(ngl_no, ngl_elem);      % Inicializa a matriz

% Inicializa o vetor de Forças equivalentes
F_eq = zeros(ngl_elem, 1);

% Armazena os valores para a integração numérica
[pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);

% Realiza a verificação se esse elemento possui cargas de tração em seus lados
if ~isempty(CargaDist)
    for i = 1:size(CargaDist, 1)        % Laço para cada carga concentrada
        %---------------------------------------------------------------------------------
        if CargaDist(i, 1) == 1     % Verifica se há cargas na direção X
            % Verifica se os lados do elemento coincidem com o lado de aplicação da carga
            aux_logico = xx(1:2) == CargaDist(i, 2);
            if sum(aux_logico) ~= 0     % Ativa o cálculo das cargas
                % Recolhe o valor da coordenada intrínseca xi (ou é -1 ou é 1)
                if aux_logico(1) == 1
                    xi = -1;
                else
                    xi = 1;
                end
                               
                % Colhe os nós do elemento que possuem a carga distribuída aplicada
                ind = find(abs(xx - CargaDist(i, 2)) < 1e-15);
                aux_carga = zeros(1, size(ind, 2));
                
                % Parcela nodal de carga (é suposto que a carga é linearmente distribuída)
                % Organiza em ordem as coordenadas y
                [aux_yy, aux_ind] = sort(yy(ind));
                % Diferença de cargas
                deltaC = CargaDist(i, 6) - CargaDist(i, 5);
                % Comprimento total do lado do elemento
                deltaY = CargaDist(i, 4) - CargaDist(i, 3);  
                
                % Cálcula a carga em cada nó do lado com a tração. Isso permite a criação
                % da função linear da carga
                for j = 1:size(ind, 2)          % Laço com a quantidade de nós
                    aux_carga(j) = (((aux_yy(j) - CargaDist(i, 3)) / deltaY) * deltaC) ...
                        + CargaDist(i, 5);
                end
                
                % Organiza as cargas nodais de acordo com os indices dos nós
                aux_carga = aux_carga(aux_ind);
                
                % Realiza a integração numérica para cálculo das forças equivalentes
                for intY = 1:nQuadFle       % Percorre os pontos de integração
                    % Valor da coordenada intrínseca eta (eixo de integração y)
                    eta = pontos_Fle(intY);
                    % Peso para essa coordenada
                    pesoY = weight_Fle(intY);
                    
                    % Cálcula as funções de forma
                    [N, dN_dxi, dN_deta] = shapefunctions(noel, xi, eta);
                    
                    % Cálculo da matriz Jacobiana da transformação de coordenadas
                    Jacob = Jacobian(noel, dN_dxi, dN_deta, xx, yy);
                    
                    % Calcula o determinante e a matriz inversa da matriz Jacobiana. Como
                    % a tração é em somente uma direção o determinante será o próprio
                    % valor da derivada da função de forma em relação à direção
                    detJacob = Jacob(2, 2);
                    
                    % Variável auxiliar que guardará os graus de liberdade
                    ind = zeros(1, ngl_no);             
                    for j = 1:noel          % Laço para os nós do elemento
                        ind(1) = (j - 1) * ngl_no + 1;      % Primeiro grau de liberdade
                        
                        for kk = 1:(ngl_no - 1)   % Laço para os demais graus de liberdade
                            ind(kk + 1) = ind(kk) + 1;     % (j+1)-ésimo grau de liberdade
                        end
                        
                        for k = 1:ngl_no          % Laço para os graus de liberdade por nó
                            N_e(k, ind(k)) = N(j);  % Armazena a função de forma na matriz
                        end
                    end
                    
                    % Inicializa o vetor de cargas nos nós do elemento
                    C_e = zeros(ngl_no, 1);
                    
                    % Cálcula o valor da função linear de carga
                    C_e(CargaDist(i, 1)) = ...
                              0.5 * ((1 - eta) * aux_carga(1) + (1 + eta) * aux_carga(2));
                    
                    % Cálculo da Força Equivalente
                    F_eq = F_eq + t * N_e' * C_e * pesoY * detJacob;
                end
            end
        %---------------------------------------------------------------------------------
        elseif CargaDist(i, 1) == 2     % Verifica se há cargas na direção Y
            aux_logico = yy(2:3) == CargaDist(i, 2);
            if sum(aux_logico) ~= 0                
                % Recolhe o valor da coordenada intrínseca xi (ou é -1 ou é 1)
                if aux_logico(1) == 1
                    eta = -1;
                else
                    eta = 1;
                end
                
                % Colhe os nós do elemento que possuem a carga distribuída aplicada
                ind = find(abs(yy - CargaDist(i, 2)) < 1e-15);
                aux_carga = zeros(1, size(ind, 2));
                
                % Parcela nodal de carga (é suposto que a carga é linearmente distribuída)
                % Organiza em ordem as coordenadas x
                [aux_xx, aux_ind] = sort(xx(ind));
                % Diferença de cargas
                deltaC = CargaDist(i, 6) - CargaDist(i, 5);
                % Comprimento total do lado do elemento
                deltaY = CargaDist(i, 4) - CargaDist(i, 3);
                
                % Cálcula a carga em cada nó do lado com a tração. Isso permite a criação
                % da função linear da carga
                for j = 1:size(ind, 2)          % Laço com a quantidade de nós
                    aux_carga(j) = (((aux_xx(j) - CargaDist(i, 3)) / deltaY) * deltaC) ...
                        + CargaDist(i, 5);
                end
                
                % Organiza as cargas nodais de acordo com os indices dos nós
                aux_carga = aux_carga(aux_ind);
                
                % Realiza a integração numérica para cálculo das forças equivalentes
                for intX = 1:nQuadFle       % Percorre os pontos de integração
                    % Valor da coordenada intrínseca eta (eixo de integração y)
                    xi = pontos_Fle(intX);
                    % Peso para essa coordenada
                    pesoX = weight_Fle(intX);
                    
                    % Cálcula as funções de forma
                    [N, dN_dxi, dN_deta] = shapefunctions(noel, xi, eta);
                    
                    % Cálculo da matriz Jacobiana da transformação de coordenadas
                    Jacob = Jacobian(noel, dN_dxi, dN_deta, xx, yy);
                    
                    % Calcula o determinante e a matriz inversa da matriz Jacobiana. Como
                    % a tração é em somente uma direção o determinante será o próprio
                    % valor da derivada da função de forma em relação à direção
                    detJacob = Jacob(1, 1);
                    
                    % Variável auxiliar que guardará os graus de liberdade
                    ind = zeros(1, ngl_no);             
                    for j = 1:noel          % Laço para os nós do elemento
                        ind(1) = (j - 1) * ngl_no + 1;      % Primeiro grau de liberdade
                        
                        for kk = 1:(ngl_no - 1)   % Laço para os demais graus de liberdade
                            ind(kk + 1) = ind(kk) + 1;     % (j+1)-ésimo grau de liberdade
                        end
                        
                        for k = 1:ngl_no          % Laço para os graus de liberdade por nó
                            N_e(k, ind(k)) = N(j);  % Armazena a função de forma na matriz
                        end
                    end
                    
                    % Inicializa o vetor de cargas nos nós do elemento
                    C_e = zeros(ngl_no, 1);
                    
                    % Cálcula o valor da função linear de carga
                    C_e(CargaDist(i, 1)) = ...
                                0.5 * ((1 - xi) * aux_carga(1) + (1 + xi) * aux_carga(2));
                    
                    % Cálculo da Força Equivalente
                    F_eq = F_eq + t * N_e' * C_e * pesoX * detJacob;
                end
            end
        end
        %---------------------------------------------------------------------------------
    end
end













