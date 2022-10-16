[Mesh]
  [the_mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 5
    ny = 100
    xmin = 0
    xmax = 5
    ymin = 0
    ymax = 100
  []
  [aquitard]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 50 0'
    top_right = '5 100 0'
    input = the_mesh
  []
  [aquifer]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '0 0 0'
    top_right = '5 50 0'
    input = aquitard
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  biot_coefficient = 1.0
[]

[Variables]
  [ppwater]
  []
  [ppgas]
  initial_condition = 0.0
  []
[]

[ICs]
  [ppwater]
    type = FunctionIC
    variable = ppwater
    function = '10000*(100-y)' 
  []
[]


[BCs]
  [ppwater_top]
    type = FunctionDirichletBC
    variable = ppwater
    function = 0
    boundary = top
  []
[]

[Modules]
  [FluidProperties]
    [water]
      type = SimpleFluidProperties
    []
  [co2]
    type = SimpleFluidProperties
    bulk_modulus = 2.27e14
    density0 = 516.48
    viscosity = 0.0393e-3
    cv = 2920.5
    cp = 2920.5
    porepressure_coefficient = 0.0
    thermal_expansion = 0
  []
  []
[]

[AuxVariables]
  [swater]
    family = MONOMIAL
    order = FIRST
  []
  [massfrac_ph0_sp0]
    initial_condition = 1
  []
  [massfrac_ph1_sp0]
    initial_condition = 0
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'ppwater ppgas'
    number_fluid_phases = 2
    number_fluid_components = 2
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.6
    alpha = 1e-5
    sat_lr = 0.0
    #s_scale = 0.1
    #pc_max = 1E4
  []
  [inj_mass]
    type = PorousFlowSumQuantity
  []
  [afc_component0_phase0]
    type = PorousFlowAdvectiveFluxCalculatorUnsaturatedMultiComponent
    fluid_component = 0
    phase = 0
    flux_limiter_type = superbee
    gravity = '0 -10 0'
  []
  [afc_component1_phase1]
    type = PorousFlowAdvectiveFluxCalculatorUnsaturatedMultiComponent
    fluid_component = 1
    phase = 1
    flux_limiter_type = superbee
    gravity = '0 -10 0'
  []
[]

[Kernels]
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = ppwater
  []
  [flux_component0_phase0]
    type = PorousFlowFluxLimitedTVDAdvection
    variable = ppwater
    advective_flux_calculator = afc_component0_phase0
  []
  [mass1]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = ppgas
  []
  [flux_component1_phase1]
    type = PorousFlowFluxLimitedTVDAdvection
    variable = ppgas
    advective_flux_calculator = afc_component1_phase1
  []
[]

[AuxKernels]
  [swater]
    type = PorousFlowPropertyAux
    property = saturation
    phase = 0
    variable = swater
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [simple_fluid0]
    type = PorousFlowSingleComponentFluid
    fp = water
    phase = 0
  []
  [simple_fluid1]
    type = PorousFlowSingleComponentFluid
    fp = co2	
    phase = 1
  []
  [ppss]
    type = PorousFlow2PhasePP
    phase0_porepressure = ppwater
    phase1_porepressure = ppgas
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
    mass_fraction_vars = 'massfrac_ph0_sp0 massfrac_ph1_sp0'
  []
  
  
  [porosity_clay]
    type = PorousFlowPorosity
    porosity_zero = 0.3
    block = 1
  []
  [permeability_clay]
    type = PorousFlowPermeabilityConst
    permeability = '1E-20 0 0   0 1E-20 0   0 0 1E-20'
    block = 1
  []
  [porosity_rock]
    type = PorousFlowPorosity
    porosity_zero = 0.05
    block = 2
  []
  [permeability_rock]
    type = PorousFlowPermeabilityConst
    permeability = '1E-13 0 0   0 1E-13 0   0 0 1E-14'
    block = 2
  []
  
  [relperm_water]
    type = PorousFlowRelativePermeabilityCorey
    n = 3
    phase = 0
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    n = 3
    phase = 1
  []
[]

[DiracKernels]
   [inj]
     type = PorousFlowPeacemanBorehole
     variable = ppgas
     SumQuantityUO = inj_mass
     mass_fraction_component = 1
     fluid_phase = 1
     point_file = action.bh
     bottom_p_or_t = 3E6
     unit_weight = '0 0 0'
     #use_mobility = false
     character = -1
   []
[]


[Postprocessors]
  [bh_report]
    type = PorousFlowPlotQuantity
    uo = inj_mass
    execute_on = 'initial timestep_end'
  []
  [fluid_mass]
    type = PorousFlowFluidMass
    execute_on = 'initial timestep_end'
  []
[]


[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      lu           NONZERO                   2'
  []
  [lu]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [moose]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
    petsc_options_value = 'hypre boomeramg 500'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  start_time = -1
  dt = 1
  end_time = 172800
  #nl_rel_tol = 1E-10
  nl_abs_tol = 1E-7
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

