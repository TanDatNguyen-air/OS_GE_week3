import os
import pandas as pd
import matplotlib.pyplot as plt

single = pd.read_csv("result_1.csv")
T_single = single["time"].mean()

approaches = {
    "Approach 2 (local)": "result_2.csv",
    "Approach 3 (mutex)": "result_3.csv",
}

summary = []
for name, file in approaches.items():
    if not os.path.exists(file):
        continue
    df = pd.read_csv(file)
    avg = df.groupby("threads")["time"].mean().reset_index()
    avg["speedup"] = T_single / avg["time"]
    avg["efficiency"] = avg["speedup"] / avg["threads"]
    avg["approach"] = name
    summary.append(avg)

summary = pd.concat(summary)
summary.to_csv("summary.csv", index=False)
print(f"T_single = {T_single:.4f} s")
print(summary.to_string(index=False))

cores = os.cpu_count()
if os.path.exists("machine_info.txt"):
    for line in open("machine_info.txt"):
        if line.startswith("cores="):
            cores = int(line.split("=")[1])
plots = [
    ("time",       "Execution time (s)", "Execution Time vs Number of Threads", "time.png"),
    ("speedup",    "Speedup",            "Speedup vs Number of Threads",        "speedup.png"),
    ("efficiency", "Efficiency",         "Efficiency vs Number of Threads",     "efficiency.png"),
]
for col, ylabel, title, fname in plots:
    plt.figure(figsize=(7, 4.5))
    for name, d in summary.groupby("approach"):
        plt.plot(d["threads"], d[col], marker="o", label=name)
    if col == "time":
        plt.axhline(T_single, ls="--", c="gray", label="Single thread (baseline)")
    if col == "speedup":
        plt.axhline(1, ls=":", c="gray")
    plt.axvline(cores, ls="--", c="red", alpha=0.5, label=f"#cores = {cores}")
    plt.xscale("log", base=2)
    plt.xticks(sorted(summary["threads"].unique()),
               [str(t) for t in sorted(summary["threads"].unique())])
    plt.xlabel("Number of threads")
    plt.ylabel(ylabel)
    plt.title(title)
    plt.grid(alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(fname, dpi=150)
    print("saved", fname)

if os.path.exists("result_3_k.csv"):
    dk = pd.read_csv("result_3_k.csv")
    kavg = dk.groupby("k")["time"].mean().reset_index()
    t_k = dk["threads"].iloc[0]
    kavg["speedup"] = T_single / kavg["time"]
    kavg.to_csv("summary_k.csv", index=False)
    print(kavg.to_string(index=False))

    plt.figure(figsize=(7, 4.5))
    plt.plot(kavg["k"], kavg["time"], marker="o", label=f"Approach 3, {t_k} threads")
    plt.axhline(T_single, ls="--", c="gray", label="Single thread (baseline)")
    if len(summary[summary["approach"] == "Approach 2 (local)"]):
        a2 = summary[(summary["approach"] == "Approach 2 (local)") & (summary["threads"] == t_k)]
        if len(a2):
            plt.axhline(a2["time"].iloc[0], ls=":", c="green",
                        label=f"Approach 2, {t_k} threads")
    plt.xscale("log")
    plt.yscale("log")
    plt.xlabel("k (update shared variable every k iterations)")
    plt.ylabel("Execution time (s)")
    plt.title("Synchronization Frequency (Approach 3)")
    plt.grid(alpha=0.3, which="both")
    plt.legend()
    plt.tight_layout()
    plt.savefig("sync_frequency.png", dpi=150)
    print("saved sync_frequency.png")
