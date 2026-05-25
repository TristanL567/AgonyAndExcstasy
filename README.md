# AgonyAndExcstasy

Cleaned working repository for the master thesis project originally developed in
`C:\Users\Tristan Leiter\Documents\MT`.

## Folder Layout

```text
01_Code/             Source code only.
02_Data_Input/       Raw and derived input data. Ignored by Git.
03_Data_Output/      Generated analysis outputs. Ignored by Git.
04_Research/         External papers, source methodology, and background material. Ignored by Git.
05_Documentation/    Project methodology, result notes, planning, and admin docs. Ignored by Git.
06_Presentations/    Proposal and final presentation material. Ignored by Git.
```

The repository is intended to track code and lightweight project metadata only.
Data, outputs, research PDFs, documentation, and presentations are intentionally
ignored because many files exceed practical Git hosting limits.

## Main Code Areas

```text
01_Code/pipeline/                  Main R/Python thesis pipeline.
01_Code/index_construction_crsp/   CRSP-like index replication scripts.
01_Code/functions/                 General R helpers.
01_Code/subfunctions/              Legacy/helper code used by selected scripts.
01_Code/shell/                     Local and VastAI run wrappers.
```

## Path Conventions

The pipeline uses the cleaned folder layout:

```text
02_Data_Input/05_PipelineResults/Necessary/{temporary_csi,permanent_csi}/
03_Data_Output/{1_Descriptive_Statistics,2_Robustness_Checks,3_Modelling_Results,4_IndexConstruction_Results}/
05_Documentation/
```

Set these environment variables when needed:

```text
MT_ROOT=C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy
RESPONSE_TRACK=dynamic_csi
```

`RESPONSE_TRACK=dynamic_csi` maps to the on-disk folder `temporary_csi`.
`RESPONSE_TRACK=permanent_csi` maps to `permanent_csi`.

## Known Regeneration Requirement

The migrated data contains dynamic CSI features and model outputs, but the
following generated dynamic-track inputs are not present in the source MT folder
and must be regenerated before rerunning all dynamic downstream steps:

```text
02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_dynamic_csi.rds
02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds
02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds
```

`01_Code/pipeline/06_Merge.R` writes these files for the active
`RESPONSE_TRACK=dynamic_csi` when the required upstream label, price,
fundamental, macro, and universe inputs are available.

