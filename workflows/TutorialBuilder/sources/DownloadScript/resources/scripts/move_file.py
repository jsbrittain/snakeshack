import shutil
import argparse


def Move(
    source: str,
    dest: str,
) -> None:
    shutil.move(source, dest)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="")
    parser.add_argument("--dest", type=str, default="")

    Move(
        source=parser.parse_args().source,
        dest=parser.parse_args().dest,
    )
