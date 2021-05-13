## ----preliminaries,echo=FALSE-------------------------------------------------
knitr::opts_chunk$set(error=TRUE) # don't stop on errors; display them
                                  # in results; this is the default

## ----error_setting_in_effect--------------------------------------------------
library(BioCro, quietly=TRUE)

## ----list_function------------------------------------------------------------
# The list() function takes any number of key=value pairs, separated
# by commas.
example_initial_values = list(Stem = 3, Leaf = 5)

# The str() function prints useful information about any object.
str(example_initial_values)

# You can get a value using the key and the '$' operator ...
example_initial_values$Leaf

# ... or with the double-bracket operator '[[' operator and the
# string value of the key.
example_initial_values[["Leaf"]]

key_variable <- "Leaf"
example_initial_values[[key_variable]]

## ----willow_initial_state-----------------------------------------------------
str(head(willow_initial_state)) # head truncates the list to six items

## ----varying_parameters_example-----------------------------------------------
example_varying_parameters = data.frame(
            year = c(2005, 2005),
            doy = c(1, 1),
            hour = c(0, 1),
            solar = c(0, 0),
            temp = c(4.04, 3.03))
print(example_varying_parameters)

## ----weather05----------------------------------------------------------------
head(get_growing_season_climate(weather05))

## ----Gro_example, fig.show='hide'---------------------------------------------
library(BioCro)
library(lattice)  # This is a package that creates figures.

result = Gro(sorghum_initial_state, sorghum_parameters,
             get_growing_season_climate(weather05), sorghum_modules)
xyplot(Stem + Leaf + Root ~ TTc, data=result)  # The output is not shown here.

