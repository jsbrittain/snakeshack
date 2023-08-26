import json
import argparse
import pandas as pd
from typing import List


def AggregateByMonth(
    source: str,
    dest: str,
    datecol: str,
    cols: List[str] = [],
) -> None:
    # Read data
    df = pd.read_csv(source)

    # Preprocess data
    df[datecol] = pd.to_datetime(df[datecol])

    # Aggregate data
    series = df.groupby(df[datecol].dt.month)[cols].mean()

    # Save data
    series.to_csv(dest)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--dest", type=str, default="")
    parser.add_argument("--datecol", type=str, default="")
    parser.add_argument("--cols", type=str, default="")

    AggregateByMonth(
        source=parser.parse_args().source,
        dest=parser.parse_args().dest,
        datecol=parser.parse_args().datecol,
        cols=json.loads(parser.parse_args().cols.replace("\'", "\"")),
    )
