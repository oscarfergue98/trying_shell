import argparse
import yaml
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# -------------------------
# TAG (like commandArgs)
# -------------------------
parser = argparse.ArgumentParser()
parser.add_argument("tag", nargs="?", default=None)
args = parser.parse_args()

if args.tag is None:
    print("No args given, assuming we are testing")
    TAG = "test"
else:
    TAG = args.tag

print(f"Using TAG: {TAG}")

# -------------------------
# Load config.yaml
# -------------------------
with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)

MAIN_PATH = Path(config["data_path"])

# -------------------------
# Paths
# -------------------------
RAW_DATA_PATH = MAIN_PATH / "raw_data"
MODEL_RUN_PATH = MAIN_PATH / "model_runs" / TAG
INTERMEDIARY_DATA_PATH = MODEL_RUN_PATH / "intermediary_data"
OUTPUT_DATA_PATH = MODEL_RUN_PATH / "output_data"

FINAL_PLOTS_PATH = MODEL_RUN_PATH / "plots"
FINAL_PLOTS_PATH.mkdir(parents=True, exist_ok=True)

# -------------------------
# Load data
# -------------------------
file_path = INTERMEDIARY_DATA_PATH / "df_python.xlsx"
df = pd.read_excel(file_path, sheet_name="Sheet1")

df["date"] = pd.PeriodIndex(df["date"], freq="Q").to_timestamp()
df = df.sort_values("date")

# -------------------------
# STYLE (publication)
# -------------------------
plt.rcParams.update({
    "text.usetex": False,
    "font.family": "serif",
    "font.serif": ["Times New Roman"],
    "axes.titlesize": 14,
    "axes.labelsize": 12,
    "xtick.labelsize": 11,
    "ytick.labelsize": 11,
    "legend.fontsize": 11,
    "figure.dpi": 100
})

plt.style.use("seaborn-v0_8-whitegrid")

colors = {
    "gdp": "#1f77b4",
    "consumption": "#ff7f0e",
    "gfcf": "#2ca02c"
}

# -------------------------
# FIGURE
# -------------------------
fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(df["date"], df["gdp"], label="GDP", linewidth=2, color=colors["gdp"])
ax.plot(df["date"], df["consumption"], label="Consumption", linewidth=2, color=colors["consumption"])
ax.plot(df["date"], df["gfcf"], label="GFCF", linewidth=2, color=colors["gfcf"])

# Event lines
ax.axvline(pd.Timestamp("2008-01-01"), linestyle="--", color="black", alpha=0.5)
ax.axvline(pd.Timestamp("2020-01-01"), linestyle="--", color="black", alpha=0.5)

# Labels
ax.set_title("Macroeconomic Variables Over Time", pad=10)
ax.set_xlabel("Year")
ax.set_ylabel("Index")

# Time formatting
ax.xaxis.set_major_locator(mdates.YearLocator(2))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
ax.xaxis.set_minor_locator(mdates.YearLocator(1))

# Legend
ax.legend(frameon=False, loc="upper left")

# Clean spines
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

# Grid
ax.grid(True, which="major", linestyle="-", linewidth=0.6, alpha=0.4)
ax.grid(True, which="minor", linestyle=":", linewidth=0.4, alpha=0.3)

plt.tight_layout()

# -------------------------
# EXPORT (TAGGED)
# -------------------------
pdf_path = FINAL_PLOTS_PATH / f"macro_series_{TAG}.pdf"
png_path = FINAL_PLOTS_PATH / f"macro_series_{TAG}.png"

plt.savefig(pdf_path, format="pdf", bbox_inches="tight")
plt.savefig(png_path, dpi=300, bbox_inches="tight")

