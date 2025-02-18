import sys
from utils.preprocessing_utils import load_and_preprocess

# sys.argv[0] is the script name, sys.argv[1] is the first argument
if len(sys.argv) > 1:
    argument = sys.argv[1]
else:
    print("No argument provided.")
    
# Load and preprocess the data
load_and_preprocess(argument)

