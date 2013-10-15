CONFIGS = \
	Makefile \
	Xdefaults \
	Xresources-snowbell \
	bashrc \
	gitignore \
	gitconfig \
	screenrc \
	toprc \
	vimrc \
	conkyrc-snowmobile \
	conkyrc-snowcone \
	conkyrc-snowblower \
	xbindkeysrc-snowcone \
	rc.lua-snowmobile \
	rc.lua-snowcone \
	rc.lua-snowblower \
	theme.lua-snowmobile \
	theme.lua-snowblower \
	theme.lua-snowcone

default : all

all : $(CONFIGS)

clean :
	rm *~ ftp-install-script || true

install-file-% : %
	install $* $(HOME)/.$*

install-file-conkyrc-snowmobile : conkyrc-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.conkyrc

install-file-conkyrc-snowcone : conkyrc-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.conkyrc

install-file-conkyrc-snowblower : conkyrc-snowblower
	test `hostname` != 'snowblower' || install $< $(HOME)/.conkyrc

install-file-xbindkeysrc-snowcone : xbindkeysrc-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.xbindkeysrc

install-file-rc.lua-snowmobile : rc.lua-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.config/awesome/rc.lua

install-file-theme.lua-snowmobile : theme.lua-snowmobile
	test `hostname` != 'snowmobile' || install $< $(HOME)/.config/awesome/theme.lua

install-file-rc.lua-snowblower : rc.lua-snowblower
	test `hostname` != 'snowblower' || install $< $(HOME)/.config/awesome/rc.lua

install-file-theme.lua-snowblower : theme.lua-snowblower
	test `hostname` != 'snowblower' || install $< $(HOME)/.config/awesome/theme.lua

install-file-rc.lua-snowcone : rc.lua-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.config/awesome/rc.lua

install-file-theme.lua-snowcone : theme.lua-snowcone
	test `hostname` != 'snowcone' || install $< $(HOME)/.config/awesome/theme.lua

install-file-Xdefaults : Xdefaults
	test `hostname` = 'snowbell' || install $< $(HOME)/.Xdefaults

install-file-Xresources-snowbell : Xresources-snowbell
	test `hostname` != 'snowbell' || install $< $(HOME)/.Xresources

install-file-gitconfig : gitconfig
	test `hostname` = 'padang' || install $< $(HOME)/.gitconfig

install: $(foreach f, $(CONFIGS), install-file-$(f) )

