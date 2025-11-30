#!/usr/bin/env python3
import os
import shutil

BASE_DIR = "data"
OUT_DIR  = "data/all_maf_flat"

def main():
    if not os.path.isdir(BASE_DIR):
        raise SystemExit(f"Base directory does not exist: {BASE_DIR}")

    os.makedirs(OUT_DIR, exist_ok=True)

    newly_copied = 0
    removed_gz = 0
    skipped = 0

    for root, dirs, files in os.walk(BASE_DIR):
        for fname in files:
            fpath = os.path.join(root, fname)

            # Remove .gz files
            if fname.endswith(".gz"):
                try:
                    os.remove(fpath)
                    removed_gz += 1
                    print(f"[rm] {fpath}")
                except Exception as e:
                    print(f"[WARN] Could not remove {fpath}: {e}")
                continue

            # Copy .maf files
            if fname.endswith(".maf"):
                dest = os.path.join(OUT_DIR, fname)

                if os.path.exists(dest):
                    print(f"[SKIP] Already exists: {dest}")
                    skipped += 1
                    continue

                try:
                    shutil.copy2(fpath, dest)
                    newly_copied += 1
                    print(f"[COPY] {fpath} -> {dest}")
                except Exception as e:
                    print(f"[WARN] Could not copy {fpath}: {e}")
            else:
                skipped += 1

    # Count final .maf files in OUT_DIR
    final_maf_count = len([f for f in os.listdir(OUT_DIR) if f.endswith(".maf")])

    print("\n=== SUMMARY ===")
    print(f"New .maf copied  : {newly_copied}")
    print(f".gz files removed: {removed_gz}")
    print(f"Other skipped    : {skipped}")
    print(f"Final .maf count : {final_maf_count}")
    print(f"Output folder    : {OUT_DIR}")

if __name__ == "__main__":
    main()
