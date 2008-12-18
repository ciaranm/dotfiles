CONFIGS = \
	Makefile \
	Xdefaults \
	bashrc \
	inkpot.vim \
	screenrc \
	securemodelines.vim \
	toprc \
	vimrc \
	conkyrc-snowmobile \
	conkyrc-snowcone \
	xbindkeysrc-snowcone \
	rc.lua-snowmobile \
	theme-snowmobile

default : all

all : $(CONFIGS)

clean :
	rm *~ ftp-install-script || true

install-file-% : %
	install $* $(HOME)/.$*

install-file-inkpot.vim : inkpot.vim
	install $< $(HOME)/.vim/colors/$<

install-file-securemodelines.vim : securemodelines.vim
	install $< $(HOME)/.vim/plugin/$<

install-file-conkyrc-snowmobile : conkyrc-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.conkyrc

install-file-conkyrc-snowcone : conkyrc-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.conkyrc

install-file-xbindkeysrc-snowcone : xbindkeysrc-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.xbindkeysrc

install-file-rc.lua-snowmobile : rc.lua-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.config/awesome/rc.lua

install-file-theme-snowmobile : theme-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.config/awesome/theme

install: $(foreach f, $(CONFIGS), install-file-$(f) )

