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

## ----loading_libraries,echo=FALSE,error=FALSE---------------------------------
library(BioCro, quietly=TRUE)
library(lattice, quietly=TRUE)

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

## ----plotting_tools,echo=FALSE------------------------------------------------
time_range <- c(142, 298)
ppfd_range <- c(-100, 1100)
assim_range <- c(-2, 40)
biomass_columns <- c('time', 'Grain', 'Leaf', 'Root', 'Stem')

## ----helping_functions,echo=FALSE---------------------------------------------
# Define a list of atmospheric CO2 values for each year
catm <- catm_data$Catm
names(catm) <- catm_data$year

# Define a function that runs the clock modules to determine the photoperiod
# length during a year's worth of weather data, adding it to the data so it can
# be used as a driver in future simulations
add_photoperiod_length <- function(weather_data) {
    clock_output <- run_biocro(
        soybean_clock_initial_values,
        soybean_clock_parameters,
        weather_data,
        soybean_clock_direct_modules,
        soybean_clock_differential_modules,
        soybean_ode_solver
    )
    weather_data[['day_length']] <- clock_output[['day_length']]
    return(weather_data)
}

# Define a helping function that runs the circadian clock model for the entire
# year and then truncates the data to the appropriate time range
process_weather <- function(weather_data) {
    weather_data <- add_photoperiod_length(weather_data)
    weather_data <-
        weather_data[weather_data[['doy']] >= 152 &
          weather_data[['doy']] <= 288,]
}

# Define a list of processed weather data
weather <- list(
    '1995' = process_weather(weather1995),
    '1996' = process_weather(weather1996),
    '1997' = process_weather(weather1997),
    '1998' = process_weather(weather1998),
    '1999' = process_weather(weather1999),
    '2000' = process_weather(weather2000),
    '2001' = process_weather(weather2001),
    '2002' = process_weather(weather2002),
    '2003' = process_weather(weather2003),
    '2004' = process_weather(weather2004),
    '2005' = process_weather(weather2005),
    '2006' = process_weather(weather2006),
    '2007' = process_weather(weather2007),
    '2008' = process_weather(weather2008),
    '2009' = process_weather(weather2009),
    '2010' = process_weather(weather2010),
    '2011' = process_weather(weather2011),
    '2012' = process_weather(weather2012),
    '2013' = process_weather(weather2013),
    '2014' = process_weather(weather2014),
    '2015' = process_weather(weather2015),
    '2016' = process_weather(weather2016),
    '2017' = process_weather(weather2017),
    '2018' = process_weather(weather2018),
    '2019' = process_weather(weather2019),
    '2020' = process_weather(weather2020)
)

# Define a function to help save PDFs of the figures. Here the important part
# is setting `useDingbats` to FALSE, since dingbats causes problems when opening
# PDFs in editing software such as Adobe Illustrator.
pdf_print <- function(
    plot_object,
    file_name_string,
    width = 6,
    height = 6
)
{
   pdf(
       file = file_name_string,
       width = width,
       height = height,
       useDingbats = FALSE
   )
   print(plot_object)
   dev.off()
}

## ----fvcb_result_2002---------------------------------------------------------
fvcb_result_2002 <- run_biocro(
    soybean_initial_values,
    soybean_parameters,
    weather[['2002']],
    append(soybean_direct_modules, 'total_biomass'),
    soybean_differential_modules,
    soybean_ode_solver
)

final_biomass <- function(df) {
    df[nrow(df), 'total_biomass']
}

final_biomass_fvcb_2002 <- final_biomass(fvcb_result_2002)

## ----rue_2002-----------------------------------------------------------------
# The first six arguments are the same as for `run_biocro`
rue_2002 <- partial_run_biocro(
    soybean_initial_values,
    within(soybean_parameters, {alpha_rue = NA}),
    weather[['2002']],
    append(within(soybean_direct_modules,
        {canopy_photosynthesis = 'ten_layer_rue_canopy'}), 'total_biomass'),
    soybean_differential_modules,
    soybean_ode_solver,
    'alpha_rue'  # here we specify the names of any quantities whose values
)                # should not be fixed

## ----rue_fvcb_square_difference-----------------------------------------------
rue_fvcb_square_difference = function(alpha_rue) {
    (final_biomass(rue_2002(alpha_rue)) - final_biomass_fvcb_2002)^2
}

## ----alpha_rue_optimization---------------------------------------------------
opt_par = optim(
    0.035,
    rue_fvcb_square_difference,
    method='Brent',
    lower=0.03,
    upper=0.04
)

best_alpha_rue = opt_par$par

## ----figure_s1,echo=FALSE,results=FALSE---------------------------------------
alpha_rue_sequence = seq(0.03, 0.04, length=31)
differences = sapply(alpha_rue_sequence, rue_fvcb_square_difference)

alpha_rue_optimization_plot <- xyplot(
    differences ~ alpha_rue_sequence,
    type = 'l',
    grid = TRUE,
    auto = TRUE,
    xlab = 'alpha_rue (C per photon)',
    ylab = '(RUE biomass - FvCB biomass)^2 at end of season',
    main = paste0('Year 2002: best_alpha_rue = ', best_alpha_rue),
    panel = function(...) {
        panel.xyplot(...)
        panel.points(
            rue_fvcb_square_difference(best_alpha_rue) ~ best_alpha_rue,
            type = 'p',
            col = 'red',
            pch = 16
        )
    }
)

pdf_print(alpha_rue_optimization_plot, 'alpha_rue_optimization_plot.pdf')

## ----optimal_rue_result_2002--------------------------------------------------
optimal_rue_result_2002 <- run_biocro(
    soybean_initial_values,
    within(soybean_parameters, {alpha_rue = best_alpha_rue}),
    weather[['2002']],
    append(within(soybean_direct_modules,
        {canopy_photosynthesis = 'ten_layer_rue_canopy'}), 'total_biomass'),
    soybean_differential_modules,
    soybean_ode_solver
)

## ----figure_4a,echo=FALSE,results=FALSE---------------------------------------
biomass_comparison_2002 <- rbind(
    within(fvcb_result_2002[biomass_columns], {model = 'FvCB'}),
    within(optimal_rue_result_2002[biomass_columns], {model = 'RUE'})
)

biomass_comparison_2002_plot <- xyplot(
    Leaf + Stem + Root + Grain ~ time,
    group = model,
    data = biomass_comparison_2002,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    xlim = time_range,
    ylim = c(-0.7, 8.7),
    xlab = 'Day of year (2002)',
    ylab = 'Biomass (Mg / ha)',
)

pdf_print(biomass_comparison_2002_plot, 'biomass_comparison_2002_plot.pdf')

## ----extract_aq_scatter-------------------------------------------------------
extract_aq_scatter <- function(biocro_output) {
    light_column_names <- grep(
        '(sunlit|shaded)_incident_ppfd_layer_[0-9]',
        names(biocro_output),
        value = TRUE
    )

    assim_column_names <- grep(
        '(sunlit|shaded)_GrossAssim_layer_[0-9]',
        names(biocro_output),
        value=TRUE
    )

    aq_scatter <- data.frame(
        incident_ppfd = unlist(biocro_output[light_column_names]),
        gross_assimilation = unlist(biocro_output[assim_column_names]),
        row.names = NULL
    )

    return(aq_scatter)
}

## ----figure_4b,echo=FALSE,results=FALSE---------------------------------------
fvcb_aq_scatter_2002 <- extract_aq_scatter(fvcb_result_2002)
rue_aq_scatter_2002 <- extract_aq_scatter(optimal_rue_result_2002)

fvcb_aq_scatter_plot <- xyplot(
    gross_assimilation ~ incident_ppfd,
    data = fvcb_aq_scatter_2002,
    type = 'p',
    pch = 16,
    xlim = ppfd_range,
    ylim = assim_range,
    xlab = 'Incident PPFD (micromol / m^2 / s)',
    ylab = 'Gross CO2 assimilation rate (micromol / m^2 / s)',
    grid = TRUE,
    main = '(Ag, Q) scatter plot from the FvCB model in 2002'
)

pdf_print(fvcb_aq_scatter_plot, 'fvcb_aq_scatter_plot.pdf')

rue_aq_scatter_plot <- xyplot(
    gross_assimilation ~ incident_ppfd,
    data = rue_aq_scatter_2002,
    type = 'p',
    pch = 16,
    xlim = ppfd_range,
    ylim = assim_range,
    xlab = 'Incident PPFD (micromol / m^2 / s)',
    ylab = 'Gross CO2 assimilation rate (micromol / m^2 / s)',
    grid = TRUE,
    main = '(Ag, Q) scatter plot from the RUE model in 2002'
)

pdf_print(rue_aq_scatter_plot, 'rue_aq_scatter_plot.pdf')

## ----fvcb_light_curve_inputs--------------------------------------------------
# Choose a set of incident PPFD values to use (micromol / m^2 / s)
incident_ppfd <- seq(0, 1000, length.out = 501)

# Determine corresponding incident PAR values (J / m^2 / s) using the average
# energy per micromole of photosynthetically active photons in sunlight
incident_par <- incident_ppfd * soybean_parameters[['par_energy_content']]

# Determine the corresponding incident shorwave values using the fraction of
# solar energy that lies in the PAR band (J / m^2 / s)
incident_shortwave <- incident_par / soybean_parameters[['par_energy_fraction']]

# Determine the corresponding absorbed shortwave energy values using the
# shortwave reflectance and transmittance of the leaf (J / m^2 / s)
average_absorbed_shortwave <-
    incident_shortwave *
    (1 - soybean_parameters[['leaf_reflectance']] -
        soybean_parameters[['leaf_transmittance']]) /
    (1 - soybean_parameters[['leaf_transmittance']])

# Make a data frame with the incident PPFD and absorbed shortwave values, where
# we also include values of a few other required parameters
light_curve_inputs <- data.frame(
    incident_ppfd = incident_ppfd,
    average_absorbed_shortwave = average_absorbed_shortwave,
    rh = 0.75,
    temp = 25,
    windspeed = 3.28,
    Catm = catm[['2002']],
    StomataWS = 0.99,
    height = 0.75
)

## ----assim_sensitivity--------------------------------------------------------
assim_sensitivity <- function(
    varname,
    base_module_inputs,
    relative_perturbation_size = 1e-6
)
{
    var_center <- base_module_inputs[[varname]]
    gross_assim_center <-
        evaluate_module('c3_leaf_photosynthesis', base_module_inputs)[['GrossAssim']]

    neg_module_inputs <- base_module_inputs
    neg_var <- base_module_inputs[[varname]] * (1 - relative_perturbation_size)
    neg_module_inputs[[varname]] <- neg_var
    gross_assim_neg <-
        evaluate_module('c3_leaf_photosynthesis', neg_module_inputs)[['GrossAssim']]

    pos_module_inputs <- base_module_inputs
    pos_var <- base_module_inputs[[varname]] * (1 + relative_perturbation_size)
    pos_module_inputs[[varname]] <- pos_var
    gross_assim_pos <-
        evaluate_module('c3_leaf_photosynthesis', pos_module_inputs)[['GrossAssim']]

    dadx = (gross_assim_pos - gross_assim_neg) / (pos_var - neg_var)
    return(dadx / (gross_assim_center / var_center))
}

## ----fvcb_assim_sensitivity---------------------------------------------------
fvcb_light_curve_sensitivity_variables <-
    c('Catm', 'rh', 'temp', 'StomataWS', 'windspeed')

fvcb_sensitivity_light_curve_result <- data.frame(
    incident_ppfd = light_curve_inputs[['incident_ppfd']]
)

# For each variable of interest, calculate sensitivity at each of the light
# intensities in `light_curve_inputs`
for (varname in fvcb_light_curve_sensitivity_variables) {
    fvcb_sensitivity_light_curve_result[[varname]] <-
        apply(light_curve_inputs, 1,
            function(x) assim_sensitivity(varname, c(soybean_parameters, as.list(x))))
}

## ----figure_5a,echo=FALSE,results=FALSE---------------------------------------
# Create Figure 5a
fvcb_light_curve_sensitivity_plot <- xyplot(
    Catm + rh + temp + StomataWS + windspeed ~ incident_ppfd,
    data = fvcb_sensitivity_light_curve_result,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    xlab = 'Incident PPFD (micromol / m^2 / s)',
    ylab = 'Normalized sensitivity coefficient',
    xlim = c(-100, 1100),
    ylim = c(-1, 1)
)

pdf_print(fvcb_light_curve_sensitivity_plot, 'fvcb_light_curve_sensitivity_plot.pdf')

## ----biomass_driver_sensitivity-----------------------------------------------
biomass_driver_sensitivity <- function(
    varname,
    parameters,
    canopy_photosynthesis_module,
    relative_perturbation_size = 1e-5
)
{
    steady_state_modules <- append(
        within(soybean_direct_modules, {
            canopy_photosynthesis = canopy_photosynthesis_module
        }),
        'total_biomass'
    )

    c_to_k <- 273.15

    default_drivers <- within(weather[['2002']], {temp = temp + c_to_k})

    default_result <- run_biocro(
        soybean_initial_values,
        parameters,
        within(default_drivers, {temp = temp - c_to_k}),
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    neg_drivers <- default_drivers
    neg_drivers[[varname]] <- default_drivers[[varname]] * (1 - relative_perturbation_size)
    neg_result <- run_biocro(
        soybean_initial_values,
        parameters,
        within(neg_drivers, {temp = temp - c_to_k}),
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    pos_drivers <- default_drivers
    pos_drivers[[varname]] <- default_drivers[[varname]] * (1 + relative_perturbation_size)
    pos_result <- run_biocro(
        soybean_initial_values,
        parameters,
        within(pos_drivers, {temp = temp - c_to_k}),
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    dMdx <-
        (pos_result[['total_biomass']] - neg_result[['total_biomass']]) /
        (pos_drivers[[varname]] - neg_drivers[[varname]])

    normalized_sensitivity <-
        dMdx / (default_result[['total_biomass']] / default_drivers[[varname]])

    return(
        data.frame(
            normalized_sensitivity = normalized_sensitivity,
            time = default_result[['time']]
        )
    )
}

## ----biomass_temp_sensitivity-------------------------------------------------
biomass_temp_sensitivity_fvcb <- biomass_driver_sensitivity(
    'temp',
    soybean_parameters,
    'ten_layer_c3_canopy'
)

biomass_temp_sensitivity_rue <- biomass_driver_sensitivity(
    'temp',
    within(soybean_parameters, {alpha_rue = best_alpha_rue}),
    'ten_layer_rue_canopy'
)

## ----figure_5b,echo=FALSE,results=FALSE---------------------------------------
# Combine the data frames
biomass_temp_sensitivity <- rbind(
    within(biomass_temp_sensitivity_fvcb, {model = 'FvCB'}),
    within(biomass_temp_sensitivity_rue, {model = 'RUE'})
)

# Create Figure 5b
biomass_temp_sensitivity_plot <- xyplot(
    normalized_sensitivity ~ time,
    group = model,
    data = biomass_temp_sensitivity,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    xlim = time_range,
    ylim = c(-20, 35),
    xlab = 'Day of year (2002)',
    ylab = 'dM / dT / (M / T)'
)

pdf_print(biomass_temp_sensitivity_plot, 'biomass_temp_sensitivity_plot.pdf')

## ----biomass_parameter_sensitivity--------------------------------------------
biomass_parameter_sensitivity <- function(
    varname,
    parameters,
    canopy_photosynthesis_module,
    relative_perturbation_size = 1e-6
)
{
    steady_state_modules <- append(
        within(soybean_direct_modules, {
            canopy_photosynthesis = canopy_photosynthesis_module
        }),
        'total_biomass'
    )

    default_result <- run_biocro(
        soybean_initial_values,
        parameters,
        weather[['2002']],
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    neg_parameters <- parameters
    neg_parameters[[varname]] <- parameters[[varname]] * (1 - relative_perturbation_size)
    neg_result <- run_biocro(
        soybean_initial_values,
        neg_parameters,
        weather[['2002']],
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    pos_parameters <- parameters
    pos_parameters[[varname]] <- parameters[[varname]] * (1 + relative_perturbation_size)
    pos_result <- run_biocro(
        soybean_initial_values,
        pos_parameters,
        weather[['2002']],
        steady_state_modules,
        soybean_differential_modules,
        soybean_ode_solver
    )

    dMdx <-
        (pos_result[['total_biomass']] - neg_result[['total_biomass']]) /
        (pos_parameters[[varname]] - neg_parameters[[varname]])

    normalized_sensitivity <-
        dMdx / (default_result[['total_biomass']] / parameters[[varname]])

    return(
        data.frame(
            normalized_sensitivity = normalized_sensitivity,
            time = default_result[['time']]
        )
    )
}

## ----biomass_catm_sensitivity-------------------------------------------------
biomass_catm_sensitivity_fvcb <- biomass_parameter_sensitivity(
    'Catm',
    soybean_parameters,
    'ten_layer_c3_canopy'
)

biomass_catm_sensitivity_rue <- biomass_parameter_sensitivity(
    'Catm',
    within(soybean_parameters, {alpha_rue = best_alpha_rue}),
    'ten_layer_rue_canopy'
)

## ----figure_5c,echo=FALSE,results=FALSE---------------------------------------
# Combine the data frames
biomass_catm_sensitivity <- rbind(
    within(biomass_catm_sensitivity_fvcb, {model = 'FvCB'}),
    within(biomass_catm_sensitivity_rue, {model = 'RUE'})
)

# Create Figure 5c
biomass_catm_sensitivity_plot <- xyplot(
    normalized_sensitivity ~ time,
    group = model,
    data = biomass_catm_sensitivity,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    xlim = time_range,
    ylim = c(-0.1, 0.9),
    xlab = 'Day of year (2002)',
    ylab = 'dM / dCa / (M / Ca)'
)

pdf_print(biomass_catm_sensitivity_plot, 'biomass_catm_sensitivity_plot.pdf')

## ----biomass_comparison_2006--------------------------------------------------
fvcb_result_2006 <- run_biocro(
    soybean_initial_values,
    within(soybean_parameters, {Catm = catm[['2006']]}),
    weather[['2006']],
    soybean_direct_modules,
    soybean_differential_modules,
    soybean_ode_solver
)

# Run the RUE model with the optimal value for alpha_rue determined for 2002
rue_result_2006 <- run_biocro(
    soybean_initial_values,
    within(soybean_parameters, {alpha_rue = best_alpha_rue; Catm = catm[['2006']]}),
    weather[['2006']],
    within(soybean_direct_modules,
        {canopy_photosynthesis = 'ten_layer_rue_canopy'}),
    soybean_differential_modules,
    soybean_ode_solver
)

## ----figure_6a,echo=FALSE,results=FALSE---------------------------------------
# Combine the RUE and FvCB results into one data frame for plotting
biomass_columns <- c('time', 'Leaf', 'Stem', 'Root', 'Grain')
biomass_comparison_2006 <- rbind(
    within(fvcb_result_2006[biomass_columns], {model = 'FvCB'}),
    within(rue_result_2006[biomass_columns], {model = 'RUE'})
)

# Make Figure 6a
biomass_comparison_2006_plot <- xyplot(
    Leaf + Stem + Root + Grain ~ time,
    group = model,
    data = biomass_comparison_2006,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    xlim = time_range,
    ylim = c(-0.7, 8.7),
    xlab = 'Day of year (2006)',
    ylab = 'Biomass (Mg / ha)',
)

pdf_print(biomass_comparison_2006_plot, 'biomass_comparison_2006_plot.pdf')

## ----multiyear_comparison-----------------------------------------------------
# Decide which years to use
years <- as.character(seq(1995, 2020))

# Initialize vectors to store final biomass and atmospheric CO2 values
final_biomass_seq_rue <- numeric(length(years))
final_biomass_seq_fvcb <- numeric(length(years))
catm_seq <- numeric(length(years))

# Get final biomass values for each year in each model
for (i in seq_along(years)) {
    # Run the RUE soybean model for this year, adding the 'total_biomass' module
    # to the set of default modules and ensuring that we're using the correct
    # value for the atmospheric CO2 concentration
    rue_result <- run_biocro(
        soybean_initial_values,
        within(soybean_parameters,
            {alpha_rue = best_alpha_rue; Catm = catm[[years[i]]]}),
        weather[[years[i]]],
        append(within(soybean_direct_modules,
            {canopy_photosynthesis = 'ten_layer_rue_canopy'}), 'total_biomass'),
        soybean_differential_modules,
        soybean_ode_solver
    )

    # Run the FvCB soybean model for this year, adding the 'total_biomass'
    # module to the set of default modules and ensuring that we're using the
    # correct value for the atmospheric CO2 concentration
    fvcb_result <- run_biocro(
        soybean_initial_values,
        within(soybean_parameters, {Catm = catm[[years[i]]]}),
        weather[[years[i]]],
        append(soybean_direct_modules, 'total_biomass'),
        soybean_differential_modules,
        soybean_ode_solver
    )

    # Store the final biomass and atmospheric CO2 values
    final_biomass_seq_rue[i] <- final_biomass(rue_result)
    final_biomass_seq_fvcb[i] <- final_biomass(fvcb_result)
    catm_seq[i] <- catm[[years[i]]]
}

## ----figure_6bc,echo=FALSE,results=FALSE--------------------------------------
# Form a data frame for plotting and calculate a few new columns
multiyear_comparison <- data.frame(
    catm = catm_seq,
    year = as.numeric(years),
    final_biomass_rue = final_biomass_seq_rue,
    final_biomass_fvcb = final_biomass_seq_fvcb
)

multiyear_comparison <- within(multiyear_comparison, {
    final_mass_difference = final_biomass_rue - final_biomass_fvcb
    final_mass_diff_percent = final_mass_difference / final_biomass_fvcb * 100
})

# Make Figure 6b
multiyear_biomass_plot <- xyplot(
    final_biomass_rue + final_biomass_fvcb ~ year,
    data = multiyear_comparison,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    ylim = c(8, 13),
    xlab = 'Year',
    ylab = 'Final biomass (Mg / ha)'
)

pdf_print(multiyear_biomass_plot, 'multiyear_biomass_plot.pdf')

# Make Figure 6c
multiyear_biomass_difference_plot <- xyplot(
    final_mass_diff_percent ~ catm,
    data = multiyear_comparison,
    type = 'l',
    auto = TRUE,
    grid = TRUE,
    ylim = c(-10, 10),
    xlab = 'Atmospheric CO2 concentration (ppm)',
    ylab = '(M_RUE - M_FvCB) / M_FvCB (%)'
)

pdf_print(multiyear_biomass_difference_plot, 'multiyear_biomass_difference_plot.pdf')

