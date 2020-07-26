run:
	moonc *.moon
	love .
	rm *.lua

build:
	moonc *.moon

clean:
	rm *.lua