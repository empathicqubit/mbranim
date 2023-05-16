# make -p ist ein Freund
ifdef COMSPEC
SHELL := bash.exe
else
SHELL := bash
endif

all: build/mbranim.img

build:
	mkdir build

build/mbranim.img: src/main.nas | build
	./bin/yasm.exe -m x86 -f bin -o "$@" $^

clean:
	rm -rf build/

UUID=c6964bbb-394c-4874-81c4-b65bd11ea523

vbox: build/mbranim.img
	VBoxManage list vms | grep $(UUID) || VBoxManage registervm $(CURDIR)/mbranim.vbox
	VBoxManage startvm $(UUID) --type emergencystop || echo 'already unlocked'
	VBoxManage startvm $(UUID) -E VBOX_GUI_DBG_AUTO_SHOW=true -E VBOX_GUI_DBG_ENABLED=true
