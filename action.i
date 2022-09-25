[Mesh]
  [the_mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 5
    ny = 50
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
  [porepressure]
  []
[]

[ICs]
  [porepressure]
    type = FunctionIC
    variable = porepressure
    function = '10000*(100-y)' 
  []
[]


[BCs]
  [pp]
    type = FunctionDirichletBC
    variable = porepressure
    function = 0
    boundary = top
  []
[]

[Modules]
  [FluidProperties]
    [the_simple_fluid]
      type = SimpleFluidProperties
    []
  []
[]

[PorousFlowUnsaturated]
  coupling_type = Hydro
  porepressure = porepressure
  gravity = '0 -10 0'
  fp = the_simple_fluid
  relative_permeability_exponent = 3
  relative_permeability_type = Corey
  residual_saturation = 0.0
  van_genuchten_alpha = 1E-5
  van_genuchten_m = .6
[]

[AuxVariables]
  [saturation]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [saturation]
    type = PorousFlowPropertyAux
    variable = saturation
    property = saturation
    phase = 0
  []
[]

[Materials]
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
[]

[DiracKernels]
   [produce]
     type = PorousFlowPeacemanBorehole
     variable = porepressure
     SumQuantityUO = produced_mass
     mass_fraction_component = 0
     point_file = action.bh
     bottom_p_or_t = 1E-8
     unit_weight = '0 0 0'
     use_mobility = true
     character = 1
   []
[]

[UserObjects]
  [produced_mass]
    type = PorousFlowSumQuantity
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
  start_time = -3600
  dt = 3600
  end_time = 172800
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]
