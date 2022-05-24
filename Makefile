SHELL = /bin/bash

update copy :
	git co develop
	git pull origin develop
	-for i in $$(cat copy-list.txt); do \
		cp -a ../$$i bin; \
		cp -a ../doc/$$i.* doc 2>/dev/null; \
	done
	echo Check: git st
	echo if OK, make ci

ci checkin commit save :
	git ci -am Updated
	echo if OK, make push

push upload :
	git pull origin develop
	git push origin develop
	echo if OK, make release

release :
	git co main
	git merge --no-ff develop
	git push origin main
	git co develop
