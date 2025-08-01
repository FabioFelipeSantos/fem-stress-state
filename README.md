# Finite Element Method (FEM) program under Plane Stress Conditions

## Overview

This repository contains a MATLAB-based Finite Element Method (FEM) program for the analysis of structures under plane stress conditions. The code is capable of analyzing both beams and plates, including those made of laminated composite materials. It uses quadrilateral elements to discretize the structure and calculates the nodal displacements based on the applied loads and boundary conditions.

## Features

-   **Analysis Types**:
    -   **Beams ('viga')**: Utilizes Euler-Bernoulli theory.
    -   **Plates ('placa')**: Utilizes Mindlin plate theory, suitable for both thin and thick plates.
-   **Element Types**:
    -   4-node linear quadrilateral elements.
    -   9-node bilinear quadrilateral elements.
-   **Material Models**:
    -   Isotropic materials for beam analysis.
    -   Laminated composite materials for plate analysis, allowing for the definition of multiple layers with different fiber orientations and material properties.
-   **Loading Conditions**:
    -   Concentrated nodal forces.
    -   Uniformly or linearly distributed surface loads (traction) and pressures.
-   **Boundary Conditions**:
    -   Pre-configured boundary conditions for simply supported or clamped edges.

## How to Run

1.  **Configuration**: Open the main script `Programa_Principal_FEM_EPT.m` in MATLAB.
2.  **Select Structure Type**:
    -   Set the `tipoEstrutura` variable to either `'viga'` for beam analysis or `'placa'` for plate analysis.
3.  **Define Geometry**:
    -   In the `InfoGeo` global structure, define the length (`L`), height/width (`h`), and thickness (`t`) of the structure.
4.  **Define Mesh**:
    -   In the `InfoMesh` global structure, specify the number of subdivisions in the X and Y directions (`numDeSubDivX`, `numDeSubDivY`) and the number of nodes per element (`nosPorElemento`, either 4 or 9).
5.  **Define Material Properties**:
    -   For **plate analysis**, configure the laminate properties in the `Laminado.m` file. This includes the angle, thickness, and elastic properties for each layer.
    -   For **beam analysis**, the isotropic material properties (Young's Modulus `E` and Poisson's ratio `nu`) are set directly within `Programa_Principal_FEM_EPT.m`.
6.  **Define Loads**:
    -   Open the `Cargas.m` file to specify concentrated (`CargaConc`) and distributed (`CargaDist`) loads. The file contains detailed instructions on how to format the load matrices.
7.  **Define Boundary Conditions**:
    -   In `Programa_Principal_FEM_EPT.m`, set the `tipoApoio` variable to select the desired boundary condition. The available options are described in the `CondCont.m` file.
8.  **Execute**:
    -   Run the `Programa_Principal_FEM_EPT.m` script.

## Code Structure

The project is organized into several MATLAB functions, each responsible for a specific part of the FEM analysis:

| File Name                          | Description                                                                                                    |
| :--------------------------------- | :------------------------------------------------------------------------------------------------------------- |
| **`Programa_Principal_FEM_EPT.m`** | **Main script** that orchestrates the entire analysis, from setting up the problem to solving for the results. |
| `nosElem4.m` / `nosElem9.m`        | Generates the mesh coordinates and element connectivity for 4-node and 9-node elements, respectively.          |
| `GraficoMalha.m`                   | Plots the generated finite element mesh.                                                                       |
| `Laminado.m`                       | Defines the laminate stacking sequence and calculates the constitutive matrices for composite plates.          |
| `Cargas.m`                         | Defines the applied concentrated and distributed loads.                                                        |
| `CondCont.m`                       | Applies the specified boundary conditions to the global stiffness matrix and force vector.                     |
| `shapefunctions.m`                 | Computes the element shape functions and their derivatives in the natural coordinate system.                   |
| `Jacobian.m`                       | Calculates the Jacobian matrix for transforming between natural and physical coordinates.                      |
| `shapefunctionderivatives.m`       | Computes the shape function derivatives with respect to the physical coordinates (x, y).                       |
| `MatrizB.m`                        | Constructs the strain-displacement matrix (B-matrix) for both bending and shear components.                    |
| `Forcas.m`                         | Calculates the equivalent nodal forces from distributed surface loads using numerical integration.             |
| `GaussQuadrature.m`                | Provides points and weights for Gaussian quadrature numerical integration.                                     |
| `Sobreposicao.m`                   | Assembles the global stiffness matrix and force vector by superimposing the element matrices.                  |
| `GrausLiberdade.m`                 | Determines the global degree of freedom indices for each element.                                              |

## Expected Output

-   **Nodal Displacements (`U`)**: The primary output is the vector `U`, which contains the displacement and rotation values for each degree of freedom in the model. The main script demonstrates how to extract the displacement at the center of the plate.
-   **Mesh Plot**: If uncommented, the `GraficoMalha()` function will generate and save a PDF file named `Malha em EF.pdf` showing the discretized structure.

Further post-processing can be performed on the displacement vector `U` and the calculated element matrices to determine stresses and strains throughout the structure.
