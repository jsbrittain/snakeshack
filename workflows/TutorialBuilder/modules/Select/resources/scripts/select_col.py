import json
import argparse
import pandas as pd
from typing import List


def Select(
    source: str,
    dest: str,
    cols: List[str],
) -> None:
    # Read data
    df = pd.read_csv(source)

    # Select columns
    df = df[cols]

    # Save data
    df.to_csv(dest, index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--dest", type=str, default="")
    parser.add_argument("--cols", type=str, default="")

    Select(
        source=parser.parse_args().source,
        dest=parser.parse_args().dest,
        cols=json.loads(parser.parse_args().cols.replace("\'", "\"")),
    )
