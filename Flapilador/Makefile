all:
	flex flapilador.l
	bison -d flapilador.y
	g++ -std=c++2a -g -O1 *.c -o cmp
	./cmp < teste1.txt
	
