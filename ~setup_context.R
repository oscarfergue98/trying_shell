# Set up the context

args <- commandArgs(trailingOnly = TRUE)

TAG <- args[1]

if (length(args) == 0) {
  print("No args given, assuming we are testing")
  TAG <- "test"
  print(paste0("Using TAG: ", TAG))
} else {
  print(paste0("Using TAG: ", TAG))
}

MAIN_PATH <- "C:/Users/cjgue/Documents/trying_shell_files"

RAW_DATA_PATH <- file.path(MAIN_PATH, 
                           "/raw_data")

MODEL_RUN_PATH <- file.path(
  MAIN_PATH,
  "model_runs", 
  TAG
)


INTERMEDIARY_DATA_PATH <- 
  file.path(
    MAIN_PATH,
    "model_runs",
    TAG,
    "intermediary_data"
  )


OUTPUT_DATA_PATH <- 
  file.path(
    MAIN_PATH,
    "model_runs", 
    TAG, 
    "output_data"
  )


FINAL_PLOTS_PATH <- 
  file.path(
    "model_runs", 
    TAG,
    "plots"
  )

fredr::fredr_set_key("f3a6e1148d769b8343f5c85eb05a5cfa")
