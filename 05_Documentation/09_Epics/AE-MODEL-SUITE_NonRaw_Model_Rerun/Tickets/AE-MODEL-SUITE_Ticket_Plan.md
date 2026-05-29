# AE-MODEL-SUITE Ticket Plan

## AE-MODEL-SUITE-001: Readiness Gate

Open the epic, create the planning documentation, inspect local feature readiness, confirm code support, and run an SSH smoke test only. No training or data generation.

Status: `BLOCKED` pending VAE feature regeneration/freshness validation.

## AE-MODEL-SUITE-002: Minimal Data Manifest and Upload

After the readiness blocker is resolved, define and upload only the minimum data/code required for non-raw reruns under the isolated AE-MODEL-SUITE validation root.

## AE-MODEL-SUITE-003: Output Isolation and Evaluation Compatibility

Verify that `fund`, `latent_raw`, and `raw_plus_latent` training/evaluation paths all route through `MT_OUTPUT_DIR`, and add narrowly scoped compatibility support if required.

## AE-MODEL-SUITE-004: Run Fundamental Models

Run `MODEL=fund` for `dynamic_csi` and `permanent_csi`, retain compact evidence, and prune heavy model artifacts.

## AE-MODEL-SUITE-005: Run Latent-Raw Models

Run `MODEL=latent_raw` for both response tracks after VAE-derived feature freshness is proven.

## AE-MODEL-SUITE-006: Run Raw-Plus-Latent Models

Run `MODEL=raw_plus_latent` for both response tracks after evaluator compatibility is confirmed.

## AE-MODEL-SUITE-007: Compare Against AE-VALIDATE Raw

Compare non-raw rerun metrics against the AE-VALIDATE raw comparator, including AP, AUC, recall-at-FPR, Brier, and headline model conclusions.

## AE-MODEL-SUITE-008: Final Model-Training Solution Report

Close the epic with final model-suite status, best model conclusions, known caveats, and branch/output hygiene evidence.
