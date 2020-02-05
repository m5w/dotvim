.PHONY: all
all: SHELL := /bin/bash
all:
	while IFS= read -d '' -r file; do \
	  ln -s ../ftplugin.vim "$$file"; \
	done < <( \
	  find "$$( \
	    vim -e -T dumb --cmd \
	        'exe "set t_cm=\<C-M>"|echo $$VIMRUNTIME|quit' \
	      | tr -d '\015')"/ftplugin -name '*.vim' -printf '%f\0')

.PHONY: clean
clean:
	find . -name '*.vim' -delete
