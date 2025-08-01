function [PontosGauss, PesosGauss] = GaussQuadrature(numPontos, dim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Função que determina os pontos de integração e os pesos para a quadratura de Gauss 
%   para problemas em duas dimensões.
% 
%   Entratada:
%       numPontos - número de pontos de integração. Estão programados de 1 a 6 pontos;
%       dim - dimensão da integração (número de variáveis).
%
%   Saída:
%       PontosGauss - matriz de dimensão ngl x 2, onde cada linha é uma combinação
%                     possível dos pontos de integração;
%       PesosGaus - matriz de dimensão ngl x 2, onde cada linha é uma combinação possível
%                   dos pesos de integração. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Chama a função que contém os pontos de integração
[Gausspoint, Gaussweight] = auxPontos(numPontos);

% Utiliza a função permn para calcaular todas as combinações possíveis dos numPontos no
% número dim de dimensões.
% Cálculo das combinações para os pontos
PontosGauss = permn(Gausspoint, dim);

% Cálculo das combinações para os pesos
PesosGauss = permn(Gaussweight, dim);
end

function [Gausspoint, Gaussweight] = auxPontos(numPontos)
% Inicializa os vetores auxiliares para o cálculo das matrizes
Gausspoint = zeros(numPontos,1);
Gaussweight = zeros(numPontos,1);

switch numPontos
    case 1
        % Pontos de Integração
        Gausspoint(1) = 0;
        
        % Pesos
        Gaussweight(1) = 2;
    case 2
        % Pontos de Integração
        Gausspoint(1) = - sqrt(1/3);
        Gausspoint(2) = sqrt(1/3);
        
        % Pesos
        Gaussweight(1) = 1;
        Gaussweight(2) = 1;        
    case 3
        % Pontos de Integração
        Gausspoint(1) = - sqrt(3/5);
        Gausspoint(2) = 0;
        Gausspoint(3) = sqrt(3/5);
        
        % Pesos
        Gaussweight(1) = 5 / 9;
        Gaussweight(2) = 8 / 9;
        Gaussweight(3) = 5 / 9;        
    case 4
        % Pontos de Integração
        Gausspoint(1) = - 0.861136311594052575223946488893;
        Gausspoint(2) = - 0.339981043584856264802665759103;
        Gausspoint(3) =   0.339981043584856264802665759103;
        Gausspoint(4) =   0.861136311594052575223946488893;
        
        % Pesos
        Gaussweight(1) = 0.347854845137453857373063949222;
        Gaussweight(2) = 0.652145154862546142626936050778;
        Gaussweight(3) = 0.652145154862546142626936050778;
        Gaussweight(4) = 0.347854845137453857373063949222;
    case 5
        % Pontos de Integração
		Gausspoint(1) = - 0.906179845938663992797626878299;
		Gausspoint(2) = - 0.538469310105683091036314420700;
		Gausspoint(3) =   0;
		Gausspoint(4) =   0.538469310105683091036314420700;
        Gausspoint(5) =   0.906179845938663992797626878299;
			
		% Pesos
		Gaussweight(1) = 0.236926885056189087514264040720;
		Gaussweight(2) = 0.478628670499366468041291514836;
		Gaussweight(3) = 128 / 255;
		Gaussweight(4) = 0.478628670499366468041291514836;
        Gaussweight(5) = 0.236926885056189087514264040720;
    case 6
        % Pontos de Integração
		Gausspoint(1) = - 0.932469514203152027812301554494;
		Gausspoint(2) = - 0.661209386466264513661399595020;
		Gausspoint(3) = - 0.238619186083196908630501721681;
		Gausspoint(4) =   0.238619186083196908630501721681;
        Gausspoint(5) =   0.661209386466264513661399595020;
		Gausspoint(6) =   0.932469514203152027812301554494;
			
		% Pesos
		Gaussweight(1) = 0.171324492379170345040296142173;
		Gaussweight(2) = 0.360761573048138607569833513838;
		Gaussweight(3) = 0.467913934572691047389870343990;
		Gaussweight(4) = 0.467913934572691047389870343990;
        Gaussweight(5) = 0.360761573048138607569833513838;
		Gaussweight(6) = 0.171324492379170345040296142173;
end
end

function [M, I] = permn(V, N, K)
% PERMN - permutations with repetition
%   Using two input variables V and N, M = PERMN(V,N) returns all
%   permutations of N elements taken from the vector V, with repetitions.
%   V can be any type of array (numbers, cells etc.) and M will be of the
%   same type as V.  If V is empty or N is 0, M will be empty.  M has the
%   size numel(V).^N-by-N. 
%
%   When only a subset of these permutations is needed, you can call PERMN
%   with 3 input variables: M = PERMN(V,N,K) returns only the K-ths
%   permutations.  The output is the same as M = PERMN(V,N) ; M = M(K,:),
%   but it avoids memory issues that may occur when there are too many
%   combinations.  This is particulary useful when you only need a few
%   permutations at a given time. If V or K is empty, or N is zero, M will
%   be empty. M has the size numel(K)-by-N. 
%
%   [M, I] = PERMN(...) also returns an index matrix I so that M = V(I).
%
%   Examples:
%     M = permn([1 2 3],2) % returns the 9-by-2 matrix:
%              1     1
%              1     2
%              1     3
%              2     1
%              2     2
%              2     3
%              3     1
%              3     2
%              3     3
%
%     M = permn([99 7],4) % returns the 16-by-4 matrix:
%              99     99    99    99
%              99     99    99     7
%              99     99     7    99
%              99     99     7     7
%              ...
%               7      7     7    99
%               7      7     7     7
%
%     M = permn({'hello!' 1:3},2) % returns the 4-by-2 cell array
%             'hello!'        'hello!'
%             'hello!'        [1x3 double]
%             [1x3 double]    'hello!'
%             [1x3 double]    [1x3 double]
%
%     V = 11:15, N = 3, K = [2 124 21 99]
%     M = permn(V, N, K) % returns the 4-by-3 matrix:
%     %        11  11  12
%     %        15  15  14
%     %        11  15  11
%     %        14  15  14
%     % which are the 2nd, 124th, 21st and 99th permutations
%     % Check with PERMN using two inputs
%     M2 = permn(V,N) ; isequal(M2(K,:),M)
%     % Note that M2 is a 125-by-3 matrix
%
%     % PERMN can be used generate a binary table, as in
%     B = permn([0 1],5)  
%
%   NB Matrix sizes increases exponentially at rate (n^N)*N.
%
%   See also PERMS, NCHOOSEK
%            ALLCOMB, PERMPOS on the File Exchange

% tested in Matlab 2016a
% version 6.1 (may 2016)
% (c) Jos van der Geest
% Matlab File Exchange Author ID: 10584
% email: samelinoa@gmail.com

% History
% 1.1 updated help text
% 2.0 new faster algorithm
% 3.0 (aug 2006) implemented very fast algorithm
% 3.1 (may 2007) Improved algorithm Roger Stafford pointed out that for some values, the floor
%   operation on floating points, according to the IEEE 754 standard, could return
%   erroneous values. His excellent solution was to add (1/2) to the values
%   of A.
% 3.2 (may 2007) changed help and error messages slightly
% 4.0 (may 2008) again a faster implementation, based on ALLCOMB, suggested on the
%   newsgroup comp.soft-sys.matlab on May 7th 2008 by "Helper". It was
%   pointed out that COMBN(V,N) equals ALLCOMB(V,V,V...) (V repeated N
%   times), ALLCMOB being faster. Actually version 4 is an improvement
%   over version 1 ...
% 4.1 (jan 2010) removed call to FLIPLR, using refered indexing N:-1:1
%   (is faster, suggestion of Jan Simon, jan 2010), removed REPMAT, and
%   let NDGRID handle this
% 4.2 (apr 2011) corrrectly return a column vector for N = 1 (error pointed
%    out by Wilson).
% 4.3 (apr 2013) make a reference to COMBNSUB
% 5.0 (may 2015) NAME CHANGED (COMBN -> PERMN) and updated description,
%   following comment by Stephen Obeldick that this function is misnamed
%   as it produces permutations with repetitions rather then combinations.
% 5.1 (may 2015) always calculate M via indices
% 6.0 (may 2015) merged the functionaly of permnsub (aka combnsub) and this
%   function
% 6.1 (may 2016) fixed spelling errors

narginchk(2,3) ;

if fix(N) ~= N || N < 0 || numel(N) ~= 1 ;
    error('permn:negativeN','Second argument should be a positive integer') ;
end
nV = numel(V) ;

if nargin == 2, % PERMN(V,N) - return all permutations
    
    if nV==0 || N == 0,
        M = zeros(nV,N) ;
        I = zeros(nV,N) ;
        
    elseif N == 1,
        % return column vectors
        M = V(:) ;
        I = (1:nV).' ;
    else
        % this is faster than the math trick used for the call with three
        % arguments.
        [Y{N:-1:1}] = ndgrid(1:nV) ;
        I = reshape(cat(N+1,Y{:}),[],N) ;
        M = V(I) ;
    end
else % PERMN(V,N,K) - return a subset of all permutations
    nK = numel(K) ;
    if nV == 0 || N == 0 || nK == 0
        M = zeros(numel(K), N) ;
        I = zeros(numel(K), N) ;
    elseif nK < 1 || any(K<1) || any(K ~= fix(K))
        error('permn:InvalidIndex','Third argument should contain positive integers.') ;
    else
        
        V = reshape(V,1,[]) ; % v1.1 make input a row vector
        nV = numel(V) ;
        Npos = nV^N ;
        if any(K > Npos)
            warning('permn:IndexOverflow', ...
                'Values of K exceeding the total number of combinations are saturated.')
            K = min(K, Npos) ;
        end
             
        % The engine is based on version 3.2 with the correction
        % suggested by Roger Stafford. This approach uses a single matrix
        % multiplication.
        B = nV.^(1-N:0) ;
        I = ((K(:)-.5) * B) ; % matrix multiplication
        I = rem(floor(I),nV) + 1 ;
        M = V(I) ;
    end
end
end