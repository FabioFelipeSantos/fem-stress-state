function [coordenadas9,iconec9] = nosElem9()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que realiza a constru��o da malha retangular de elementos finitos com 4 pontos
%   (malha retangular linear).
%
%   Entrada:
%       N�o h� entrada de vari�veis.
%
%   Sa�da:
%       coordenadas4 - matriz de coordenadas x e y da malha retangular. Cada linha um n�;
%       iconec - matriz de conectividade dos elementos. Cada linha representa um elemento.
%
%	Vari�vel Global:
%       InfoMesh - struct com as informa��es da malha de EF.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global InfoMesh

% Realiza a retirada dos dados da struct InfoMesh
nosCanto = InfoMesh.nosCanto;
numDeElem = InfoMesh.numDeElem;
numDeSubDivX = InfoMesh.numDeSubDivX;
numDeSubDivY = InfoMesh.numDeSubDivY;
compX = InfoMesh.compX;
compY = InfoMesh.compY;

% N�mero total de n�s
numDeNos = InfoMesh.nosCanto + numDeSubDivX * (numDeSubDivY + 1)...
                             + (numDeSubDivX + 1) * numDeSubDivY...
                             + numDeElem;

coordenadas9 = zeros(numDeNos, 2);       % Cria a matriz de coordenadas

% Cria��o da matriz de Conectivadade
iconec9 = zeros(numDeElem, 9);       % Matriz de Conectividade

% Vari�veis auxiliares para o c�lculo dos n�s
aux1 = 0;
aux2 = 0; 

%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
% Cria os primeiros n�s e as conectividades iniciais dos elementos
% C�lculo dos valores das coordenadas de cada n� de canto do elemento 
for i = 1:nosCanto
    coordenadas9(i, 1) = compX * aux1;
    coordenadas9(i, 2) = compY * aux2;
    
    aux1 = aux1 + 1;
    if aux1 == numDeSubDivX + 1
        aux1 = 0;
        aux2 = aux2 + 1;
    end
end

% Vari�veis auxiliares para o c�lculo da conectividade
aux1 = 0;
aux2 = 1;
k = 1;
%-----------------------------------------------------
% C�lculo da conectividade de cada elemento
% Para os n�s de conectividade inferiores
for i = 1:(numDeSubDivY)
    for j = 1:(numDeSubDivX)
        % Conectividades Inferiores
        iconec9(k,1) = j + aux1 * (numDeSubDivX + 1);
        iconec9(k,2) = iconec9(k,1) + 1;
        
        % Conectividades Superiores
        iconec9(k,4) = j + aux2 * (numDeSubDivX + 1);
        iconec9(k,3) = iconec9(k,4) + 1;
        k = k + 1;
    end
    aux1 = aux1 + 1;
    aux2 = aux2 + 1;
end
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
% C�lculo dos demais n�s
% Vari�veis auxiliares para o c�lculo da conectividade
aux1 = 0;
aux2 = compX/2;
aux3 = 0;
k = 1;
%-----------------------------------------------------
% C�lculo da conectividade de cada elemento
% Para os n�s de conectividade inferiores
for i = 1:(numDeSubDivY+1)
    for j = 1:(numDeSubDivX)
        % N�s de centro horizontal (Quinto N�)
        ind = nosCanto + j + aux1*(numDeSubDivX);
        coordenadas9(ind,1) = aux2;
        coordenadas9(ind,2) = aux3;
        aux2 = aux2 + compX;
        
        % Conectividade Elemento 5 n�
        if i <= numDeSubDivY
            iconec9(k, 5) = ind;
            k = k+1;
        end
    end
    aux1 = aux1 + 1;
    aux2 = compX/2;
    aux3 = aux3 + compY;
end

% Aloca a conectividade do S�timo n�
aux1 = 1;
aux2 = compX/2;
aux3 = 0;

k = 1;
for i = 1:(numDeSubDivY)
    for j = 1:(numDeSubDivX)
        
        % Conectividade Elemento 5 n�
        ind = nosCanto + j + aux1*(numDeSubDivX);
        iconec9(k, 7) = ind;
        k = k+1;
    end
    aux1 = aux1 + 1;
end

% N�s na vertical, sexto n� da conectividade
aux1 = 0;
aux2 = 0;
aux3 = compY / 2;
k = 1;
ind1 = ind;
%-----------------------------------------------------
% C�lculo da conectividade de cada elemento
% Para os n�s de conectividade inferiores
for i = 1:(numDeSubDivY)
    for j = 1:(numDeSubDivX + 1)
        % N�s de centro horizontal (Quinto N�)
        ind = ind1 + j + aux1*(numDeSubDivX + 1);
        coordenadas9(ind,1) = aux2;
        coordenadas9(ind,2) = aux3;
        aux2 = aux2 + compX;
        
        % Conectividade do sexto e oitavo n� do Elemento
        if j <= numDeSubDivX
            iconec9(k, 8) = ind;    % oitavo
            iconec9(k, 6) = ind + 1;    % sexto
            k = k+1;
        end
    end
    aux1 = aux1 + 1;
    aux2 = 0;
    aux3 = aux3 + compY;
end


% C�lculo dos n�s centrais
% N�s na vertical, sexto n� da conectividade
aux1 = 0;
aux2 = compX / 2;
aux3 = compY / 2;
k = 1;
ind1 = ind;
%-----------------------------------------------------
% C�lculo da conectividade de cada elemento
% Para os n�s de conectividade inferiores
for i = 1:(numDeSubDivY)
    for j = 1:(numDeSubDivX)
        % N�s de centro horizontal (Quinto N�)
        ind = ind1 + j + aux1*numDeSubDivX;
        coordenadas9(ind,1) = aux2;
        coordenadas9(ind,2) = aux3;
        aux2 = aux2 + compX;
        
        % Conectividade do nono n� do Elemento
        iconec9(k, 9) = ind;    % oitavo        
        k = k+1;
    end
    aux1 = aux1 + 1;
    aux2 = compX / 2;
    aux3 = aux3 + compY;
end


