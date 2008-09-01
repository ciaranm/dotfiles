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
	xbindkeysrc-snowcone

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
	[[ `hostname` != 'snowmobile' ]] || install $< $(HOME)/.conkyrc

install-file-conkyrc-snowcone : conkyrc-snowcone
	[[ `hostname` != 'snowcone' ]] || install $< $(HOME)/.conkyrc

install-file-xbindkeysrc-snowcone : xbindkeysrc-snowcone
	[[ `hostname` != 'snowcone' ]] || install $< $(HOME)/.xbindkeysrc

install: $(foreach f, $(CONFIGS), install-file-$(f) )

