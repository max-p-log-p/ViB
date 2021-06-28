install:
	mkdir -p ~/.vib
	cp -n ./vib ~/.vib/vib
	cp -n ./.vibrc ~/.vibrc
clean:
	rm -r ~/.vib
	rm ~/.vibrc
