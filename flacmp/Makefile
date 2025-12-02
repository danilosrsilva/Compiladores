all:
	flex flacmp.l
	bison -d flacmp.y
	g++ -std=c++2a -g -O1 *.c -o flacmp 


	./flacmp testes/aceita1.txt
	#./flacmp testes/aceita2.txt
	#./flacmp testes/aceita3.txt

	#./flacmp testes/erroSin1.txt
	#./flacmp testes/erroSin2.txt
	#./flacmp testes/erroSin3.txt

	#./flacmp testes/erroSem1.txt
	#./flacmp testes/erroSem2.txt
	#./flacmp testes/erroSem3.txt