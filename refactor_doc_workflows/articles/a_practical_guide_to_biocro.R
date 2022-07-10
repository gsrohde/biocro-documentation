## ----solve_latex_color_problems,include=FALSE,error=TRUE----------------------
if (packageVersion('knitr') >= "1.39") {
  knitr::opts_knit$set(latex.options.xcolor = 'dvipsnames')
} else {
  knitr::knit_hooks$set(document = function(x) {
    sub('\\usepackage[]{color}', '\\usepackage[dvipsnames]{xcolor}', x, fixed = TRUE)
  })
}

## ----preliminaries,echo=FALSE,error=TRUE--------------------------------------
knitr::opts_chunk$set(error=TRUE) # don't stop on errors; display them
                                  # in results; this is the default;
                                  # we override this below when
                                  # loading needed packages
knitr::opts_chunk$set(fig.width=5, fig.height=3)

## ----version_info,echo=FALSE,comment=''---------------------------------------
# Show the current commit hash and the date of that commit.
cat(
  paste0(
    system2('git',
            args = c('show',
                     '-s',
                     '--format="This document was generated from the version of BioCro specified as follows:%n%nCommit Hash: %h%nDate: %aD"'
                    ),
            stdout = TRUE
    ),
    sep = '',
    collapse = '\n'
  ),
  "\nBranch:",
  system2('git',
          args = c('branch',
                   '--show-current'),
          stdout = TRUE
  ),
  "\n"
)

## ----loading_libraries,error=FALSE--------------------------------------------
library(BioCro)
library(lattice)

## ----installing_lattice,eval=FALSE--------------------------------------------
#  install.packages('lattice')

## ----help_example,eval=FALSE--------------------------------------------------
#  # Access documentation for a BioCro function when the package is loaded
#  ?run_biocro
#  
#  # Access documentation for a BioCro data set, even if the package is not loaded
#  ?BioCro::soybean_parameters
#  
#  # Access documentation for a base R function
#  ?list
#  
#  # Access documentation for an R operator, which must be quoted using ', `, or "
#  ?`<-`

## ----run_biocro---------------------------------------------------------------
soybean_result = run_biocro(
  soybean_initial_values,
  soybean_parameters,
  soybean_weather2002,
  soybean_direct_modules,
  soybean_differential_modules,
  soybean_ode_solver
)

## ----example_module_vector----------------------------------------------------
direct_modules <- c(
    'Module_1',
    'Module_2'
)

## ----example_vector_access----------------------------------------------------
print(direct_modules[1])
direct_modules[1] <- 'Module_3'
print(direct_modules)

## ----example_module_list------------------------------------------------------
differential_modules <- list(
   'partitioning_growth',
   thermal_time_module = 'thermal_time_linear'
)

## ----example_module_swap------------------------------------------------------
differential_modules$thermal_time_module <- 'thermal_time_trilinear'

## ----viewing_soybean_modules--------------------------------------------------
str(soybean_differential_modules)

## ----example_parameter_list---------------------------------------------------
parameters <- list(
    parameter_1 = 2.3,
    parameter_2 = 8.9
)

## ----example_drivers----------------------------------------------------------
hour <- seq(0, 23, 3)
temp <- 20 + 8 * sin((hour / 24) * pi)^2 # we use "vector arithmetic" to form `temp`
drivers <- data.frame(
    hour = hour,
    temp = temp
)

## ----example_view_drivers-----------------------------------------------------
print(drivers)

## ----view_ode_solver----------------------------------------------------------
str(soybean_ode_solver)

## ----run_biocro_error_quantity------------------------------------------------
soybean_result = run_biocro(
  within(soybean_initial_values, rm(Leaf)),         # remove the initial `Leaf` value
  within(soybean_parameters, rm(leaf_reflectance)), # remove `leaf_reflectance`
  soybean_weather2002,
  soybean_direct_modules,
  soybean_differential_modules,
  soybean_ode_solver
)

## ----run_biocro_error_module--------------------------------------------------
soybean_result = run_biocro(
  soybean_initial_values,
  soybean_parameters,
  soybean_weather2002,
  append(soybean_direct_modules, 'nonexistent_module_name'), # add a nonexistent module
  soybean_differential_modules,
  soybean_ode_solver
)

## ----validate_inputs,eval=FALSE-----------------------------------------------
#  # This code is not evaluated here since it produces a large amount of text
#  valid <- validate_dynamical_system_inputs(
#    soybean_initial_values,
#    soybean_parameters,
#    soybean_weather2002,
#    rev(soybean_direct_modules), # Reverse the order of the direct modules
#    soybean_differential_modules
#  )

## ----view_data_frame,eval=FALSE-----------------------------------------------
#  View(soybean_result)

## ----print_column_names-------------------------------------------------------
soybean_model_outputs <- colnames(soybean_result)

## ----print_one_column---------------------------------------------------------
str(soybean_result$doy)

## ----print_subset-------------------------------------------------------------
str(soybean_result[c('doy', 'hour', 'Leaf')])

## ----print_subset_narrow------------------------------------------------------
str(soybean_result[round(soybean_result$doy) == 250, c('doy', 'hour', 'Leaf')])

## ----soybean_plot_1-----------------------------------------------------------
soybean_plot_v1 <- xyplot(
  soybean_result$Leaf ~ soybean_result$time
)
print(soybean_plot_v1)

## ----soybean_plot_v2----------------------------------------------------------
soybean_plot_v2 <- xyplot(
  Leaf ~ time,
  data = soybean_result
)
print(soybean_plot_v2)

## ----soybean_plot_v3----------------------------------------------------------
soybean_plot_v3 = xyplot(
  Stem + Leaf + Root ~ time,                   # Specify multiple data series using `+`
  data = soybean_result,                       # Plot data from `soybean_result`
  type = 'b',                                  # Plot using both points and a line (use
                                               # 'l' for just a line or 'p' for points)
  pch = 20,                                    # Use a small solid circle for the points
  ylab = 'Biomass (Mg / ha)',                  # Y label
  xlab = 'Day of year',                        # X label
  auto.key = list(space = 'right'),            # Add a legend on the right side
  grid = TRUE,                                 # Add horizontal and vertical lines
  main = 'Soybean biomass calculated in 2002', # Add a main title
  xlim = c(204, 206),                          # Specify the X axis limits
  ylim = c(0, 3)                               # Specify the Y axis limits
)
print(soybean_plot_v3)

## ----c3_module_info-----------------------------------------------------------
module_info('c3_assimilation')

## ----c3_assimilation_v1-------------------------------------------------------
outputs <- evaluate_module('c3_assimilation', soybean_parameters)

## ----c3_assimilation_v2-------------------------------------------------------
outputs <- evaluate_module(
  'c3_assimilation',
  within(soybean_parameters, {
    rh = 0.7      # dimensionless
    Qp = 1800     # micromol / m^2 / s
    Tleaf = 27    # degrees C
    StomataWS = 1 # dimensionless; 1 indicates no water stress
  })
)

## ----c3_light_response_curve--------------------------------------------------
rc <- module_response_curve(
  'c3_assimilation',
  within(soybean_parameters, {
    rh = 0.7
    Tleaf = 27
    StomataWS = 1
  }),
  data.frame(Qp = seq(from = 0, to = 2000, length.out = 501))
)

caption <- paste0(
  'Soybean response curve calculated with\nTleaf = ', unique(rc$Tleaf),
  ' degrees C and RH = ', unique(rc$rh), '\nusing the `',
  unique(rc$module_name), '` module'
)

xyplot(
  Assim ~ Qp,
  data = rc,
  type = 'l',
  xlab = 'Incident PPFD (micromol / m^2 / s)',
  ylab = 'Net CO2 assimilation rate\n(micromol / m^2 / s)',
  main = caption,
  grid = TRUE
)

## ----leaf_information---------------------------------------------------------
all_quantities <- get_all_quantities()
leaf_quantity_subset <- all_quantities[all_quantities$quantity_name == 'Leaf', ]
leaf_modules <- unique(leaf_quantity_subset$module_name)
print(leaf_modules)

## ----total_biomass_info-------------------------------------------------------
info <- module_info('total_biomass', verbose = FALSE)
str(info)

