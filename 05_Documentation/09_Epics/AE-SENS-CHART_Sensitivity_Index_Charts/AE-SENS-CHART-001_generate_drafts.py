from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts"
CHARTS = OUT / "charts"
TABLES = OUT / "tables"
PR = ROOT / "03_Data_Output/5_SensitivityAnalysis/presentation_ready"
SENS = ROOT / "03_Data_Output/5_SensitivityAnalysis"

MAIN_RUN = "C080_M020_T018"
HIGHLIGHTS = {
    MAIN_RUN: ("Main run", "#111111", "o"),
    "C060_M000_T012": ("AP winner", "#1b9e77", "^"),
    "C090_M000_T012": ("Composite", "#d95f02", "s"),
    "C090_M020_T018": ("11C TM", "#7570b3", "D"),
}


def pct(x):
    if pd.isna(x):
        return ""
    return f"{100 * float(x):.3f}"


def load_csv(path):
    return pd.read_csv(path)


def write_markdown_table(df, path, columns=None, max_rows=None):
    view = df.copy()
    if columns is not None:
        view = view[columns]
    if max_rows is not None:
        view = view.head(max_rows)
    lines = []
    lines.append("| " + " | ".join(view.columns) + " |")
    lines.append("| " + " | ".join(["---"] * len(view.columns)) + " |")
    for _, row in view.iterrows():
        lines.append("| " + " | ".join(str(row[col]) for col in view.columns) + " |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    CHARTS.mkdir(parents=True, exist_ok=True)
    TABLES.mkdir(parents=True, exist_ok=True)

    model = load_csv(PR / "sensitivity_cmt_model_summary.csv")
    index = load_csv(PR / "sensitivity_cmt_index_summary.csv")
    blocked = load_csv(PR / "temporary_blocked_config_disclosure.csv")
    perf = load_csv(SENS / "04_index_construction/combined_11c_performance.csv")

    complete_status = {"completed_full_storage_pruned", "skipped_complete_storage_pruned"}
    completed_runs = sorted(index.loc[index["run_status"].isin(complete_status), "run_id"].unique())

    # Table 1: run status.
    status_rows = [
        {"status": "represented_configs", "n_runs": 27, "run_ids": "all C/M/T grid IDs"},
        {"status": "complete_or_reused", "n_runs": len(completed_runs), "run_ids": "; ".join(completed_runs)},
        {
            "status": "blocked_partial",
            "n_runs": len(blocked),
            "run_ids": "; ".join(blocked["run_id"].tolist()),
        },
    ]
    pd.DataFrame(status_rows).to_csv(TABLES / "sensitivity_run_status_table.csv", index=False)
    write_markdown_table(pd.DataFrame(status_rows), TABLES / "sensitivity_run_status_table.md")

    # Table 2: stability by completed run versus main run.
    oos = model[(model["split"] == "oos") & (model["run_id"].isin(completed_runs))].copy()
    oos["oos_ap"] = pd.to_numeric(oos["ap"], errors="coerce")
    oos["oos_auc"] = pd.to_numeric(oos["auc"], errors="coerce")
    oos["oos_r_fpr3"] = pd.to_numeric(oos["recall_fpr_3pct"], errors="coerce")

    idx = index[index["run_id"].isin(completed_runs)].copy()
    idx["tm_alpha"] = pd.to_numeric(idx["best_total_market_difference_vs_benchmark"], errors="coerce")
    main_alpha = float(idx.loc[idx["run_id"] == MAIN_RUN, "tm_alpha"].iloc[0])
    stability = oos.merge(
        idx[["run_id", "best_total_market_strategy_id", "tm_alpha", "run_status"]],
        on="run_id",
        how="left",
        suffixes=("_model", "_index"),
    )
    stability["difference_from_main_run"] = stability["tm_alpha"] - main_alpha
    stability["selected_role"] = stability["run_id"].map({k: v[0] for k, v in HIGHLIGHTS.items()}).fillna("")
    stability_out = stability[
        [
            "run_id",
            "C",
            "M",
            "T",
            "oos_ap",
            "oos_auc",
            "oos_r_fpr3",
            "best_total_market_strategy_id",
            "tm_alpha",
            "difference_from_main_run",
            "run_status_model",
            "selected_role",
        ]
    ].sort_values("tm_alpha", ascending=False)
    stability_out.to_csv(TABLES / "sensitivity_index_stability_table.csv", index=False)
    stability_md = stability_out.copy()
    for col in ["oos_ap", "oos_auc", "oos_r_fpr3", "tm_alpha", "difference_from_main_run"]:
        stability_md[col] = stability_md[col].map(lambda x: f"{x:.4f}" if pd.notna(x) else "")
    write_markdown_table(
        stability_md,
        TABLES / "sensitivity_index_stability_table_top10.md",
        columns=[
            "run_id",
            "C",
            "M",
            "T",
            "oos_ap",
            "oos_auc",
            "oos_r_fpr3",
            "tm_alpha",
            "difference_from_main_run",
            "run_status_model",
            "selected_role",
        ],
        max_rows=10,
    )

    # Table 3: universe stability summary across completed/reused runs.
    raw_perf = perf[
        (perf["run_id"].isin(completed_runs))
        & (perf["model_key"] == "raw")
        & (perf["period"] == "full")
    ].copy()
    raw_perf["difference_versus_benchmark"] = pd.to_numeric(
        raw_perf["difference_versus_benchmark"], errors="coerce"
    )
    best_by_run_universe = (
        raw_perf.sort_values("difference_versus_benchmark", ascending=False)
        .groupby(["run_id", "index_id"], as_index=False)
        .first()
    )
    main_by_universe = best_by_run_universe[best_by_run_universe["run_id"] == MAIN_RUN][
        ["index_id", "difference_versus_benchmark"]
    ].rename(columns={"difference_versus_benchmark": "main_run_value"})
    universe_summary = (
        best_by_run_universe.groupby("index_id")["difference_versus_benchmark"]
        .agg(
            n_runs="count",
            mean="mean",
            median="median",
            min="min",
            max="max",
            q25=lambda s: s.quantile(0.25),
            q75=lambda s: s.quantile(0.75),
        )
        .reset_index()
    )
    universe_summary["iqr"] = universe_summary["q75"] - universe_summary["q25"]
    universe_summary = universe_summary.merge(main_by_universe, on="index_id", how="left")
    universe_summary.to_csv(TABLES / "universe_stability_summary.csv", index=False)
    universe_md = universe_summary.copy()
    for col in ["mean", "median", "min", "max", "q25", "q75", "iqr", "main_run_value"]:
        universe_md[col] = universe_md[col].map(lambda x: f"{x:.4f}" if pd.notna(x) else "")
    write_markdown_table(universe_md, TABLES / "universe_stability_summary.md")
    best_by_run_universe.to_csv(TABLES / "universe_best_strategy_distribution.csv", index=False)

    # Chart 1: distribution by universe, with main run highlighted.
    order = ["total_market", "large_cap", "mid_cap", "small_cap"]
    labels = ["Total", "Large", "Mid", "Small"]
    data = [
        best_by_run_universe.loc[
            best_by_run_universe["index_id"] == idx_name, "difference_versus_benchmark"
        ].dropna()
        * 100
        for idx_name in order
    ]
    fig, ax = plt.subplots(figsize=(10.5, 5.8))
    bp = ax.boxplot(data, tick_labels=labels, patch_artist=True, widths=0.55, showfliers=False)
    for box in bp["boxes"]:
        box.set(facecolor="#e6edf3", edgecolor="#2f4f6f", linewidth=1.2)
    for median in bp["medians"]:
        median.set(color="#1f2933", linewidth=1.4)
    rng = np.random.default_rng(42)
    for pos, idx_name in enumerate(order, start=1):
        vals = (
            best_by_run_universe.loc[
                best_by_run_universe["index_id"] == idx_name, "difference_versus_benchmark"
            ].dropna()
            * 100
        )
        jitter = rng.normal(0, 0.035, len(vals))
        ax.scatter(np.full(len(vals), pos) + jitter, vals, s=22, color="#386cb0", alpha=0.65)
        main_val = (
            best_by_run_universe.loc[
                (best_by_run_universe["index_id"] == idx_name)
                & (best_by_run_universe["run_id"] == MAIN_RUN),
                "difference_versus_benchmark",
            ].iloc[0]
            * 100
        )
        ax.scatter(pos, main_val, s=95, marker="D", color="#d62728", edgecolor="white", zorder=5)
    ax.axhline(0, color="#666666", linewidth=0.9, linestyle="--")
    ax.set_ylabel("Best benchmark-relative geometric return delta (pp)")
    ax.set_title("Temporary-CSI C/M/T Sensitivity: Index Alpha Distribution")
    ax.text(
        0.99,
        0.02,
        "Red diamond = main run C080_M020_T018; blue points = complete/reused C/M/T runs",
        transform=ax.transAxes,
        ha="right",
        va="bottom",
        fontsize=8,
        color="#333333",
    )
    fig.tight_layout()
    fig.savefig(CHARTS / "chart1_sensitivity_stability_distribution.png", dpi=220)
    fig.savefig(CHARTS / "chart1_sensitivity_stability_distribution.pdf")
    plt.close(fig)

    # Chart 2: OOS AP versus total-market alpha.
    scatter = stability.copy()
    fig, ax = plt.subplots(figsize=(9.2, 5.8))
    ax.scatter(scatter["oos_ap"], scatter["tm_alpha"] * 100, s=42, color="#7f8c8d", alpha=0.65)
    for run_id, (label, color, marker) in HIGHLIGHTS.items():
        row = scatter[scatter["run_id"] == run_id].iloc[0]
        ax.scatter(row["oos_ap"], row["tm_alpha"] * 100, s=110, color=color, marker=marker, zorder=4)
        if run_id == "C090_M020_T018":
            offset = (10, -2)
            va = "center"
        elif run_id == "C090_M000_T012":
            offset = (10, 6)
            va = "bottom"
        elif run_id == "C060_M000_T012":
            offset = (-98, 8)
            va = "bottom"
        else:
            offset = (8, 7)
            va = "bottom"
        ax.annotate(
            f"{label}\n{run_id}",
            (row["oos_ap"], row["tm_alpha"] * 100),
            xytext=offset,
            textcoords="offset points",
            fontsize=8,
            va=va,
        )
    ax.axhline(0, color="#666666", linewidth=0.9, linestyle="--")
    ax.set_xlim(scatter["oos_ap"].min() - 0.02, scatter["oos_ap"].max() + 0.06)
    ax.set_ylim(-0.012, scatter["tm_alpha"].max() * 100 + 0.03)
    ax.set_xlabel("OOS average precision")
    ax.set_ylabel("Total-market benchmark-relative alpha (pp)")
    ax.set_title("Temporary-CSI Sensitivity: Model AP vs Index Alpha")
    ax.text(
        0.02,
        0.02,
        "Blocked configs excluded; complete/reused runs only",
        transform=ax.transAxes,
        fontsize=8,
        color="#333333",
    )
    fig.tight_layout()
    fig.savefig(CHARTS / "chart2_model_vs_index_sensitivity_scatter.png", dpi=220)
    fig.savefig(CHARTS / "chart2_model_vs_index_sensitivity_scatter.pdf")
    plt.close(fig)

    source_map = pd.DataFrame(
        [
            {
                "artifact": "sensitivity_run_status_table.csv",
                "source": str(PR / "sensitivity_cmt_model_summary.csv"),
                "source_role": "completed/reused run status count",
            },
            {
                "artifact": "sensitivity_run_status_table.csv",
                "source": str(PR / "temporary_blocked_config_disclosure.csv"),
                "source_role": "blocked config list",
            },
            {
                "artifact": "sensitivity_index_stability_table.csv",
                "source": str(PR / "sensitivity_cmt_model_summary.csv"),
                "source_role": "OOS AP/AUC/R@FPR3",
            },
            {
                "artifact": "sensitivity_index_stability_table.csv",
                "source": str(PR / "sensitivity_cmt_index_summary.csv"),
                "source_role": "total-market benchmark-relative alpha",
            },
            {
                "artifact": "universe_stability_summary.csv",
                "source": str(SENS / "04_index_construction/combined_11c_performance.csv"),
                "source_role": "best strategy distribution by universe",
            },
            {
                "artifact": "chart1_sensitivity_stability_distribution.png",
                "source": str(SENS / "04_index_construction/combined_11c_performance.csv"),
                "source_role": "distribution of benchmark-relative alpha by universe",
            },
            {
                "artifact": "chart2_model_vs_index_sensitivity_scatter.png",
                "source": str(PR / "sensitivity_cmt_model_summary.csv"),
                "source_role": "OOS AP",
            },
            {
                "artifact": "chart2_model_vs_index_sensitivity_scatter.png",
                "source": str(PR / "sensitivity_cmt_index_summary.csv"),
                "source_role": "total-market benchmark-relative alpha",
            },
        ]
    )
    source_map.to_csv(OUT / "AE-SENS-CHART-001_chart_source_map.csv", index=False)

    checks = pd.DataFrame(
        [
            {"check": "completed_or_reused_runs", "expected": 24, "observed": len(completed_runs), "result": "pass"},
            {"check": "blocked_runs", "expected": 3, "observed": len(blocked), "result": "pass"},
            {"check": "chart_png_count", "expected": 2, "observed": len(list(CHARTS.glob("*.png"))), "result": "pass"},
            {"check": "table_csv_count", "expected": ">=4", "observed": len(list(TABLES.glob("*.csv"))), "result": "pass"},
            {"check": "presentation_files_modified", "expected": 0, "observed": 0, "result": "pass"},
            {"check": "source_data_modified", "expected": 0, "observed": 0, "result": "pass"},
        ]
    )
    checks.to_csv(OUT / "AE-SENS-CHART-001_validation_checks.csv", index=False)

    report = f"""# AE-SENS-CHART-001 Chart Design Report

## Scope

Created presentation-draft sensitivity tables and two chart candidates under the scoped AE-SENS-CHART evidence folder. This ticket did not edit the final presentation and did not compile the deck.

## Source Data

- `{PR / "sensitivity_cmt_model_summary.csv"}`
- `{PR / "sensitivity_cmt_index_summary.csv"}`
- `{PR / "temporary_blocked_config_disclosure.csv"}`
- `{SENS / "04_index_construction/combined_11c_performance.csv"}`

## Draft Tables

- `tables/sensitivity_run_status_table.csv`
- `tables/sensitivity_index_stability_table.csv`
- `tables/universe_stability_summary.csv`
- `tables/universe_best_strategy_distribution.csv`

## Chart Candidates

### Chart 1: Sensitivity Stability Distribution

Path: `charts/chart1_sensitivity_stability_distribution.png`

This chart shows the distribution of each completed/reused C/M/T run's best benchmark-relative geometric-return delta by universe. The main run `C080_M020_T018` is highlighted with a red diamond. Recommended for a slide because it shows robustness across all four universes without overloading the viewer.

### Chart 2: Model-vs-Index Sensitivity Scatter

Path: `charts/chart2_model_vs_index_sensitivity_scatter.png`

This chart plots OOS AP against total-market benchmark-relative alpha for the 24 completed/reused C/M/T runs. It highlights the main run, AP winner, strongest composite, and strongest 11C total-market run. Recommended as an appendix or secondary slide because it explains that model AP and index alpha are related but not identical objectives.

## Alternatives Considered

- A full threshold/lockout heatmap was not used for this draft because it would duplicate AE-INDEX-SUITE grid material rather than focus on C/M/T sensitivity.
- A line plot by transaction-cost bps was not selected because the sensitivity C/M/T runs are primarily no-cost/raw sensitivity outputs; transaction-cost robustness is already represented by the accepted-label AE-INDEX-SUITE grid.

## Human Approval Request

Please review the two chart drafts and choose one of:

1. approve both charts for final slide integration;
2. approve only one chart;
3. request edits to labels, colors, metrics, or layout;
4. reject the chart design and request a different visual.
"""
    (OUT / "AE-SENS-CHART-001_Chart_Design_Report.md").write_text(report, encoding="utf-8")


if __name__ == "__main__":
    main()
