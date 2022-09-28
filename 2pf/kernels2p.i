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
  [porepressure]
    type = FunctionIC
    variable = ppwater
    function = '10000*(100-y)' 
  []
[]


[BCs]
  [pp]
    type = FunctionDirichletBC
    variable = ppwater
    function = 0
    boundary = top
  []
[]

[Modules]
  [FluidProperties]
    [the_simple_fluid]
      type = SimpleFluidProperties
    []
    [the_simple_fluid2]
      type = SimpleFluidProperties
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
    sat_lr = 0
  []
  [produced_mass]
    type = PorousFlowSumQuantity
  []
[]

[Kernels]
  [flux0]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = ppwater
    gravity = '0 -10 0'
  []
  [flux1]
    type = PorousFlowAdvectiveFlux
    fluid_component = 1
    variable = ppgas
    gravity = '0 -10 0'
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
    fp = the_simple_fluid
    phase = 0
  []
  [simple_fluid1]
    type = PorousFlowSingleComponentFluid
    fp = the_simple_fluid2
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
    n = 1
    phase = 0
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 1
  []
[]

[DiracKernels]
   [produce]
     type = PorousFlowPeacemanBorehole
     variable = ppwater
     SumQuantityUO = produced_mass
     mass_fraction_component = 0
     point_file = action.bh
     bottom_p_or_t = 1E-8
     unit_weight = '0 0 0'
     use_mobility = true
     character = 1
   []
[]

[Postprocessors]
  [bh_report]
    type = PorousFlowPlotQuantity
    uo = produced_mass
    execute_on = 'initial timestep_end'
  []
  [fluid_mass]
    type = PorousFlowFluidMass
    execute_on = 'initial timestep_end'
  []
[]

[Preconditioning]
  [andy]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  automatic_scaling = true
  compute_scaling_once = false
  line_search = none
  start_time = -3600
  dt = 3600
  end_time = 1728000
  #nl_rel_tol = 1E-10
  #nl_abs_tol = 1E-3
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]
