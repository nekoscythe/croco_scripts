import sys
from utils.preprocessing_utils import load_and_preprocess

# sys.argv[0] is the script name, get the two arguments
if len(sys.argv) == 2:
    path = sys.argv[1]
else:
    print("Usage: python preprocess.py <path>")
    sys.exit(1)

# Load and preprocess the data
load_and_preprocess(path)

