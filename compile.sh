# Compile all .d files in the given folders.
mkdir -p bin
gdc main/*.d DBorg/*.d -Wall -O3 -s -o bin/dborg
