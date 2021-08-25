SHELL = /bin/bash

update copy :
	-for i in $$(cat copy-list.txt); do \
		cp -a ../$$i bin; \
		cp -a ../doc/$$i.* doc 2>/dev/null; \
	done

checkin commit save :
	git ci -am Updated

upload :
	git pull origin develop
	git push origin develop

release :
	git co main
	git merge develop
	git push origin main
	git co develop
