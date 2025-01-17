[Mesh]
  type = GeneratedMesh
  dim = 3
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[AuxVariables]
  [./temperature]
  [../]
[]

[AuxKernels]
  [./temp_aux]
    type = FunctionAux
    variable = temperature
    function = temp_fcn
    execute_on = 'initial timestep_begin'
  [../]
[]

[Functions]
  [./rhom_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 1
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./rhoi_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 2
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./vmJ2_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 3
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./evm_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 4
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./temp_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 5
    format = columns
    xy_in_file_only = false
    direction = right
  [../]

  [./rhom_soln_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 7
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./rhoi_soln_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 8
    format = columns
    xy_in_file_only = false
    direction = right
  [../]
  [./creep_rate_soln_fcn]
    type = PiecewiseConstant
    data_file = ss316_verification_data.csv
    x_index_in_file = 0
    y_index_in_file = 10
    format = columns
    xy_in_file_only = false
    direction = right
  [../]

  [./rhom_diff_fcn]
    type = ParsedFunction
    vars = 'rhom_soln rhom'
    vals = 'rhom_soln rhom'
    value = 'abs(rhom_soln - rhom) / rhom_soln'
  [../]
  [./rhoi_diff_fcn]
    type = ParsedFunction
    vars = 'rhoi_soln rhoi'
    vals = 'rhoi_soln rhoi'
    value = 'abs(rhoi_soln - rhoi) / rhoi_soln'
  [../]
  [./creep_rate_diff_fcn]
    type = ParsedFunction
    vars = 'creep_rate_soln creep_rate'
    vals = 'creep_rate_soln creep_rate'
    value = 'abs(creep_rate_soln - creep_rate) / creep_rate_soln'
  [../]
[]


[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    generate_output = 'vonmises_stress'
    use_automatic_differentiation = true
  [../]
[]

[BCs]
  [./symmx]
    type = ADPresetBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./symmy]
    type = ADPresetBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./symmz]
    type = ADPresetBC
    variable = disp_z
    boundary = back
    value = 0
  [../]
  [./pressure_x]
    type = ADPressure
    variable = disp_x
    component = 0
    boundary = right
    function = vmJ2_fcn
    constant = 0.5e6
  [../]
  [./pressure_y]
    type = ADPressure
    variable = disp_y
    component = 1
    boundary = top
    function = vmJ2_fcn
    constant = -0.5e6
  [../]
  [./pressure_z]
    type = ADPressure
    variable = disp_z
    component = 2
    boundary = front
    function = vmJ2_fcn
    constant = -0.5e6
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e11
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = rom_stress_prediction
  [../]
  [./rom_stress_prediction]
    type = SS316HLAROMANCEStressUpdateTest
    temperature = temperature
    effective_inelastic_strain_name = effective_creep_strain
    internal_solve_full_iteration_history = true
    apply_strain = false
    outputs = all
    immobile_dislocation_density_forcing_function = rhoi_fcn
    mobile_dislocation_density_forcing_function = rhom_fcn
    old_creep_strain_forcing_function = evm_fcn
  [../]
[]

[Executioner]
  type = Transient

  solve_type = 'NEWTON'

  petsc_options = '-snes_ksp_ew -snes_converged_reason -ksp_converged_reason'# -ksp_error_if_not_converged -snes_error_if_not_converged'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'
  automatic_scaling = true
  compute_scaling_once = false

  nl_abs_tol = 1e-10

  dt = 1e-3
  end_time = 1e-2
[]

[Postprocessors]
  [./effective_strain_avg]
    type = ElementAverageValue
    variable = effective_creep_strain
  [../]
  [./temperature]
    type = ElementAverageValue
    variable = temperature
  [../]
  [./rhom]
    type = ElementAverageValue
    variable = mobile_dislocations
  [../]
  [./rhoi]
    type = ElementAverageValue
    variable = immobile_dislocations
  [../]
  [./vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
  [../]
  [./creep_rate]
    type = ElementAverageValue
    variable = creep_rate
  [../]
  [./rhom_in]
    type = FunctionValuePostprocessor
    function = rhom_fcn
    execute_on = 'TIMESTEP_END initial'
  [../]
  [./rhoi_in]
    type = FunctionValuePostprocessor
    function = rhoi_fcn
    execute_on = 'TIMESTEP_END initial'
  [../]
  [./vmJ2_in]
    type = FunctionValuePostprocessor
    function = vmJ2_fcn
    execute_on = 'TIMESTEP_END initial'
  [../]
  [./rhom_soln]
    type = FunctionValuePostprocessor
    function = rhom_soln_fcn
  [../]
  [./rhoi_soln]
    type = FunctionValuePostprocessor
    function = rhoi_soln_fcn
  [../]
  [./creep_rate_soln]
    type = FunctionValuePostprocessor
    function = creep_rate_soln_fcn
  [../]

  [./rhom_diff]
    type = FunctionValuePostprocessor
    function = rhom_diff_fcn
  [../]
  [./rhoi_diff]
    type = FunctionValuePostprocessor
    function = rhoi_diff_fcn
  [../]
  [./creep_rate_diff]
    type = FunctionValuePostprocessor
    function = creep_rate_diff_fcn
  [../]

  [./rhom_max_diff]
    type = TimeExtremeValue
    postprocessor = rhom_diff
  [../]
  [./rhoi_max_diff]
    type = TimeExtremeValue
    postprocessor = rhoi_diff
  [../]
  [./creep_rate_max_diff]
    type = TimeExtremeValue
    postprocessor = creep_rate_diff
  [../]
[]

[Outputs]
  csv = true
  file_base = 'verification_1e-3_out'
[]
