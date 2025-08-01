function F_eq = Forcas(noel, xx, yy, ngl_elem, CargaDist, t, nQuadFle, dim)
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

% Matriz de fun��es de forma para c�lculo das for�as equivalentes
N_e = zeros(ngl_no, ngl_elem);      % Inicializa a matriz

% Inicializa o vetor de For�as equivalentes
F_eq = zeros(ngl_elem, 1);

% Armazena os valores para a integra��o num�rica
[pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);

% Realiza a verifica��o se esse elemento possui cargas de tra��o em seus lados
if ~isempty(CargaDist)
    for i = 1:size(CargaDist, 1)        % La�o para cada carga concentrada
        %---------------------------------------------------------------------------------
        if CargaDist(i, 1) == 1     % Verifica se h� cargas na dire��o X
            % Verifica se os lados do elemento coincidem com o lado de aplica��o da carga
            aux_logico = xx(1:2) == CargaDist(i, 2);
            if sum(aux_logico) ~= 0     % Ativa o c�lculo das cargas
                % Recolhe o valor da coordenada intr�nseca xi (ou � -1 ou � 1)
                if aux_logico(1) == 1
                    xi = -1;
                else
                    xi = 1;
                end
                               
                % Colhe os n�s do elemento que possuem a carga distribu�da aplicada
                ind = find(abs(xx - CargaDist(i, 2)) < 1e-15);
                aux_carga = zeros(1, size(ind, 2));
                
                % Parcela nodal de carga (� suposto que a carga � linearmente distribu�da)
                % Organiza em ordem as coordenadas y
                [aux_yy, aux_ind] = sort(yy(ind));
                % Diferen�a de cargas
                deltaC = CargaDist(i, 6) - CargaDist(i, 5);
                % Comprimento total do lado do elemento
                deltaY = CargaDist(i, 4) - CargaDist(i, 3);  
                
                % C�lcula a carga em cada n� do lado com a tra��o. Isso permite a cria��o
                % da fun��o linear da carga
                for j = 1:size(ind, 2)          % La�o com a quantidade de n�s
                    aux_carga(j) = (((aux_yy(j) - CargaDist(i, 3)) / deltaY) * deltaC) ...
                        + CargaDist(i, 5);
                end
                
                % Organiza as cargas nodais de acordo com os indices dos n�s
                aux_carga = aux_carga(aux_ind);
                
                % Realiza a integra��o num�rica para c�lculo das for�as equivalentes
                for intY = 1:nQuadFle       % Percorre os pontos de integra��o
                    % Valor da coordenada intr�nseca eta (eixo de integra��o y)
                    eta = pontos_Fle(intY);
                    % Peso para essa coordenada
                    pesoY = weight_Fle(intY);
                    
                    % C�lcula as fun��es de forma
                    [N, dN_dxi, dN_deta] = shapefunctions(noel, xi, eta);
                    
                    % C�lculo da matriz Jacobiana da transforma��o de coordenadas
                    Jacob = Jacobian(noel, dN_dxi, dN_deta, xx, yy);
                    
                    % Calcula o determinante e a matriz inversa da matriz Jacobiana. Como
                    % a tra��o � em somente uma dire��o o determinante ser� o pr�prio
                    % valor da derivada da fun��o de forma em rela��o � dire��o
                    detJacob = Jacob(2, 2);
                    
                    % Vari�vel auxiliar que guardar� os graus de liberdade
                    ind = zeros(1, ngl_no);             
                    for j = 1:noel          % La�o para os n�s do elemento
                        ind(1) = (j - 1) * ngl_no + 1;      % Primeiro grau de liberdade
                        
                        for kk = 1:(ngl_no - 1)   % La�o para os demais graus de liberdade
                            ind(kk + 1) = ind(kk) + 1;     % (j+1)-�simo grau de liberdade
                        end
                        
                        for k = 1:ngl_no          % La�o para os graus de liberdade por n�
                            N_e(k, ind(k)) = N(j);  % Armazena a fun��o de forma na matriz
                        end
                    end
                    
                    % Inicializa o vetor de cargas nos n�s do elemento
                    C_e = zeros(ngl_no, 1);
                    
                    % C�lcula o valor da fun��o linear de carga
                    C_e(CargaDist(i, 1)) = ...
                              0.5 * ((1 - eta) * aux_carga(1) + (1 + eta) * aux_carga(2));
                    
                    % C�lculo da For�a Equivalente
                    F_eq = F_eq + t * N_e' * C_e * pesoY * detJacob;
                end
            end
        %---------------------------------------------------------------------------------
        elseif CargaDist(i, 1) == 2     % Verifica se h� cargas na dire��o Y
            aux_logico = yy(2:3) == CargaDist(i, 2);
            if sum(aux_logico) ~= 0                
                % Recolhe o valor da coordenada intr�nseca xi (ou � -1 ou � 1)
                if aux_logico(1) == 1
                    eta = -1;
                else
                    eta = 1;
                end
                
                % Colhe os n�s do elemento que possuem a carga distribu�da aplicada
                ind = find(abs(yy - CargaDist(i, 2)) < 1e-15);
                aux_carga = zeros(1, size(ind, 2));
                
                % Parcela nodal de carga (� suposto que a carga � linearmente distribu�da)
                % Organiza em ordem as coordenadas x
                [aux_xx, aux_ind] = sort(xx(ind));
                % Diferen�a de cargas
                deltaC = CargaDist(i, 6) - CargaDist(i, 5);
                % Comprimento total do lado do elemento
                deltaY = CargaDist(i, 4) - CargaDist(i, 3);
                
                % C�lcula a carga em cada n� do lado com a tra��o. Isso permite a cria��o
                % da fun��o linear da carga
                for j = 1:size(ind, 2)          % La�o com a quantidade de n�s
                    aux_carga(j) = (((aux_xx(j) - CargaDist(i, 3)) / deltaY) * deltaC) ...
                        + CargaDist(i, 5);
                end
                
                % Organiza as cargas nodais de acordo com os indices dos n�s
                aux_carga = aux_carga(aux_ind);
                
                % Realiza a integra��o num�rica para c�lculo das for�as equivalentes
                for intX = 1:nQuadFle       % Percorre os pontos de integra��o
                    % Valor da coordenada intr�nseca eta (eixo de integra��o y)
                    xi = pontos_Fle(intX);
                    % Peso para essa coordenada
                    pesoX = weight_Fle(intX);
                    
                    % C�lcula as fun��es de forma
                    [N, dN_dxi, dN_deta] = shapefunctions(noel, xi, eta);
                    
                    % C�lculo da matriz Jacobiana da transforma��o de coordenadas
                    Jacob = Jacobian(noel, dN_dxi, dN_deta, xx, yy);
                    
                    % Calcula o determinante e a matriz inversa da matriz Jacobiana. Como
                    % a tra��o � em somente uma dire��o o determinante ser� o pr�prio
                    % valor da derivada da fun��o de forma em rela��o � dire��o
                    detJacob = Jacob(1, 1);
                    
                    % Vari�vel auxiliar que guardar� os graus de liberdade
                    ind = zeros(1, ngl_no);             
                    for j = 1:noel          % La�o para os n�s do elemento
                        ind(1) = (j - 1) * ngl_no + 1;      % Primeiro grau de liberdade
                        
                        for kk = 1:(ngl_no - 1)   % La�o para os demais graus de liberdade
                            ind(kk + 1) = ind(kk) + 1;     % (j+1)-�simo grau de liberdade
                        end
                        
                        for k = 1:ngl_no          % La�o para os graus de liberdade por n�
                            N_e(k, ind(k)) = N(j);  % Armazena a fun��o de forma na matriz
                        end
                    end
                    
                    % Inicializa o vetor de cargas nos n�s do elemento
                    C_e = zeros(ngl_no, 1);
                    
                    % C�lcula o valor da fun��o linear de carga
                    C_e(CargaDist(i, 1)) = ...
                                0.5 * ((1 - xi) * aux_carga(1) + (1 + xi) * aux_carga(2));
                    
                    % C�lculo da For�a Equivalente
                    F_eq = F_eq + t * N_e' * C_e * pesoX * detJacob;
                end
            end
        end
        %---------------------------------------------------------------------------------
    end
end













