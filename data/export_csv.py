"""Export balance.xlsx tabs to CSVs the game loads at runtime.
Run after any edit to balance.xlsx. Commit both the .xlsx and the CSVs.
Stops at the first blank row so trailing designer notes are not exported."""
import pandas as pd, sys, pathlib

TABS = ["Globals","Crops","Goods","Buildings","Progression","Orders","Currencies"]
src = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else "balance.xlsx")
out = pathlib.Path(sys.argv[2] if len(sys.argv)>2 else ".")
out.mkdir(parents=True, exist_ok=True)

for tab in TABS:
    df = pd.read_excel(src, sheet_name=tab, header=3)
    df = df.loc[:, ~df.columns.astype(str).str.startswith("Unnamed")]
    keep = []
    for _, row in df.iterrows():
        if pd.isna(row.iloc[0]) or pd.isna(row.iloc[1]):
            break                      # blank row => notes follow
        keep.append(row)
    df = pd.DataFrame(keep)
    for c in df.columns:               # 3.0 -> 3
        if pd.api.types.is_float_dtype(df[c]) and (df[c].dropna() % 1 == 0).all():
            df[c] = df[c].astype("Int64")
    df.to_csv(out / f"{tab.lower()}.csv", index=False)
    print(f"{tab:12} -> {tab.lower()}.csv  ({len(df)} rows)")
