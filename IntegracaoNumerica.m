function Mat = IntegracaoNumerica(
for intX = 1:nQuadFle       % Laço para os pontos de integração no eixo x
        xi = pontos_Fle(intX);      % Variável xi (parâmetro de int. eixo x)
        pesoX = weight_Fle(intX);   % Peso da variável xi
        
        for intY = 1:nQuadFle   % Laço para os pontos de integração no eixo y
            eta = pontos_Fle(intY);     % Variável eta (parâmetro de int. eixo y)
            pesoY = weight_Fle(intY);   % Peso da variável eta
            
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
            [B_f, B_c] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
                                                                            dN_dx, dN_dy);
            
            % Cálculo da matriz de Rigidez do Elemento
            % Parcela de Membrana-Flexão
            K_e = K_e + InfoGeo.t * B_f' * C * B_f * pesoX * pesoY * detJacobiana;
            
            % Parcela do Cisalhamento
            K_e = K_e + InfoGeo.t * B_c' * Mat_cis * B_c * pesoX * pesoY * detJacobiana;
            
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
                F_e = F_e + N_e * q * pesoX * pesoY * detJacobiana;                
            end
        end        
    end
end