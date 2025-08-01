function Mat = IntegracaoNumerica(
for intX = 1:nQuadFle       % La�o para os pontos de integra��o no eixo x
        xi = pontos_Fle(intX);      % Vari�vel xi (par�metro de int. eixo x)
        pesoX = weight_Fle(intX);   % Peso da vari�vel xi
        
        for intY = 1:nQuadFle   % La�o para os pontos de integra��o no eixo y
            eta = pontos_Fle(intY);     % Vari�vel eta (par�metro de int. eixo y)
            pesoY = weight_Fle(intY);   % Peso da vari�vel eta
            
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
            [B_f, B_c] = MatrizB(tipoEstrutura, InfoMesh.nosPorElemento, ngl_no, N, ...
                                                                            dN_dx, dN_dy);
            
            % C�lculo da matriz de Rigidez do Elemento
            % Parcela de Membrana-Flex�o
            K_e = K_e + InfoGeo.t * B_f' * C * B_f * pesoX * pesoY * detJacobiana;
            
            % Parcela do Cisalhamento
            K_e = K_e + InfoGeo.t * B_c' * Mat_cis * B_c * pesoX * pesoY * detJacobiana;
            
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
                F_e = F_e + N_e * q * pesoX * pesoY * detJacobiana;                
            end
        end        
    end
end