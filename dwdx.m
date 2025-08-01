function dwdx(U, conec, coor)

noDer = [1, 1;0 -1; 0 0];

ws = (conec(1,:) - 1)*5 +3;
dw = zeros(3,2);
for i = 1:3
    [N, dN_dr, dN_ds] = shapefunctions(9, noDer(i, 1), noDer(i,2));
    Jacobiana = Jacobian(9, dN_dr, dN_ds, coor(:, 1), coor(:, 2));
    JacInv = Jacobiana^(-1);
    derivadas = JacInv * [dN_dr;dN_ds];
    dw(i,1) = sum(derivadas(1,:).*U(ws')');
    dw(i,2) = sum(derivadas(2,:).*U(ws')');
end
dw(:,1)
dw(:,2)
end