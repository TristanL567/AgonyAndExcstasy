# AE-VALIDATE-002 Output Isolation Report

## Status

- Worker status: completed with one remote-readiness blocker.
- Local branch: `validation`.
- Local HEAD: `54078be AE-VALIDATE-001: add base state report`.
- No commit was made.
- No files were staged.

## Scope And Safety

- Prohibited scripts were not run:
  - `09C_AutoGluon.py` training was not run.
  - `10_Evaluation.R` was not run.
  - `11C_IndexConstruction_Revised.R` was not run.
  - No model training, evaluation, index construction, sensitivity analysis, pipeline regeneration, upload, or download command was run.
- No local files under `03_Data_Output/**` were written.
- No canonical output files were modified.
- No remote writes were performed.

## Files Changed

- `01_Code/pipeline/config.R`

No changes were made to `01_Code/pipeline/09C_AutoGluon.py`.

## Python MT_OUTPUT_DIR Support

Python support already existed before this ticket.

`01_Code/pipeline/09C_AutoGluon.py` defines `resolve_output_dir()`, reads `MT_OUTPUT_DIR`, and uses the override only when it is an absolute path. Downstream AutoGluon output constants are then built under `DIR_OUTPUT`, including:

- `DIR_MODELLING_TRACK`
- `DIR_MODELS`
- `DIR_TABLES`

No Python path-handling defect was found, so the Python file was left unchanged.

## R MT_OUTPUT_DIR Support

R support did not exist before this ticket. Before the change, `config.R` always set:

```r
DIR_DATA_OUTPUT <- file.path(DIR_ROOT, "03_Data_Output")
```

The ticket added minimal absolute-override handling:

- `MT_OUTPUT_DIR` unset or relative: keep canonical `file.path(DIR_ROOT, "03_Data_Output")`.
- `MT_OUTPUT_DIR` absolute: use `MT_OUTPUT_DIR` as `DIR_DATA_OUTPUT`.

Because existing track-aware constants are built from `DIR_DATA_OUTPUT`, the change routes downstream output constants under the isolated validation root while preserving track folders.

## Path-Resolution Checks

Checks evaluated only the non-writing config definitions before Section 5, where `config.R` creates directories. No `source()` of the full config was used for these checks.

With `MT_OUTPUT_DIR` unset and `MT_ROOT` set to the local repository:

```text
DIR_DATA_OUTPUT=C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output
DIR_OUTPUT=C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output
DIR_TABLES_EVAL_TRACK=C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation
DIR_TABLES_INDEX_TRACK=C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11_index
```

With absolute `MT_OUTPUT_DIR=C:/tmp/ae_validate/raw_rerun_test`:

```text
DIR_DATA_OUTPUT=C:/tmp/ae_validate/raw_rerun_test
DIR_OUTPUT=C:/tmp/ae_validate/raw_rerun_test
DIR_TABLES_EVAL_TRACK=C:/tmp/ae_validate/raw_rerun_test/3_Modelling_Results/Necessary/temporary_csi/evaluation
DIR_TABLES_INDEX_TRACK=C:/tmp/ae_validate/raw_rerun_test/4_IndexConstruction_Results/Necessary/temporary_csi/11_index
```

Expected remote validation command environment:

```sh
MT_ROOT=/root/AgonyAndExcstasy
MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_<timestamp>
```

The remote `MT_OUTPUT_DIR` convention is absolute and will therefore route R outputs under the validation root.

## Parse And Syntax Validation

- `config.R`: parse passed.
- `09C_AutoGluon.py`: AST parse passed.
- `git diff --check -- 01_Code/pipeline/config.R`: passed.

## Remote Package Readiness

Required packages:

```text
here, data.table, arrow, jsonlite, ggplot2, lubridate, scales, pROC, PRROC, dplyr, tidyr, viridis
```

Result: blocked. The locally discoverable SSH endpoints tested with `C:\Windows\System32\OpenSSH\ssh.exe` were unreachable from this worker session; connections either timed out or were refused. Endpoint details are intentionally omitted from this report.

The package check that should be run once a live endpoint is available is:

```sh
MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_<timestamp> Rscript -e 'pkgs <- c("here","data.table","arrow","jsonlite","ggplot2","lubridate","scales","pROC","PRROC","dplyr","tidyr","viridis"); missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly=TRUE)]; if (length(missing)) stop(paste("Missing:", paste(missing, collapse=", "))); cat("All required R packages available\n")'
```

## Commands Run

Local read-only/status:

```powershell
git status --short --branch
git rev-parse --short HEAD
git log -1 --pretty=format:"%h %s"
rg -n "MT_OUTPUT_DIR|OUTPUT|output|03_Data_Output|TRACK|track|here\(" 01_Code/pipeline/config.R 01_Code/pipeline/09C_AutoGluon.py
```

Local inspection and validation:

```powershell
Get-Content -Path '01_Code/pipeline/config.R' | Select-Object -Skip 170 -First 140
Get-Content -Path '01_Code/pipeline/config.R' | Select-Object -Skip 360 -First 50
Get-Content -Path '01_Code/pipeline/09C_AutoGluon.py' | Select-Object -Skip 112 -First 70
py -3.10 -c "import ast, pathlib; ast.parse(pathlib.Path('01_Code/pipeline/09C_AutoGluon.py').read_text(encoding='utf-8')); print('09C_AutoGluon.py AST parse OK')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "invisible(parse('01_Code/pipeline/config.R')); cat('config.R parse OK\n')"
git diff --check -- 01_Code/pipeline/config.R
git diff --stat
```

Local non-writing R path-resolution probes:

```powershell
$env:MT_ROOT=(Get-Location).Path
Remove-Item Env:MT_OUTPUT_DIR -ErrorAction SilentlyContinue
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "<evaluate config definitions before Section 5 and print DIR_* paths>"

$env:MT_ROOT=(Get-Location).Path
$env:MT_OUTPUT_DIR='C:/tmp/ae_validate/raw_rerun_test'
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "<evaluate config definitions before Section 5 and print DIR_* paths>"
```

Remote read-only connection attempts:

```powershell
& 'C:\Windows\System32\OpenSSH\ssh.exe' <endpoint omitted> "MT_ROOT=/root/AgonyAndExcstasy; cd $MT_ROOT && pwd"
```

## Blockers

- Remote R package readiness could not be verified because no live SSH endpoint was reachable from this worker session.

## Readiness For AE-VALIDATE-003

- Local Python and R output-root handling is ready for isolated validation reruns.
- Canonical output paths remain unchanged when `MT_OUTPUT_DIR` is unset.
- Absolute `MT_OUTPUT_DIR` routes track-aware output constants under the validation root.
- AE-VALIDATE-003 should not proceed to remote reruns until the remote endpoint is reachable and the required R package check passes.
