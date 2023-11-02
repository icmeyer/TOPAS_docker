# Dockerfile for TOPAS

This Dockerfile will build a TOPAS image with relevant data. Requires a zip file `topas_3_9.zip` containing the source code obtained from www.topasmc.org

Convenient commands for initializing a container to run a topas input file are included. The steps are as follows:

    - Navigate to the directory containing the input file
    - Run the command `bash run_docker_topas.sh input.txt`

The command will bind the current directory, run TOPAS in the container, print the output to the terminal while simultaneously writing the output to file, save the output files in the current directory, and shutdown the container. 

Future improvements:

    - Enable extensions
    - Enable mesh geometry in different directory
