parser: main.c COSStyleLex.o COSStyleParser.c
	cc -o $@ $^

COSStyleParser.c COSStyleParser.h: COSStyleParser.y lemon
	./lemon $<

COSStyleLex.o: COSStyleLex.c COSStyleParser.h
	cc -c -o $@ $<

COSStyleLex.c: COSStyleLex.l
	flex -o $@ $<

lemon: lemon.c
	cc -o $@ $<

clean:
	rm -f COSStyleParser.h COSStyleParser.c COSStyleParser.out
	rm -f COSStyleLex.h COSStyleLex.c COSStyleLex.o
	rm -f parser
	rm -f lemon
