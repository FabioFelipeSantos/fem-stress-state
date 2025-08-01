function [LaminadoInfo, C, E] = Laminado(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Fun��o que armazena as informa��es de cada l�mina e realiza o c�lculo da matriz de
%   rigidez C do laminado.
%
%   As informa��es de cada l�mina dever�o ser passadas por meio de uma matriz com 8
%   colunas onde cada linha representa uma l�mina. As colunas ir�o representar:
%       1 - �ngulo de dire��o da fibra (em graus);
%       2 - altura (thickness) em metros;
%       3 - E1 = m�dulo de elasticidade na dire��o da fibra (N/m^2);
%       4 - E2 = m�dulo de elasticidade na dire��o perpendicular � da fibra (N/m^2);
%       5 - G12 = m�dulo de cisalhamento no plano 12 da l�mina (N/m^2);
%       6 - G13 = m�dulo de cisalhamento no plano 13 da l�mina (N/m^2);
%       7 - G23 = m�dulo de cisalhamento no plano 23 da l�mina (N/m^2);
%       8 - nu12 = coeficiente de Poisson no plano 12 da l�mina;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Informa��es do laminado
% E2 = 7e9;
% E1 = 25*E2;
% G12 = 0.5*E2;
% G13 = G12;
% G23 = 0.2*E2;
% nu12 = 0.25;

% E1 = 2e11;
% E2 = 2e11;
% nu12 = 0.3;
% G12 = E1 / (2*(1+nu12));
% G13 = G12;
% G23 = G12;

E1 = 1.8282e6;
E2 = 1.8315e6;
nu12 = 0.2395;
G12 = 0.3125e6;
G13 = G12;
G23 = G12;

% E2 = 1.8315e6;
% E1 = 1.8282e6;
% G12 = 0.3125e6;
% G13 = G12;
% G23 = G12;
% nu12 = 0.2395;

LaminadoInfo(1, :) = [ 0, h/4, E1, E2, G12, G13, G23, nu12];
LaminadoInfo(2, :) = [90, h/4, E1, E2, G12, G13, G23, nu12];
LaminadoInfo(3, :) = [90, h/4, E1, E2, G12, G13, G23, nu12];
LaminadoInfo(4, :) = [ 0, h/4, E1, E2, G12, G13, G23, nu12];
% LaminadoInfo(5, :) = lamina2;
% LaminadoInfo(6, :) = lamina1;

% Colhe o n�mero de laminas
n = size(LaminadoInfo, 1);

% Cria o vetor com as cotas das l�minas
zk = zeros(1, n + 1);
zk(1) = -sum(LaminadoInfo(:, 2)) / 2;

for i = 1:n
    zk(i + 1) = zk(i) + LaminadoInfo(i, 2);
end

% Calcula a matriz Q
Q = zeros(3, 3);
Q(1, 1) = E1^2 / (E1 - (E2 * nu12^2));
Q(1, 2) = (nu12 * E1 * E2) / (E1 - (E2 * nu12^2));
Q(2, 1) = Q(1, 2);
Q(2, 2) = (E1 * E2) / (E1 - (E2 * nu12^2));
Q(3, 3) = G12;                  % Equivale ao Q66

% Q(1, 1) = E1 / (1 - (nu12^2));
% Q(1, 2) = (nu12 * E2) / (1 - (nu12^2));
% Q(2, 1) = Q(1, 2);
% Q(2, 2) = (E2) / (1 - (nu12^2));
% Q(3, 3) = G12;  

% Calcula a matriz Qbarra de cada l�mina
Qbarra = zeros(3,3,n);

for i = 1:n
    % �ngulo da l�mina
    t = degtorad(LaminadoInfo(i, 1));
    
    % Cosseno e Seno do �ngulo
    c = cos(t); s = sin(t);
    
    % Matriz de Transforma��o
    T = [c^2 s^2 -2*s*c; s^2 c^2 2*s*c; s*c -s*c (c^2 - s^2)];
    
    % Matriz Qbarra
    Qbarra(:, :, i) = T * Q * T';
end

% C�lculo das matrizes A, B e D
A = zeros(3, 3);
B = A; D = A;
E = zeros(2, 2);
for i = 1:n
    %-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    % Matriz Qbarra da l�mina
    Qaux = Qbarra(:, :, i);
    
    % Matriz A
    A = A + Qaux * (zk(i + 1) - zk(i));
    
    % Matriz B
    B = B + ((1 / 2)*Qaux*(zk(i + 1)^2 - zk(i)^2));
    
    % Matriz D
    D = D + ((1 / 3)*Qaux*(zk(i + 1)^3 - zk(i)^3));    
    %-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    
    %----------------------------C�lculo da matriz de cisalhamento------------------------
    % �ngulo da l�mina
    t = degtorad(LaminadoInfo(i, 1));
    
    % Cosseno e Seno do �ngulo
    c = cos(t); s = sin(t);
    
    QB44 = LaminadoInfo(i, 6) * (c^2) + LaminadoInfo(i, 7) * (s^2);
    QB45 = (LaminadoInfo(i, 7) - LaminadoInfo(i, 6)) * c * s;
    QB55 = LaminadoInfo(i, 6) * (s^2) + LaminadoInfo(i, 7) * (c^2);
    E = E + LaminadoInfo(i, 2) * [QB44, QB45; QB45, QB55];
    %-------------------------------------------------------------------------------------
end
ShearFactor = 5/6;

E = ShearFactor * E;

% Matriz de Rigidez do laminado
C = zeros(6,6);
C(1:3, 1:3) = A;
C(1:3, 4:6) = B;
C(4:6, 1:3) = B;
C(4:6, 4:6) = D;
end