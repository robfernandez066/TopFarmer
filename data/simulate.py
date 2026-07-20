"""Balance simulator for TopFarmer.

Reads the exported CSVs and simulates a player to answer the only question
that matters early: how long does it take to reach level 10, and does the
player ever sit with nothing to do?

This is a sanity check, not a model of fun. It assumes a perfectly efficient
player who always plants the best gold/hr crop available and never wastes a
plot. Real players are worse than this, so treat the output as a FLOOR on
time-to-level, not an estimate.

Usage: python simulate.py [--sessions-per-day 3] [--session-minutes 6]
"""
import csv, argparse, pathlib

D = pathlib.Path(__file__).parent

def load(name):
    with open(D / f"{name}.csv", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return v

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--sessions-per-day", type=int, default=3)
    p.add_argument("--session-minutes", type=float, default=6)
    p.add_argument("--days", type=int, default=60)
    a = p.parse_args()

    crops = [{k: num(v) for k, v in r.items()} for r in load("crops")]
    prog  = [{k: num(v) for k, v in r.items()} for r in load("progression")]

    level, xp, gold = 1, 0.0, 250.0
    plots = {r["level"]: r["plots_unlocked"] for r in prog}
    xp_needed = {r["level"]: r["cumulative_xp"] for r in prog}
    max_level = int(max(xp_needed))

    # session-based: player logs in N times/day, harvests whatever finished,
    # replants. Between sessions, real time passes and crops grow.
    gap_sec = 86400 / a.sessions_per_day
    log = []
    reached = {}

    for day in range(1, a.days + 1):
        for _ in range(a.sessions_per_day):
            avail = [c for c in crops if c["unlock_level"] <= level]
            n_plots = plots[level]

            def yield_per_session(c):
                """A plot holds ONE crop. Offline, it finishes once and waits.
                So a crop yields exactly 1 harvest per session if it fits in
                the gap, plus any extra cycles the player can farm by hand
                while actually logged in."""
                if c["growth_sec_eff"] > gap_sec:
                    return 0.0, 0.0        # not ready yet this session
                extra = int((a.session_minutes * 60) // c["growth_sec_eff"])
                cycles = 1 + extra
                return (c["profit_per_harvest"] * cycles,
                        c["xp_eff"] * cycles)

            best = max(avail, key=lambda c: yield_per_session(c)[0])
            g_gain, x_gain = yield_per_session(best)
            gold += g_gain * n_plots
            xp   += x_gain * n_plots

            while level < max_level and xp >= xp_needed[level + 1]:
                level += 1
                reached.setdefault(level, day)
        log.append((day, level, round(xp), round(gold)))

    print(f"sessions/day={a.sessions_per_day}  session={a.session_minutes}min\n")
    print("day  level     xp      gold")
    for day, lv, x, g in log:
        if day <= 7 or day % 7 == 0:
            print(f"{day:3}  {lv:5}  {x:7}  {g:8}")
    print("\nfirst day at each level:")
    for lv in sorted(reached):
        print(f"  level {lv:2}: day {reached[lv]}")
    if level < max_level:
        print(f"\nDid NOT reach level {max_level} in {a.days} days (stalled at {level}).")
    print("\nSanity checks:")
    for c in crops:
        if c["profit_per_harvest"] <= 0:
            print(f"  FAIL crop {c['name']} has non-positive profit")
    goods = [{k: num(v) for k, v in r.items()} for r in load("goods")]
    for g in goods:
        if g["margin"] <= 0:
            print(f"  FAIL good {g['name']} destroys value (margin {g['margin']})")
    print("  done.")

if __name__ == "__main__":
    main()
