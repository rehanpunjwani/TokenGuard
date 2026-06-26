"""Allow `python -m recall_py ...` (useful when the console script is not on PATH)."""

from recall_py.cli import main

if __name__ == "__main__":
    main()
