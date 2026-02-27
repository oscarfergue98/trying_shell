# Set up the context

args <- commandArgs(trailingOnly = TRUE)

TAG <- args[1]

if (length(args) == 0) {
  print("No args given, assuming we are testing")
  TAG <- "test"
  print(paste0("Using TAG: ", TAG))
}

RAW_DATA_PATH <- "C:/Users/cjgue/Documents/trying_shell_files/raw_data"

MODEL_RUN_PATH <- file.path(
  "C:/Users/cjgue/Documents/trying_shell_files/model_runs", 
  TAG
)


INTERMEDIARY_DATA_PATH <- 
  file.path(
    "C:/Users/cjgue/Documents/trying_shell_files/model_runs",
    TAG,
    "intermediary_data"
  )


OUTPUT_DATA_PATH <- 
  file.path(
    "C:/Users/cjgue/Documents/trying_shell_files/model_runs", 
    TAG, 
    "output_data"
  )


FINAL_PLOTS_PATH <- 
  file.path(
    "C:/Users/cjgue/Documents/trying_shell_files/model_runs", 
    TAG,
    "plots"
  )