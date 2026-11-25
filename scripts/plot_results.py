"""Plot README figures: manuscript results (Tables 5 and 7) and the single-objective
NMPC baseline from MiskCodes/.../EAAI_Codes/MPC_Comparison.csv.

    python scripts/plot_results.py
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets"
BASELINE = ROOT / "MiskCodes/Analysis/Python/Python Main Container/EAAI_Codes/MPC_Comparison.csv"
OUT.mkdir(exist_ok=True)

INK, MUTED, ACCENT, COPPER, SAGE, LINE = "#202c3a", "#536171", "#305b8a", "#b47b40", "#5f8a6e", "#dce1e6"
plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 10, "axes.edgecolor": LINE, "axes.labelcolor": INK,
    "xtick.color": MUTED, "ytick.color": MUTED, "axes.spines.top": False, "axes.spines.right": False,
    "axes.titleweight": "bold", "axes.titlesize": 11.5, "axes.titlecolor": INK, "savefig.dpi": 200,
    "savefig.bbox": "tight", "savefig.facecolor": "white",
})

# Table 5: optimisation of the surrogate, genetic algorithm vs Bayesian optimisation
CALIBRATION = {"Wall-clock time (s)": (118.5, 2.40), "Objective evaluations": (3915, 25)}

# Table 7: surrogate model comparison
MODELS = ["DNN", "XGBoost", "TabPFN"]
SURROGATES = {
    "Test R²  (higher is better)": ([0.988, 0.698, 0.999], "{:.3f}"),
    "Test RMSE, km  (lower is better)": ([2.31, 11.42, 0.56], "{:.2f}"),
    "Training time, s  (lower is better)": ([20.32, 0.03, 0.54], "{:.2f}"),
}


def calibration():
    fig, axes = plt.subplots(1, 2, figsize=(9.5, 3.2))
    for ax, (title, (ga, bo)) in zip(axes, CALIBRATION.items()):
        bars = ax.barh(["Genetic algorithm", "Bayesian optimisation"], [ga, bo], color=[MUTED, ACCENT], height=0.55)
        ax.invert_yaxis()
        ax.set_xlim(0, ga * 1.28)
        for b, v in zip(bars, (ga, bo)):
            ax.text(b.get_width() + ga * 0.02, b.get_y() + b.get_height() / 2,
                    f"{v:,}" if isinstance(v, int) else f"{v:g}",
                    va="center", fontsize=9, color=INK)
        ax.set_title(title, loc="left")
        ax.grid(axis="x", color=LINE, lw=0.6)
        ax.set_axisbelow(True)
    axes[1].set_yticklabels([])
    speedup = CALIBRATION["Wall-clock time (s)"][0] / CALIBRATION["Wall-clock time (s)"][1]
    fig.suptitle(f"Calibrating NMPC weights on the surrogate: {speedup:.1f}× faster with Bayesian optimisation",
                 x=0.01, ha="left", fontweight="bold", color=INK, y=0.98)
    fig.tight_layout()
    fig.savefig(OUT / "calibration_speedup.png")
    plt.close(fig)


def surrogates():
    fig, axes = plt.subplots(1, 3, figsize=(11, 3.2))
    colors = [ACCENT, COPPER, SAGE]
    for ax, (title, (vals, fmt)) in zip(axes, SURROGATES.items()):
        bars = ax.bar(MODELS, vals, color=colors, width=0.6)
        top = max(vals)
        for b, v in zip(bars, vals):
            ax.text(b.get_x() + b.get_width() / 2, v + top * 0.03, fmt.format(v), ha="center", fontsize=9, color=INK)
        ax.set_ylim(0, top * 1.2)
        ax.set_title(title, loc="left", fontsize=10.5)
        ax.grid(axis="y", color=LINE, lw=0.6)
        ax.set_axisbelow(True)
    fig.suptitle("Surrogate models predicting driving range from NMPC weights", x=0.01, ha="left",
                 fontweight="bold", color=INK, y=0.98)
    fig.tight_layout()
    fig.savefig(OUT / "surrogate_comparison.png")
    plt.close(fig)


def single_objective_baseline():
    df = pd.read_csv(BASELINE).dropna(how="all")
    df["term"] = np.select([df.w1 == 1, df.w2 == 1, df.w3 == 1], ["L1  maximise min SoC", "L2  minimise SoC spread", "L3  equalise to mean SoC"], default="")
    df["cycle"] = df.DC_Name.str.replace("_extended", "").replace({"FHDS": "FHDS", "FUDSfast": "FUDS Fast", "US06City": "US06 City", "US06HW": "US06 Hwy"})
    order = list(dict.fromkeys(df.cycle))
    terms = list(dict.fromkeys(df.term))
    fig, ax = plt.subplots(figsize=(11, 3.9))
    width = 0.26
    for k, (term, color) in enumerate(zip(terms, [ACCENT, COPPER, SAGE])):
        vals = [df[(df.cycle == c) & (df.term == term)].Range.iloc[0] for c in order]
        ax.bar(np.arange(len(order)) + (k - 1) * width, vals, width * 0.92, color=color, label=term)
    for i, c in enumerate(order):
        sub = df[df.cycle == c]
        spread = sub.Range.max() - sub.Range.min()
        if spread > 0.05:
            ax.text(i, sub.Range.max() + 1.2, f"Δ {spread:.1f} km", ha="center", fontsize=8.5, color=INK)
    ax.set_xticks(range(len(order)), order)
    ax.set_ylim(130, 228)
    ax.set_ylabel("Driving range (km)")
    ax.grid(axis="y", color=LINE, lw=0.6)
    ax.set_axisbelow(True)
    ax.legend(frameon=False, ncol=3, loc="upper center", bbox_to_anchor=(0.5, -0.12))
    ax.set_title("No single cost term is best on every drive cycle: the weights must be calibrated", loc="left")
    fig.savefig(OUT / "single_objective_baseline.png")
    plt.close(fig)


if __name__ == "__main__":
    single_objective_baseline()
    calibration()
    surrogates()
