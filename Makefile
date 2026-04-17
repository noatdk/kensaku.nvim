.PHONY: test submodules
submodules:
	git submodule update --init --recursive

test:
	nvim --headless -u NONE -l tests/regression.lua
