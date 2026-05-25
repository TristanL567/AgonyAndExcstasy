$ErrorActionPreference = "Stop"

$env:MT_ROOT = if ($env:MT_ROOT) { $env:MT_ROOT } else { "C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy" }
$env:RESPONSE_TRACK = if ($env:RESPONSE_TRACK) { $env:RESPONSE_TRACK } else { "dynamic_csi" }
$env:CSI_USE_TERMINAL_FAILURE_INDICATORS = if ($env:CSI_USE_TERMINAL_FAILURE_INDICATORS) { $env:CSI_USE_TERMINAL_FAILURE_INDICATORS } else { "1" }
$env:CSI_GRID_WORKERS = if ($env:CSI_GRID_WORKERS) { $env:CSI_GRID_WORKERS } else { "1" }
# MT_OUTPUT_DIR is obsolete (single output tree); honoured only if absolute path is provided.

$env:OMP_NUM_THREADS = if ($env:OMP_NUM_THREADS) { $env:OMP_NUM_THREADS } else { "1" }
$env:OPENBLAS_NUM_THREADS = if ($env:OPENBLAS_NUM_THREADS) { $env:OPENBLAS_NUM_THREADS } else { "1" }
$env:MKL_NUM_THREADS = if ($env:MKL_NUM_THREADS) { $env:MKL_NUM_THREADS } else { "1" }
$env:BLIS_NUM_THREADS = if ($env:BLIS_NUM_THREADS) { $env:BLIS_NUM_THREADS } else { "1" }
$env:VECLIB_MAXIMUM_THREADS = if ($env:VECLIB_MAXIMUM_THREADS) { $env:VECLIB_MAXIMUM_THREADS } else { "1" }

$root = $env:MT_ROOT
$codeDir = Join-Path $root "01_Code\pipeline"
if ($env:MT_OUTPUT_DIR -and [System.IO.Path]::IsPathRooted($env:MT_OUTPUT_DIR)) {
  $outputRoot = $env:MT_OUTPUT_DIR
} else {
  $outputRoot = Join-Path $root "03_Data_Output"
}
$logDir = Join-Path $outputRoot "3_Modelling_Results\Additional\run_logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = Join-Path $logDir "dynamic_csi_03b_to_autoencoder_$stamp.log"

$rscript = "C:\Program Files\R\R-4.5.2\bin\Rscript.exe"
if (-not (Test-Path $rscript)) {
  $rscript = "Rscript"
}

Set-Location $codeDir

function Run-Step {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][scriptblock]$Command
  )
  "[$Name] START $(Get-Date -Format o)" | Tee-Object -FilePath $logPath -Append
  & $Command 2>&1 | Tee-Object -FilePath $logPath -Append
  if ($LASTEXITCODE -ne 0) {
    throw "Step failed: $Name (exit $LASTEXITCODE)"
  }
  "[$Name] DONE $(Get-Date -Format o)" | Tee-Object -FilePath $logPath -Append
}

"[run_dynamic_csi_03b_to_autoencoder_local] START $(Get-Date -Format o)" | Tee-Object -FilePath $logPath
"MT_ROOT=$env:MT_ROOT" | Tee-Object -FilePath $logPath -Append
"RESPONSE_TRACK=$env:RESPONSE_TRACK" | Tee-Object -FilePath $logPath -Append
"CSI_USE_TERMINAL_FAILURE_INDICATORS=$env:CSI_USE_TERMINAL_FAILURE_INDICATORS" | Tee-Object -FilePath $logPath -Append
"CSI_GRID_WORKERS=$env:CSI_GRID_WORKERS" | Tee-Object -FilePath $logPath -Append
"MT_OUTPUT_DIR=$env:MT_OUTPUT_DIR" | Tee-Object -FilePath $logPath -Append
"OUTPUT_ROOT=$outputRoot" | Tee-Object -FilePath $logPath -Append

Run-Step "05A_Dynamic_CSI_Label.R" { & $rscript "05A_Dynamic_CSI_Label.R" }
Run-Step "06_Merge.R" { & $rscript "06_Merge.R" }
Run-Step "06B_FeatureEngineering.R" { & $rscript "06B_FeatureEngineering.R" }
Run-Step "08_Split.R" { & $rscript "08_Split.R" }
Run-Step "08B_Autoencoder.py fund" { $env:VAE_INPUT = "fund"; py -3.10 "08B_Autoencoder.py" }
Run-Step "08B_Autoencoder.py raw" { $env:VAE_INPUT = "raw"; py -3.10 "08B_Autoencoder.py" }

Run-Step "validation" {
  & $rscript -e "source('config.R'); library(data.table); events <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE)); labels <- as.data.table(readRDS(PATH_LABELS_DYNAMIC)); features <- as.data.table(readRDS(PATH_FEATURES_RAW)); print(events[, .N, by = event_status][order(event_status)]); cat('positive_event_rows', nrow(events[event_status %in% CSI_POSITIVE_EVENT_STATUSES]), '\n'); cat('dynamic_label_positives', sum(labels[['y_dynamic_csi']] == 1L, na.rm = TRUE), '\n'); cat('feature_rows', nrow(features), '\n'); cat('output_dir', DIR_OUTPUT, '\n')"
}

"[run_dynamic_csi_03b_to_autoencoder_local] DONE $(Get-Date -Format o)" | Tee-Object -FilePath $logPath -Append
"LOG_PATH=$logPath" | Tee-Object -FilePath $logPath -Append
