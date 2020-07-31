run:
	moonc *.moon
	moonc dungeon_generator/*.moon
	love .
	rm *.lua
	rm dungeon_generator/*.lua

build:
	moonc *.moon
	moonc dungeon_generator/*.moon

clean:
	rm *.lua