CC = cc
INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

CFLAGS = -O2 -Wall -Werror

DESTDIR = $(HOME)/bin

install: vib .vibrc urlencode
	mkdir -p $(DESTDIR)
	$(INSTALL_PROGRAM) ./urlencode $(DESTDIR)/urlencode
	$(INSTALL_PROGRAM) ./vib $(DESTDIR)/vib
	$(INSTALL_DATA) ./.vibrc $$HOME/.vibrc
	mkdir -p $(HOME)/.vib
	echo '' > $(HOME)/.vib/tab1

urlencode: urlencode.c
	$(CC) $(CFLAGS) $< -o $@

uninstall:
	rm -f $(DESTDIR)/{urlencode,vib}
	rm -f $(HOME)/.vibrc
	rm -r $(HOME)/.vib

clean:
	rm -f urlencode
