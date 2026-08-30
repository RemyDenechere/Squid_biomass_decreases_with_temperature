# Historical squid biomass increase is not explained by rising temperature but rather by loss of top predators

Rémy Denéchère, P. Daniël van Denderen, and Ken H. Andersen

*Centre for Ocean Life, National Institute of Aquatic Resources (DTU Aqua), Technical University of Denmark, Lyngby, Denmark*

---

## Overview

This repository contains the MATLAB code used to generate all figures and analyses for the paper investigating two hypotheses for the historical
increase in squid biomass: (1) loss of top predators due to fishing and (2) rising ocean temperatures.

The model is based on the **FEISTY-squid** framework (Denéchère et al., 2024), a size- and trait-based model of upper trophic level communities 
that resolves five functional groups: small pelagic fish, large pelagic fish, demersal fish, mesopelagic fish, and squid.

## Requirements

- MATLAB R2023a or later (tested on R2026a)
- No additional toolboxes are required beyond base MATLAB

## Repository structure
├──FIG/<br>
├──SRC/<br>
│ └── Figure_paper.mlx Main script: generates Figures 1–4 <br>
│ └── Supplementary_paper.mlx Supplementary script: generates Figures SB1–SB2 <br>
│ └── baseparameters.m Default model parameters (physiology, sizes, interactions)<br>
│ └── baseparam_depth.m Depth-dependent parameters (vertical habitat, feeding preferences)<br>
│ └── baseparam_temp.m Temperature scaling of physiological rates <br>
│ └── poem.m Main ODE solver wrapper (runs model to equilibrium) <br>
│ └── poem_deriv.m Right-hand side of the ODE system (growth, mortality, reproduction) <br>
│ └── calcEncounter.m Encounter rates, feeding level, and predation mortality <br>
│ └── calcpreference.m Vertical distribution and predator–prey overlap matrix <br>
│ └── calctemperature.m Temperature scaling using Q₁₀ and depth profiles <br>
│ └── calcNu.m Growth rate and biomass flux between size classes <br>
│ └── PlotEcosystem.m Food-web visualization (Fig. 1) <br>
│ └── plotdiet_squid.m Squid diet composition plot (Fig. 3A, B) <br>
│ └── plotmort_squid.m Squid predation mortality plot (Fig. 3C)<br>
│ └── ciplot.m Shaded confidence-interval helper function<br>
│ └── save_graph.m Figure export helper (PDF, PNG, SVG, EPS) <br>
│ └── axes_formating.m Axes default formatting helper <br>
│ └── tempdata.mat Temperature depth profiles by region (loaded by calctemperature.m)

---

# Key parameters

The main parameters controlling the experiments are defined in baseparameters.m and modified in the live scripts:
  -  Depth: m
  -  Zooplankton productivity: range 5–150 g WW m⁻² yr⁻¹
  -  Fishing intensity: varied from 0.1 to 3 yr⁻¹ on large demersal (shelf) or large pelagic (open ocean) fish
  -  Temperature: baseline 10 °C, tested at ±2 °C
  -  Q₁₀ values: 1.88 (default Fish); sensitivity tested at 1.5 and 2.1 for clearance rate, maximum consumption, and metabolic cost. 

# Model description

FEISTY-squid extends the FEISTY framework by adding squid as a fifth functional group with faster growth rates (5× higher than fish)
and a distinct predator–prey size ratio (β = 50 for squid vs. 400 for fish). The model resolves:
   - Size-based feeding via a size preference error function.
   - Vertical habitat overlap through day/night depth Gaussian distributions.
   - Temperature effects on maximum consumption (C_max), clearance rate (V), and metabolic cost (M_c) via Q₁₀ scalings 
   - Size-selective fishing following a logistic selectivity function

Full model equations are documented in Denéchère et al. (2024).


# Citation

If you use this code, please cite:

Denéchère, R., van Denderen, P. D., & Andersen, K. H. (2026).
Historical squid biomass increase is not explained by rising temperature
but rather by loss of top predators. [Journal name], [volume], [pages].

# Contact

Rémy Denéchère — rdenechere@ucsd.edu

