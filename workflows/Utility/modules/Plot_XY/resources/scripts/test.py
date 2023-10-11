import json
import argparse
import pandas as pd
import matplotlib.pyplot as plt


def plotColumn(
    source: str,
    col_x: str,
    col_y: str,
    filters: dict = {},
    convert_x_to_datetime: bool = False,
) -> None:
    # Read data
    df = pd.read_csv(source)
    if convert_x_to_datetime:
        df[col_x] = pd.to_datetime(df[col_x])

    # Filter data
    data = df
    for k, v in filters.items():
        data = data.loc[df[k] == v]

    # Plot data
    fig, ax = plt.subplots()
    ax.plot(data[col_x], data[col_y])
    ax.set(xlabel=col_x, ylabel=col_y)
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--col_x", type=str, default="")
    parser.add_argument("--col_y", type=str, default="")
    parser.add_argument("--filters", type=str, default="")
    parser.add_argument("--convert_x_to_datetime", type=bool, default=False)

    plotColumn(
        source=parser.parse_args().source,
        col_x=parser.parse_args().col_x,
        col_y=parser.parse_args().col_y,
        filters=json.loads(parser.parse_args().filters.replace("\'", "\"")),
        convert_x_to_datetime=parser.parse_args().convert_x_to_datetime,
    )
