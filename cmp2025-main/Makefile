all:
	flex calc.l
	bison -d calc.y
	g++ -std=c++2a -g -O1 *.c -o calc 
	./calc teste2.txt
