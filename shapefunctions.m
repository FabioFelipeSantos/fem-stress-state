function [shape,dhdr,dhds]=shapefunctions(noel, xi,eta)

%------------------------------------------------------------------------
%  Purpose:
%     compute isoparametric four-node Quadilateral shape functions
%     and their derivatves at the selected (integration) point
%     in terms of the natural coordinate 
%
%  Synopsis:
%     [shapeQ4,dhdrQ4,dhdsQ4]=shapefunctions(xi,eta)  
%
%  Variable Description:
%     shapeQ4 - shape functions for four-node element
%     dhdrQ4 - derivatives of the shape functions w.r.t. r
%     dhdsQ4 - derivatives of the shape functions w.r.t. s
%     xi - r coordinate value of the selected point   
%     eta - s coordinate value of the selected point
%
%  Notes:
%     1st node at (-1,-1), 2nd node at (1,-1)
%     3rd node at (1,1), 4th node at (-1,1)
%------------------------------------------------------------------------
if (noel == 4)
    % shape functions

     shape(1)=0.25*(1-xi)*(1-eta);
     shape(2)=0.25*(1+xi)*(1-eta);
     shape(3)=0.25*(1+xi)*(1+eta);
     shape(4)=0.25*(1-xi)*(1+eta);

    % derivatives

     dhdr(1)=-0.25*(1-eta);
     dhdr(2)=0.25*(1-eta);
     dhdr(3)=0.25*(1+eta);
     dhdr(4)=-0.25*(1+eta);

     dhds(1)=-0.25*(1-xi);
     dhds(2)=-0.25*(1+xi);
     dhds(3)=0.25*(1+xi);
     dhds(4)=0.25*(1-xi);
else
    %shape functions
    Lx(1) = 0.5*xi*(xi-1);
    Lx(2) = 1-xi^2;
    Lx(3) = 0.5*xi*(xi+1);
    Ly(1) = 0.5*eta*(eta-1);
    Ly(2) = 1-eta^2;
    Ly(3) = 0.5*eta*(eta+1);
    shape(1) = Lx(1)*Ly(1);
    shape(2) = Lx(3)*Ly(1);
    shape(3) = Lx(3)*Ly(3);
    shape(4) = Lx(1)*Ly(3);
    shape(5) = Lx(2)*Ly(1);
    shape(6) = Lx(3)*Ly(2);
    shape(7) = Lx(2)*Ly(3);
    shape(8) = Lx(1)*Ly(2);
    shape(9) = Lx(2)*Ly(2);
    
    % derivatives of a Lagrangean's functions
    DxLx(1) = xi - 0.5;
    DxLx(2) = - 2 * xi;
    DxLx(3) = xi + 0.5;
    DyLy(1) = eta - 0.5;
    DyLy(2) = - 2 * eta;
    DyLy(3) = eta + 0.5;
    
    % derivatives shape function in r (x) direction
    dhdr(1) = DxLx(1)*Ly(1);
    dhdr(2) = DxLx(3)*Ly(1);
    dhdr(3) = DxLx(3)*Ly(3);
    dhdr(4) = DxLx(1)*Ly(3);
    dhdr(5) = DxLx(2)*Ly(1);
    dhdr(6) = DxLx(3)*Ly(2);
    dhdr(7) = DxLx(2)*Ly(3);
    dhdr(8) = DxLx(1)*Ly(2);
    dhdr(9) = DxLx(2)*Ly(2);
    
    % derivatives shape function in s (y) direction
    dhds(1) = Lx(1)*DyLy(1);
    dhds(2) = Lx(3)*DyLy(1);
    dhds(3) = Lx(3)*DyLy(3);
    dhds(4) = Lx(1)*DyLy(3);
    dhds(5) = Lx(2)*DyLy(1);
    dhds(6) = Lx(3)*DyLy(2);
    dhds(7) = Lx(2)*DyLy(3);
    dhds(8) = Lx(1)*DyLy(2);
    dhds(9) = Lx(2)*DyLy(2);    
end










