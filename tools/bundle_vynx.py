import os
import sys

# Route to build_vynx_bundle
TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, TOOLS_DIR)

from build_vynx_bundle import build

if __name__ == "__main__":
    build()
