%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   An�lise de estruturas por meio dos Elementos Finitos utilizando a an�lise do estado
%   plano de tens�es.
%
%   O programa � capaz de criar uma malha de elementos quadrangulares linear (4 n�s por
%   elemento) e bilinear (9 n�s por elementos), se a estrutura analisada for retangular de
%   dimens�es L x h (comprimento x altura).
%
%   Para an�lises de estruturas em viga ser� utilizado o modelo de Euler-Bernoulli onde � 
%   recomendado que L / h >> 50. Para placas ser� utilizado o modelo de Mindlin onde �
%   recomendado que a espessura (t) seja menor que max(L, h)/50 (onde na placa L e h s�o
%   as dimens�es da superf�cie de refer�ncia).
%
%   Todas as an�lises s�o para materiais que obedecem a Lei de Hook e est�o sujeitos a
%   pequenas deforma��es. As an�lises s�o para o estado linear de deforma��es.
%
%   -----------------------------------------------
%   Autor: F�bio Felipe dos Santos Nascentes
%   Data:  12/07/2018
%   -----------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;
%=========================================================================================
%                   DEFINI��O DAS DIMENS�ES E DO MATERIAL DA ESTRUTRA
% A vari�vel tipo de estrutura ser� a respons�vel da escolha nos switch case para o
% c�lculo da estrutura. Poder�o ser passados somente strings como valores da vari�vel.
%   Op��es da vari�vel tipoEstrutura:
%       'viga' - realiza o c�lculo de uma viga pelo EPT via EF
%       'placa' - realiza o c�lculo de uma placa pelo EPT via EF
tipoEstrutura = 'placa';

% Dimens�es da Estrutura
global InfoGeo
InfoGeo.L = 12;                        % Comprimento da estrutura (em metros)
InfoGeo.h = 12;                        % Altura da viga ou largura na placa (em metros)
InfoGeo.t = 0.096;                     % Espessura da viga ou altura da placa (em metros)

% Armazena as cargas aplicadas sobre a estrutura
[CargaDist, CargaConc] = Cargas();
%=========================================================================================

%=========================================================================================
%                  DADOS DA MALHA EM ELEMENTOS FINITOS (ESTRUTURA RETANGULAR)
% Cria��o dos dados principais da malha
global InfoMesh
InfoMesh.numDeSubDivX = 4;                  % N�mero de elementos ao longo do eixo x
InfoMesh.numDeSubDivY = 4;                   % N�mero de elementos ao longo do eixo y

InfoMesh.compX = (InfoGeo.L - 0) / InfoMesh.numDeSubDivX; % Comprimento x de cada elemento
InfoMesh.compY = (InfoGeo.h - 0) / InfoMesh.numDeSubDivY; % Comprimento y de cada elemento

% N�mero de n�s nos cantos de cada elemento 
InfoMesh.nosCanto = (InfoMesh.numDeSubDivX + 1) * (InfoMesh.numDeSubDivY + 1);

% N�mero de Elementos da malha
InfoMesh.numDeElem = InfoMesh.numDeSubDivX * InfoMesh.numDeSubDivY;

% Cria��o dos N�s e do tipo de elemento
InfoMesh.nosPorElemento = 9;
if (InfoMesh.nosPorElemento == 4)
    [InfoMesh.coordenadas, InfoMesh.elem_conec] = nosElem4();
else
    [InfoMesh.coordenadas, InfoMesh.elem_conec] = nosElem9();
end

% Faz o gr�fico da malha de elementos finitos
%GraficoMalha();
%=========================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Montagem das Matrizes de Rigidez Global e de For�as
%   Defini��o do n�mero de graus de liberdade do modelo.
%   Para o caso da viga cada n� da malha est� sujeito a dois graus de liberdade:
%   deslocamento vertical e rota��o da perpendicular em x, ou seja, o par (v, dv/dx).
%   Para o caso da placa temos que cada n� est� sujeito a 5 graus de liberdade: as
%   transla��es em x, y e z (u, v, w), e as rota��es da normal em x e y (phi_x, dphi_y),
%   ou seja, a qu�ntupla (u, v, w, phi_x, phi_y).
switch tipoEstrutura
    case 'viga'
        ngl_no = 2;
    case 'placa'
        ngl_no = 5;
end

% N�mero de graus de liberdade por elemento do modelo
ngl_elem = InfoMesh.nosPorElemento * ngl_no;

% N�mero de graus de liberdade totais do modelo
ngl = size(InfoMesh.coordenadas, 1) * ngl_no; 

% Inicializa��o da matriz de rigidez da estrutura e da matriz de elementos
K = zeros(ngl, ngl);

% Inicializa��o do vetor de for�as nodais do modelo e de cada elemento
F = zeros(ngl, 1);

% Defini��o da matriz do material para o c�lculo das matrizes de rigidez
switch tipoEstrutura
    case 'viga'
        % M�dulo de Elasticidade N / m^2
        E = 2e11;
        
        % Coeficiente de Poisson
        nu = 0;
        
        % Matriz Constitutiva de Flex�o para o EPT
        C = E / (1 - nu^2)*[1 nu 0 ; nu 1 0; 0 0 ((1 - nu) / 2)];
        
        % Matriz Constitutiva de Cisalhamento para o EPT
        % No caso de viga de Euler-Bernoulli n�o se analisa o cisalhamento, portanto essa 
        % matriz dever� ser nula.
        Mat_cis = 0;
    case 'placa'
        % Chama a fun��o que possui as informa��es do laminado composto
        [InfoLaminado, C, Mat_cis] = Laminado(InfoGeo.t);
end
%-----------------------------------------------------------------------------------------
% Defini��o doos pontos para o c�lculo da integral num�rica das fun��es de aproxima��o
% para montagem das matrizes de rigidez e de for�a
% Defini��o da dimens�o da integra��o
dim = 2;        % X e Y
switch tipoEstrutura
    case 'viga'
        nQuadFle = 3;
        [pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);
    case 'placa'
        if InfoMesh.nosPorElemento == 4
            nQuadFle = 2;   % Flex�o
            nQuadCis = 1;   % Cisalhamento
        else
            nQuadFle = 3;   % Flex�o
            nQuadCis = 2;
        end
        [pontos_Fle, weight_Fle] = GaussQuadrature(nQuadFle, dim);
        [pontos_Cis, weight_Cis] = GaussQuadrature(nQuadCis, dim);
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% C�lculo das matrizes
for iel = 1:InfoMesh.numDeElem           % La�o para os elementos do modelo
    % Extrai o n� i de conectivade do iel-�simo elemento
    nd = InfoMesh.elem_conec(iel, :);
    
    % Extrai a coordenada x desse n�
    xx = InfoMesh.coordenadas(nd, 1)';
    
    % Extrai a coordenada y desse n�
    yy = InfoMesh.coordenadas(nd, 2)';
    
    % Inicializa as matrizes de Rigidiz e de For�a do Elemento
    Kf_e = zeros(ngl_elem, ngl_elem);
    KC_e = zeros(ngl_elem, ngl_elem);
    F_e = zeros(ngl_elem, 1);
    
    %==============================Integra��o Num�rica====================================
    %--------------------------Matriz de Rigidez Para Flex�o------------------------------
    for ponto = 1:size(pontos_Fle, 1)       % La�o para os pontos de integra��o no eixo x
        xi = pontos_Fle(ponto, 1);      % Vari�vel xi (par�metro de int. eixo x)
        eta = pontos_Fle(ponto, 2);     % Vari�vel eta (par�metro de int. eixo y)
        peso = weight_Fle(ponto, 1) * weight_Fle(ponto, 2);   % Peso da vari�vel eta
        
        % Realiza o c�lculo das fun��es de forma do elemento (N), e das derivadas
        % dessas fun��es nas coordenadas intr�nsecas (dN/dxi e dN/deta)
        [N, dN_dxi, dN_deta] = shapefunctions(InfoMesh.nosPorElemento, xi, eta);
        
        % C�lculo da matriz Jacobiana da transforma��o de coordenadas
        Jacobiana = Jacobian(InfoMesh.nosPorElemento, dN_dxi, dN_deta, xx, yy);
        
        % Calcula o determinante e a matriz inversa da matriz Jacobiana
        detJacobiana = det(Jacobiana);
        invJacobiana = inv(Jacobiana);
        
        % Calcula as derivadas das fun��es de forma em rela��o �s coordenadas x e y
        [dN_dx, dN_dy] = shapefunctionderivatives(InfoMesh.nosPorElemento, dN_dxi, ...
            dN_deta, invJacobiana);
        
        % C�lculo da matriz B para constru��o da Matriz de Rigidez de Flex�o e de
        % Cisalhamento
        [B_f, ~] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
            dN_dx, dN_dy);
        
        % C�lculo da matriz de Rigidez do Elemento
        % Parcela de Membrana-Flex�o
        Kf_e = Kf_e + B_f' * C * B_f * peso * detJacobiana;        
    end
    %--------------------------Matriz de Rigidez para o Cisalhamento----------------------
    for ponto = 1:size(pontos_Cis, 1)       % La�o para os pontos de integra��o no eixo x
        xi = pontos_Cis(ponto, 1);      % Vari�vel xi (par�metro de int. eixo x)
        eta = pontos_Cis(ponto, 2);     % Vari�vel eta (par�metro de int. eixo y)
        peso = weight_Cis(ponto, 1) * weight_Cis(ponto, 2);   % Peso da vari�vel eta
        
        % Realiza o c�lculo das fun��es de forma do elemento (N), e das derivadas
        % dessas fun��es nas coordenadas intr�nsecas (dN/dxi e dN/deta)
        [N, dN_dxi, dN_deta] = shapefunctions(InfoMesh.nosPorElemento, xi, eta);
        
        % C�lculo da matriz Jacobiana da transforma��o de coordenadas
        Jacobiana = Jacobian(InfoMesh.nosPorElemento, dN_dxi, dN_deta, xx, yy);
        
        % Calcula o determinante e a matriz inversa da matriz Jacobiana
        detJacobiana = det(Jacobiana);
        invJacobiana = inv(Jacobiana);
        
        % Calcula as derivadas das fun��es de forma em rela��o �s coordenadas x e y
        [dN_dx, dN_dy] = shapefunctionderivatives(InfoMesh.nosPorElemento, dN_dxi, ...
            dN_deta, invJacobiana);
        
        % C�lculo da matriz B para constru��o da Matriz de Rigidez de Flex�o e de
        % Cisalhamento
        [~, B_c] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
                                                                            dN_dx, dN_dy);
        
        % C�lculo da matriz de Rigidez do Elemento
        % Parcela do Cisalhamento
        KC_e = KC_e + B_c' * Mat_cis * B_c * peso * detJacobiana;
        
        % C�lculo da for�a nodal equivalente devido � press�es sobre o plano (dire��o
        % z). No caso da viga esses valores s�o desconsiderados
        if sum(ismember(CargaDist(:,1), 3)) ~= 0
            % Recolhe o valor da carga distribu�da
            q = CargaDist(CargaDist(:, 1) == 3, 5);
            
            % Monta a matriz de fun��es de forma para c�lculo das for�as equivalentes
            N_e = zeros(ngl_elem, 1);      % Inicializa a matriz
            
            for i = 1:InfoMesh.nosPorElemento    % La�o para os n�s do elemento
                ind = (i - 1) * ngl_no + 3;      % Terceiro grau de liberdade (w_0)
                
                % Armazena a fun��o de forma no vetor auxiliar de fun��es de forma
                N_e(ind) = N(i);
            end
            
            % C�lculo do vetor de for�as equivalente do elemento
            F_e = F_e + N_e * q * peso * detJacobiana;
        end
    end
    
    % Soma as matrizes de flex�o e de cisalhamento
    K_e = Kf_e + KC_e;
    %=====================================================================================
    % Limpa a mem�ria das vari�veis utilizadas para o c�lculo da carga distribu�da na 
    % dire��o Z
    clear q N_e ind
    
    % Calcula as parcelas de for�as de superf�cie (tra��o)
    F_eq = Forcas(InfoMesh.nosPorElemento, xx, yy, ngl_elem, CargaDist,...
                                                                  InfoGeo.t, nQuadFle, 1);
    F_e = F_e + F_eq;
    
    % Calcula os �ndices dos graus de liberdade que est�o associados ao elemento
    indices = GrausLiberdade(nd, InfoMesh.nosPorElemento, ngl_no);
    
    % Realiza a sobreposi��o da matriz de rigidez e do vetor de for�as do elemento
    [K, F] = Sobreposicao(K, F, K_e, F_e, indices);
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear indices

% Imposi��o das condi��es de contorno
% Armazena os valores originais
K0 = K;
F0 = F;

%----------------------------Aplica as condi��es de contorno------------------------------
% Os tipos de apoio poss�veis s�o:
%   Viga:
%       1 - Engastada em um extremo da viga (x = 0 ou x = L), a definir dentro da fun��o;
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





