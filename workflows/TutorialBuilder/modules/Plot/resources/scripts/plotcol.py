import json
import argparse
import pandas as pd
import matplotlib.pyplot as plt


def PlotColumn(
    source: str,
    col_x: str,
    col_y: str,
) -> None:
    # Read data
    df = pd.read_csv(source)

    df.index = df[col_x]
    series = df[col_y]

    # Plot data
    fig, ax = plt.subplots()
    ax.plot(series)
    if len(series) > 12:
        ax.xaxis.set_major_locator(plt.MaxNLocator(12))
    ax.set(xlabel=col_x, ylabel=col_y)
    plt.xticks(rotation=45)
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--col_x", type=str, default="")
    parser.add_argument("--col_y", type=str, default="")

    PlotColumn(
        source=parser.parse_args().source,
        col_x=parser.parse_args().col_x,
        col_y=parser.parse_args().col_y,
    )
