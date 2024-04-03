@echo off

echo "Build started"
ping -n 3 127.0.0.1 > nul
echo "Compiling C libs ..."
ping -n 3 127.0.0.1 > nul
echo "Compiling modules ..."
ping -n 3 127.0.0.1 > nul
echo "Build completed successfully."
echo "Some library 1" > app_lib_1.a
echo "Some library 2" > app_lib_2.a
