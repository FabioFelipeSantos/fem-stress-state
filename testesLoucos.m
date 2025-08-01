clear;
clc;

A = [4 1 2; 1 20 6; 2 6 12]

i = [1 1 1 2 2 3]';
j = [1 2 3 2 3 3]';
v = [4 1 2 20 6 12]'

sparse(A)

B = sparse(i, j, v)

C1 = A^(-1)
C2 = B^(-1)

A*C1
B*C2

C1*A
C2*B

A*C2
B*C1
