# AE-CLOUD-005 Live Connection And Environment Report

Date: 2026-05-27

## Scope

Worker ticket AE-CLOUD-005 tested the live Vast.ai SSH connection, documented the remote environment, prepared the remote project root, and installed the Python/R libraries required for the upcoming AE-VALIDATE raw-model/index validation run.

No data was uploaded. No local code, data, or output files were modified. No model, evaluation, index, or sensitivity scripts were run.

## Local Repository State

- Repository: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy`
- Local branch: `Development`
- Local HEAD: `95477a1`
- Local status before report creation: clean (`## Development`)

## SSH Connection Result

- Primary endpoint: succeeded.
- Proxy fallback: not used.
- Connection smoke test result: remote `pwd` returned `/root`.
- Authentication method: local default SSH auth / configured key agent. No key path was provided or recorded.

## Remote Project Root

- Assumed remote project root: `/root/AgonyAndExcstasy`
- Action taken: created/confirmed directory with `mkdir -p`.
- Project root status: exists.
- Git repository status: no git repository exists at `/root/AgonyAndExcstasy`.
- Deferred work: code clone/upload is deferred to the next ticket.

## Remote Machine Summary

- Remote `pwd`: `/root`
- Kernel/OS: `Linux 7a7bc1ba8559 6.8.0-94-generic #96~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 16 13:19:05 UTC 2 x86_64 x86_64 x86_64 GNU/Linux`
- Python: `Python 3.12.3`
- Rscript: `Rscript (R) version 4.3.3 (2024-02-29)`
- Git: `git version 2.43.0`

## Disk And RAM

Final post-install snapshot:

```text
Filesystem      Size  Used Avail Use% Mounted on
overlay         100G  2.8G   98G   3% /
overlay         100G  2.8G   98G   3% /

Mem:           503Gi        52Gi       379Gi       271Mi        75Gi       451Gi
Swap:          8.0Gi          0B       8.0Gi
```

The broader initial `df -h` check also showed a 3.0T `/dev/nvme1n1` mount with about 2.4T available, mounted by the container at `/etc/hosts`.

## GPU Availability

`nvidia-smi` is available.

```text
GPU: NVIDIA GeForce RTX 3060
Memory: 12288 MiB total, 1 MiB used
Utilization: 0%
Driver: 590.48.01
CUDA shown by nvidia-smi: 13.1
```

## Python Package Status

Install command completed successfully:

```text
python -m pip install --upgrade pip numpy pandas pyarrow pyreadr scikit-learn matplotlib autogluon.tabular
```

Import verification completed successfully for all required modules:

| Package/module | Status | Version |
| --- | --- | --- |
| `numpy` | OK | `2.3.5` |
| `pandas` | OK | `2.3.3` |
| `pyarrow` | OK | `20.0.0` |
| `pyreadr` | OK | `0.5.6` |
| `sklearn` / `scikit-learn` | OK | `1.7.2` |
| `matplotlib` | OK | `3.10.9` |
| `autogluon.tabular` | OK | `1.5.0` |

Environment warning: pip reported an already-installed `datasets 4.4.2` package requires `pyarrow>=21.0.0`, while `autogluon.tabular 1.5.0` selected `pyarrow 20.0.0`. Required AE-VALIDATE imports passed despite this warning.

## R Package Status

`Rscript` was initially missing. Installed R with:

```text
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y r-base
```

Installed available binary R packages with:

```text
DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-data.table r-cran-jsonlite r-cran-ggplot2 r-cran-lubridate r-cran-scales r-cran-proc
```

Installed CRAN source packages for libraries not available as Ubuntu binary packages:

```text
Rscript -e 'a<-commandArgs(TRUE); install.packages(a[-1], repos=a[1])' https://cloud.r-project.org arrow PRROC
```

R package verification completed successfully:

| Package | Status | Version |
| --- | --- | --- |
| `data.table` | OK | `1.14.10` |
| `arrow` | OK | `24.0.0` |
| `jsonlite` | OK | `1.8.8` |
| `ggplot2` | OK | `3.4.4` |
| `lubridate` | OK | `1.9.3` |
| `scales` | OK | `1.3.0` |
| `pROC` | OK | `1.18.5` |
| `PRROC` | OK | `1.4` |

## Sanitized Commands Run

Representative sanitized commands:

```text
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "pwd"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "uname -a; df -h; free -h; nvidia-smi; python --version; Rscript --version; git --version"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "mkdir -p /root/AgonyAndExcstasy"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "cd /root/AgonyAndExcstasy && pwd && git status checks if repo exists"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "python -m pip install --upgrade pip numpy pandas pyarrow pyreadr scikit-learn matplotlib autogluon.tabular"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "python import verification and pip freeze package summary"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "DEBIAN_FRONTEND=noninteractive apt-get update"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "DEBIAN_FRONTEND=noninteractive apt-get install -y r-base"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-data.table r-cran-jsonlite r-cran-ggplot2 r-cran-lubridate r-cran-scales r-cran-proc"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "Rscript -e 'a<-commandArgs(TRUE); install.packages(a[-1], repos=a[1])' https://cloud.r-project.org arrow PRROC"
ssh -p <PRIMARY_PORT> root@<PRIMARY_HOST> "R package requireNamespace verification"
```

No private key contents, secret values, or data paths were written to this report.

## Readiness For Next Ticket

Ready for code/data upload: yes, with notes.

Notes:

- SSH primary endpoint works.
- Remote project root exists at `/root/AgonyAndExcstasy`.
- No repository exists there yet; code clone/upload remains deferred.
- Python and R dependency checks pass.
- GPU is visible and idle.
- Disk/RAM are adequate for the next upload/validation preparation step.
- Python dependency warning around `datasets` vs `pyarrow` should be watched if any upcoming script imports `datasets`; it is not a blocker for the required AE-VALIDATE package imports.

## Blockers

No blocking install or environment failures remain for code/data upload preparation.
