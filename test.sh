CC=g++
INC_DIR=../../ #src folder
ls $INC_DIR 
file=array(*.cuh *.cu) 
echo $file
CFLAGS=-c -Wall -l($INC_DIR)
DEPS=palabos3D.h

#all: *.cuh *.cu

%.o:%.cpp$(DEPS)
	$(CC) -o $@ $<$(CFLAGS)
	
clean:
	rm -rf *o all 
