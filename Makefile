
update :
	for i in $$(cat copy-list.txt); do \
		cp ../$$i bin; \
	done
