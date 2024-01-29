import argparse

from example_1.example import main
from utils import get_workshop_token_from_keycloak

parser = argparse.ArgumentParser(prog="Diagnostics Example 1")
parser.add_argument(
    "-i", "--interactive",
    action="store_true",
    default=False,
    help="Require manual confirmation before providing any data."
)
args = parser.parse_args()


main(
    interactive=args.interactive, api_token=get_workshop_token_from_keycloak()
)
