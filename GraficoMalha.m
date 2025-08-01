function GraficoMalha()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que realiza o gráfico da malha de elementos finitos
%
%   Não há entrada de dados e nem saída de dados. A saída será gráfica com a malha
%   retangular de elementos.
%
%   Variáveis Globais:
%       InfoMesh - struct com as informações da malha de EF.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global InfoMesh

% Recolhe somente a numeração dos nós de canto dos elementos quadragulares
conec = InfoMesh.elem_conec(:, 1:4);

% Cria as variáveis que irão armazenar as coordenadas dos quatro cantos de cada elemento
x = zeros(4, InfoMesh.numDeElem);       % Coordenadas x
y = zeros(4, InfoMesh.numDeElem);       % Coordenadas y

for i = 1:InfoMesh.numDeElem
    % Cria uma variável auxiliar com a conectividade do elemento em cálculo no laço
    aux_conec = conec(i, :);
    
    % Cria uma matriz auxiliar com somente as coordenadas dos nós do elemento em cálculo
    % no laço
    aux_coor = InfoMesh.coordenadas(aux_conec, :);
    
    % Armazena as coordenadas separadas
    x(:, i) = aux_coor(:, 1);
    y(:, i) = aux_coor(:, 2);
end

% Cálcula das dimensões L e h da malha
L = abs(max(InfoMesh.coordenadas(:,1)) - min(InfoMesh.coordenadas(:,1)));
h = abs(max(InfoMesh.coordenadas(:,2)) - min(InfoMesh.coordenadas(:,2)));

% Criação da figura
fig = figure ;
set(fig,'name','Malha em Elementos Finitos','numbertitle','off','color','w') ;

% Desenha os pontos da malha
plot(InfoMesh.coordenadas(:,1), InfoMesh.coordenadas(:,2),'or', 'MarkerSize', 5, ...
                    'MarkerFaceColor', 'r', 'MarkerEdgeColor','k');
hold on            

% Desenha os retângulos que representam os elementos
patch(x, y, 'k', 'FaceColor','none')

% Agora configura-se os eixos da plotagem
ax = gca;
ax.YLim = [min(InfoMesh.coordenadas(:,2)), max(InfoMesh.coordenadas(:,2))];
outerpos = ax.OuterPosition;        % Recolhe a posição externa dos eixos, incluindo label
ti = ax.TightInset;     % Armazena o espaço necessário para os ticks e labels
left = outerpos(1) + ti(1);         % Coordenada x do começo do eixo
bottom = outerpos(2) + ti(2);       % Coordenada y do começo do eixo 
ax_width = outerpos(3) - ti(1) - ti(3);     % Comprimeto x do eixo
ax_height = outerpos(4) - ti(2) - ti(4);    % Comprimento y do eixo
ax.Position = [left bottom ax_width ax_height];     % Ajusta os eixos na figura
ax.TickLabelInterpreter = 'Latex';  % Faz a saída dos ticks em latex

% Agora configura-se a saída para o papel ser do tamanho da plotagem
fig = gcf;                          % Figura atual (get current figure)
fig.PaperPositionMode = 'auto';     % Tamanho da figura se ajusta ao tamanho da figura 
                                    % exportada
fig_pos = fig.PaperPosition;        % Armazena a posição da figura pelos eixos        
fig.PaperSize = [fig_pos(3) fig_pos(4)];    % AJusta o tamanho do papel
hold off
print('Malha em EF', '-dpdf')     % Finalmente salva a figura em .pdf)
end