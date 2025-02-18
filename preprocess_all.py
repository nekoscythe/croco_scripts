import sys
import os
from utils.preprocessing_utils import load_and_preprocess

# sys.argv[0] is the script name, get the two arguments
paths = []
if len(sys.argv) > 1:
    paths = sys.argv[1:]
else:
    print("Please provide at least one path to the data")
    sys.exit(1)
    
#check if all paths are valid
for path in paths:
    if not os.path.exists(path):
        print("The path {} does not exist".format(path))
        sys.exit(1)

for path in paths:
    load_and_preprocess(path)
