%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Análise de estruturas por meio dos Elementos Finitos utilizando a análise do estado
%   plano de tensões.
%
%   O programa é capaz de criar uma malha de elementos quadrangulares linear (4 nós por
%   elemento) e bilinear (9 nós por elementos), se a estrutura analisada for retangular de
%   dimensões L x h (comprimento x altura).
%
%   Para análises de estruturas em viga será utilizado o modelo de Euler-Bernoulli onde é 
%   recomendado que L / h >> 50. Para placas será utilizado o modelo de Mindlin onde é
%   recomendado que a espessura (t) seja menor que max(L, h)/50 (onde na placa L e h são
%   as dimensões da superfície de referência).
%
%   Todas as análises são para materiais que obedecem a Lei de Hook e estão sujeitos a
%   pequenas deformações. As análises são para o estado linear de deformações.
%
%   -----------------------------------------------
%   Autor: Fábio Felipe dos Santos Nascentes
%   Data:  12/07/2018
%   -----------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;
%=========================================================================================
%                   DEFINIÇÃO DAS DIMENSÕES E DO MATERIAL DA ESTRUTRA
% A variável tipo de estrutura será a responsável da escolha nos switch case para o
% cálculo da estrutura. Poderão ser passados somente strings como valores da variável.
%   Opções da variável tipoEstrutura:
%       'viga' - realiza o cálculo de uma viga pelo EPT via EF
%       'placa' - realiza o cálculo de uma placa pelo EPT via EF
tipoEstrutura = 'placa';

% Dimensões da Estrutura
global InfoGeo
InfoGeo.L = 12;                        % Comprimento da estrutura (em metros)
InfoGeo.h = 12;                        % Altura da viga ou largura na placa (em metros)
InfoGeo.t = 0.096;                     % Espessura da viga ou altura da placa (em metros)

% Armazena as cargas aplicadas sobre a estrutura
[CargaDist, CargaConc] = Cargas();
%=========================================================================================

%=========================================================================================
%                  DADOS DA MALHA EM ELEMENTOS FINITOS (ESTRUTURA RETANGULAR)
% Criação dos dados principais da malha
global InfoMesh
InfoMesh.numDeSubDivX = 4;                  % Número de elementos ao longo do eixo x
InfoMesh.numDeSubDivY = 4;                   % Número de elementos ao longo do eixo y

InfoMesh.compX = (InfoGeo.L - 0) / InfoMesh.numDeSubDivX; % Comprimento x de cada elemento
InfoMesh.compY = (InfoGeo.h - 0) / InfoMesh.numDeSubDivY; % Comprimento y de cada elemento

% Número de nós nos cantos de cada elemento 
InfoMesh.nosCanto = (InfoMesh.numDeSubDivX + 1) * (InfoMesh.numDeSubDivY + 1);

% Número de Elementos da malha
InfoMesh.numDeElem = InfoMesh.numDeSubDivX * InfoMesh.numDeSubDivY;

% Criação dos Nós e do tipo de elemento
InfoMesh.nosPorElemento = 9;
if (InfoMesh.nosPorElemento == 4)
    [InfoMesh.coordenadas, InfoMesh.elem_conec] = nosElem4();
else
    [InfoMesh.coordenadas, InfoMesh.elem_conec] = nosElem9();
end

% Faz o gráfico da malha de elementos finitos
%GraficoMalha();
%=========================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Montagem das Matrizes de Rigidez Global e de Forças
%   Definição do número de graus de liberdade do modelo.
%   Para o caso da viga cada nó da malha está sujeito a dois graus de liberdade:
%   deslocamento vertical e rotação da perpendicular em x, ou seja, o par (v, dv/dx).
%   Para o caso da placa temos que cada nó está sujeito a 5 graus de liberdade: as
%   translações em x, y e z (u, v, w), e as rotações da normal em x e y (phi_x, dphi_y),
%   ou seja, a quíntupla (u, v, w, phi_x, phi_y).
switch tipoEstrutura
    case 'viga'
        ngl_no = 2;
    case 'placa'
        ngl_no = 5;
end

% Número de graus de liberdade por elemento do modelo
ngl_elem = InfoMesh.nosPorElemento * ngl_no;

% Número de graus de liberdade totais do modelo
ngl = size(InfoMesh.coordenadas, 1) * ngl_no; 

% Inicialização da matriz de rigidez da estrutura e da matriz de elementos
K = zeros(ngl, ngl);

% Inicialização do vetor de forças nodais do modelo e de cada elemento
F = zeros(ngl, 1);

% Definição da matriz do material para o cálculo das matrizes de rigidez
switch tipoEstrutura
    case 'viga'
        % Módulo de Elasticidade N / m^2
        E = 2e11;
        
        % Coeficiente de Poisson
        nu = 0;
        
        % Matriz Constitutiva de Flexão para o EPT
        C = E / (1 - nu^2)*[1 nu 0 ; nu 1 0; 0 0 ((1 - nu) / 2)];
        
        % Matriz Constitutiva de Cisalhamento para o EPT
        % No caso de viga de Euler-Bernoulli não se analisa o cisalhamento, portanto essa 
        % matriz deverá ser nula.
        Mat_cis = 0;
    case 'placa'
        % Chama a função que possui as informações do laminado composto
        [InfoLaminado, C, Mat_cis] = Laminado(InfoGeo.t);
end
%-----------------------------------------------------------------------------------------
% Definição doos pontos para o cálculo da integral numérica das funções de aproximação
% para montagem das matrizes de rigidez e de força
% Definição da dimensão da integração
dim = 2;        % X e Y
switch tipoEstrutura
    case 'viga'
        nQuadFle = 3;
        [pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);
    case 'placa'
        if InfoMesh.nosPorElemento == 4
            nQuadFle = 2;   % Flexão
            nQuadCis = 1;   % Cisalhamento
        else
            nQuadFle = 3;   % Flexão
            nQuadCis = 2;
        end
        [pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);
        [pontos_Cis, weight_Cis] = GaussQuadrature(nQuadCis, dim);
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Cálculo das matrizes
for iel = 1:InfoMesh.numDeElem           % Laço para os elementos do modelo
    % Extrai o nó i de conectivade do iel-ésimo elemento
    nd = InfoMesh.elem_conec(iel, :);
    
    % Extrai a coordenada x desse nó
    xx = InfoMesh.coordenadas(nd, 1)';
    
    % Extrai a coordenada y desse nó
    yy = InfoMesh.coordenadas(nd, 2)';
    
    % Inicializa as matrizes de Rigidiz e de Força do Elemento
    Kf_e = zeros(ngl_elem, ngl_elem);
    KC_e = zeros(ngl_elem, ngl_elem);
    F_e = zeros(ngl_elem, 1);
    
    %==============================Integração Numérica====================================
    %--------------------------Matriz de Rigidez Para Flexão------------------------------
    for ponto = 1:size(pontos_Fle, 1)       % Laço para os pontos de integração no eixo x
        xi = pontos_Fle(ponto, 1);      % Variável xi (parâmetro de int. eixo x)
        eta = pontos_Fle(ponto, 2);     % Variável eta (parâmetro de int. eixo y)
        peso = weight_Fle(ponto, 1) * weight_Fle(ponto, 2);   % Peso da variável eta
        
        % Realiza o cálculo das funções de forma do elemento (N), e das derivadas
        % dessas funções nas coordenadas intrínsecas (dN/dxi e dN/deta)
        [N, dN_dxi, dN_deta] = shapefunctions(InfoMesh.nosPorElemento, xi, eta);
        
        % Cálculo da matriz Jacobiana da transformação de coordenadas
        Jacobiana = Jacobian(InfoMesh.nosPorElemento, dN_dxi, dN_deta, xx, yy);
        
        % Calcula o determinante e a matriz inversa da matriz Jacobiana
        detJacobiana = det(Jacobiana);
        invJacobiana = inv(Jacobiana);
        
        % Calcula as derivadas das funções de forma em relação às coordenadas x e y
        [dN_dx, dN_dy] = shapefunctionderivatives(InfoMesh.nosPorElemento, dN_dxi, ...
            dN_deta, invJacobiana);
        
        % Cálculo da matriz B para construção da Matriz de Rigidez de Flexão e de
        % Cisalhamento
        [B_f, ~] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
            dN_dx, dN_dy);
        
        % Cálculo da matriz de Rigidez do Elemento
        % Parcela de Membrana-Flexão
        Kf_e = Kf_e + B_f' * C * B_f * peso * detJacobiana;        
    end
    %--------------------------Matriz de Rigidez para o Cisalhamento----------------------
    for ponto = 1:size(pontos_Cis, 1)       % Laço para os pontos de integração no eixo x
        xi = pontos_Cis(ponto, 1);      % Variável xi (parâmetro de int. eixo x)
        eta = pontos_Cis(ponto, 2);     % Variável eta (parâmetro de int. eixo y)
        peso = weight_Cis(ponto, 1) * weight_Cis(ponto, 2);   % Peso da variável eta
        
        % Realiza o cálculo das funções de forma do elemento (N), e das derivadas
        % dessas funções nas coordenadas intrínsecas (dN/dxi e dN/deta)
        [N, dN_dxi, dN_deta] = shapefunctions(InfoMesh.nosPorElemento, xi, eta);
        
        % Cálculo da matriz Jacobiana da transformação de coordenadas
        Jacobiana = Jacobian(InfoMesh.nosPorElemento, dN_dxi, dN_deta, xx, yy);
        
        % Calcula o determinante e a matriz inversa da matriz Jacobiana
        detJacobiana = det(Jacobiana);
        invJacobiana = inv(Jacobiana);
        
        % Calcula as derivadas das funções de forma em relação às coordenadas x e y
        [dN_dx, dN_dy] = shapefunctionderivatives(InfoMesh.nosPorElemento, dN_dxi, ...
            dN_deta, invJacobiana);
        
        % Cálculo da matriz B para construção da Matriz de Rigidez de Flexão e de
        % Cisalhamento
        [~, B_c] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
                                                                            dN_dx, dN_dy);
        
        % Cálculo da matriz de Rigidez do Elemento
        % Parcela do Cisalhamento
        KC_e = KC_e + B_c' * Mat_cis * B_c * peso * detJacobiana;
        
        % Cálculo da força nodal equivalente devido à pressões sobre o plano (direção
        % z). No caso da viga esses valores são desconsiderados
        if sum(ismember(CargaDist(:,1), 3)) ~= 0
            % Recolhe o valor da carga distribuída
            q = CargaDist(CargaDist(:, 1) == 3, 5);
            
            % Monta a matriz de funções de forma para cálculo das forças equivalentes
            N_e = zeros(ngl_elem, 1);      % Inicializa a matriz
            
            for i = 1:InfoMesh.nosPorElemento    % Laço para os nós do elemento
                ind = (i - 1) * ngl_no + 3;      % Terceiro grau de liberdade (w_0)
                
                % Armazena a função de forma no vetor auxiliar de funções de forma
                N_e(ind) = N(i);
            end
            
            % Cálculo do vetor de forças equivalente do elemento
            F_e = F_e + N_e * q * peso * detJacobiana;
        end
    end
    
    % Soma as matrizes de flexão e de cisalhamento
    K_e = Kf_e + KC_e;
    %=====================================================================================
    % Limpa a memória das variáveis utilizadas para o cálculo da carga distribuída na 
    % direção Z
    clear q N_e ind
    
    % Calcula as parcelas de forças de superfície (tração)
    F_eq = Forcas(InfoMesh.nosPorElemento, xx, yy, ngl_elem, CargaDist,...
                                                                  InfoGeo.t, nQuadFle, 1);
    F_e = F_e + F_eq;
    
    % Calcula os índices dos graus de liberdade que estão associados ao elemento
    indices = GrausLiberdade(nd, InfoMesh.nosPorElemento, ngl_no);
    
    % Realiza a sobreposição da matriz de rigidez e do vetor de forças do elemento
    [K, F] = Sobreposicao(K, F, K_e, F_e, indices);
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear indices

% Imposição das condições de contorno
% Armazena os valores originais
K0 = K;
F0 = F;

%----------------------------Aplica as condições de contorno------------------------------
% Os tipos de apoio possíveis são:
%   Viga:
%       1 - Engastada em um extremo da viga (x = 0 ou x = L), a definir dentro da função;
%       2 - Biengastada.
%
%   Placa:
%       1 -> SS-SS-SS-SS = simplesmente apoiada nas quatro bordas;
%       2 -> SS-1 livro do Reddy
%       3 -> C-C-C-C = engastada nas 4 bordas
tipoApoio = 3;
[K, F] = CondCont(K, F, tipoEstrutura, tipoApoio, InfoMesh.coordenadas, ngl_no);
%-----------------------------------------------------------------------------------------
% Resolve o sistema KU = F e encontra os deslocamentos nodais
U = linsolve(K, F);

meio = [InfoGeo.L / 2, InfoGeo.h / 2];

ind_medio = find(abs(InfoMesh.coordenadas(:, 1) - meio(1)) < 1e-10 & ...
                                        abs(InfoMesh.coordenadas(:, 2) - meio(2)) <1e-10);

ind_medio = (ind_medio - 1) * ngl_no + 3;

U(ind_medio)

%U(ind_medio)*((7e9*0.1^3)/(1*4e3))
% 
% energ = 0.5*U'*K0*U;





