function [K, F] = CondCont(K, F, estrutura, tipoApoio, coor, ngl_no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que aplica as condi��es de contorno � matriz de rigidez e ao vetor de for�as.
%
%   Entrada:
%       K - matriz de rigidez;
%       F - vetor de for�as;
%       estrutura - qual o tipo de estrutura ('viga' ou 'placa');
%       tipoApoio - qual o tipo de apoio;
%       coor - matriz de coordenadas do modelo;
%       ngl_no - n�mero de graus de liberdade por n� do modelo.
%
%   Sa�da:
%       K - matriz de Rigidez com as condi��es de contorno aplicadas;
%       F - vetor de for�as com as condi��es de contorno aplicadas.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch estrutura
    case 'viga'
        % C�lcula os �ndices da matriz que possui restri��o
        Ind_Rest = IndicesViga(tipoApoio, coor, ngl_no);
        
    case 'placa'
        % C�lcula os �ndices da matriz que possui restri��o
        Ind_Rest = IndicesPlaca(tipoApoio, coor, ngl_no);
end

% Aplica as condi��es de contorno sobre a matriz de rigidez e o vetor de for�as
for i = 1:length(Ind_Rest)       % La�o que percorre os �ndices restritos
    % Recolhe o �ndice restrito
    pos = Ind_Rest(i);
    
    % Aplica a condi��o de contorno � linha (zerando-a)
    K(pos, :) = 0;
    
    % Aplica a condi��o de contorno � coluna (zerando-a)
    K(:, pos) = 0;
    
    % Aloca o valor 1 na matriz de rigidez
    K(pos, pos) = 1;
    
    % Aplica as condi��es de contorno ao vetor de for�as
    F(pos) = 0;
end

end
%=========================================================================================
function Ind_Rest = IndicesViga(tipoApoio, coor, ngl_no)
switch tipoApoio
    case 1      % Engastado
        % Primeiro especifica-se o ponto de engaste
        x_eng = 0;
        
        % Determina quais s�o os n�s que estar�o engastados
        nos_eng = find(abs(coor(:, 1) - x_eng) < 1e-10);
        
        % Inicializa o vetor com os �ndices de restri��o
        Ind_Rest = zeros(1, length(nos_eng) * ngl_no);
        
        % Preenche o vetor de �ndices
        k = 1;
        for i = 1:length(nos_eng)       % La�o que percorre os n�s restringidos
            aux_ind = (nos_eng(i) - 1) * ngl_no;
            for j = 1:ngl_no
                Ind_Rest(k) = aux_ind + j;
                k = k + 1;
            end
        end
    case 2      % Biengastado
        % Colhe os n�s que estar�o restritos
        nos1_eng = find(abs(coor(:, 1) - min(coor(:,1))) < 1e-10);
        nos2_eng = find(abs(coor(:, 1) - max(coor(:,1))) < 1e-10);
        nos_eng = union(nos1_eng, nos2_eng);
        
        % Inicializa o vetor com os �ndices de restri��o
        Ind_Rest = zeros(1, length(nos_eng) * ngl_no);
        
        % Preenche o vetor de �ndices
        k = 1;
        for i = 1:length(nos_eng)       % La�o que percorre os n�s restringidos
            aux_ind = (nos_eng(i) - 1) * ngl_no;
            for j = 1:ngl_no
                Ind_Rest(k) = aux_ind + j;
                k = k + 1;
            end
        end
end
end

function Ind_Rest = IndicesPlaca(tipoApoio, coor, ngl_no)
% Recolhe os n�s que pertencem aos lados da placa
lado1 = find(abs(coor(:, 1) - min(coor(:,1))) < 1e-10); % x = 0
lado2 = find(abs(coor(:, 1) - max(coor(:,1))) < 1e-10); % x = L
lado3 = find(abs(coor(:, 2) - min(coor(:,2))) < 1e-10); % y = 0
lado4 = find(abs(coor(:, 2) - max(coor(:,2))) < 1e-10); % y = h

% Decide de acordo com o tipo de apoio quais graus de liberdade estar�o restringidos
switch tipoApoio
    case 1      % SS-SS-SS-SS
        % No caso de ser simplesmente apoiado os graus restingidos ser�o os 1, 2, 3
        % referentes � u, v e w, respectivamente.
        
        % Como s�o os quatro lados juntamos todos os n�s em um �nico vetor
        nos_lados = union(union(lado1, lado2), union(lado3, lado4));
        
        % Inicializa o vetor com os �ndices de restri��o
        Ind_Rest = zeros(1, length(nos_lados) * 1);
        
        % Preenche o vetor de �ndices
        k = 1;
        for i = 1:length(nos_lados)       % La�o que percorre os n�s restringidos
            aux_ind = (nos_lados(i) - 1) * ngl_no;
            for j = 1:3
                Ind_Rest(k) = aux_ind + j;
                k = k + 1;
            end
        end
    case 2      % SS-1
        % Lados em X e Y
        ladosX = union(lado1, lado2);
        ladosY = union(lado3, lado4);
        
        % Preenche o vetor de �ndices
        k = 1;
        for i = 1:length(ladosX)       % La�o que percorre os n�s restringidos
            aux_ind = (ladosX(i) - 1) * ngl_no;
            Ind_Rest(k) = aux_ind + 2;
            Ind_Rest(k + 1) = aux_ind + 3;
            Ind_Rest(k + 2) = aux_ind + 5;
            k = k + 3;
        end
        for i = 1:length(ladosY)       % La�o que percorre os n�s restringidos
            aux_ind = (ladosY(i) - 1) * ngl_no;
            Ind_Rest(k) = aux_ind + 1;
            Ind_Rest(k + 1) = aux_ind + 3;
            Ind_Rest(k + 2) = aux_ind + 4;
            k = k + 3;
        end    
        Ind_Rest = sort(Ind_Rest);
    case 3      % C-C-C-C
        % No caso de ser engastado nos quatro lados, todos os 5 graus de liberdade do n�
        % ser�o restringidos.
        
        % Como s�o os quatro lados juntamos todos os n�s em um �nico vetor
        nos_lados = union(union(lado1, lado2), union(lado3, lado4));
        
        % Inicializa o vetor com os �ndices de restri��o
        Ind_Rest = zeros(1, length(nos_lados) * 3);
        
        % Preenche o vetor de �ndices
        k = 1;
        for i = 1:length(nos_lados)       % La�o que percorre os n�s restringidos
            aux_ind = (nos_lados(i) - 1) * ngl_no;
            for j = 1:5
                Ind_Rest(k) = aux_ind + j;
                k = k + 1;
            end
        end
end
end