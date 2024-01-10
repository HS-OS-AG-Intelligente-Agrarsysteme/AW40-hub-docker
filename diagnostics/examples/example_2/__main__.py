import argparse

from example import main

parser = argparse.ArgumentParser(prog="Diagnostics Example 2.")
parser.add_argument(
    "-i", "--interactive",
    action="store_true",
    default=False,
    help="Require manual confirmation before providing any data."
)
args = parser.parse_args()


main(interactive=args.interactive)
