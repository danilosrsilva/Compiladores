all:
	flex flacmp.l
	bison -d flacmp.y
	g++ -std=c++2a -g -O1 *.c -o flacmp 
	./flacmp teste1.txt
