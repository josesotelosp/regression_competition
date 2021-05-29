

# Set Up ------------------------------------------------------------------

# Libraries
library(tidyverse)
library(tidymodels)
library(skimr)
library(GGally)
library(reshape2)
library(patchwork)


# loading data
load("model_info/train_folds.rda")
load("model_info/train_spli.rda")
load("model_info/train_recipe.rda")
load("model_info/train_train.rda")
load("model_info/train_test.rda")




# Define model ----
rf_model <- rand_forest(
  mtry = tune(),
  min_n = tune()
) %>%
  set_mode("regression") %>%
  set_engine("ranger")


# set-up tuning grid ----

# update parameters
rf_params <- parameters(rf_model)  %>%
  update(mtry = mtry(range = c(2, 23)))

# define tuning grid
rf_grid <- grid_regular(rf_params, levels = 5)

# workflow ----
rf_workflow <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(train_recipe)

# Tuning/fitting ----
rf_tune1 <- rf_workflow %>%
  tune_grid(
    resample = train_folds,
    grid = rf_grid
  )

# Write out results & workflow
save(rf_tune1, rf_workflow, file = "model_info/rf_tune1.rda")
