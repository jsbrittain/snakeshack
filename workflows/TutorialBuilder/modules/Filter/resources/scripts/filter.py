import json
import argparse
import pandas as pd


def Filter(
    source: str,
    dest: str,
    filters: dict = {},
) -> None:
    # Read data
    df = pd.read_csv(source)

    # Filter data
    for k, v in filters.items():
        df = df.loc[df[k] == v]

    df.to_csv(dest, index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--dest", type=str, default="")
    parser.add_argument("--filters", type=str, default="")

    Filter(
        source=parser.parse_args().source,
        dest=parser.parse_args().dest,
        filters=json.loads(parser.parse_args().filters.replace("\'", "\"")),
    )
