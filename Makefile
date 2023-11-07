SHELL = /bin/bash

update copy :
	git co develop
	git pull origin develop
	-for i in $$(cat ../copy-list.txt); do \
		cp -a ../$$i bin; \
		cp -a ../doc/$$i.md doc 2>/dev/null; \
		cp -a ../doc/$$i.int.md doc 2>/dev/null; \
		cp -a ../doc/$$i.txt doc 2>/dev/null; \
	done
	git st
	echo if OK, make ci

ci checkin commit save :
	git ci -am Updated
	echo if OK, make push

push upload :
	git pull origin develop
	incver.sh -p VERSION
	git ci -am "inc patch level"
	git push origin develop
	echo if OK, make release

release :
	incver.sh -m VERSION
	git ci -am "inc minor level"
	git push origin develop
	git co main
	git merge develop -m "Merge develop to main"
	git tag -m "Release $$(cat VERSION)" $$(echo tag-$$(cat VERSION | tr '.' '-'))
	git push --tags origin main
	git co develop
	incver.sh -p VERSION
	git ci -am "inc patch level"
	git push origin develop

gist update-gist : ~/ver/github/gist/sshagent/d*/sshagent

~/ver/github/gist/sshagent/d*/sshagent : bin/sshagent
	cd ~/ver/github/gist/sshagent/d*; \
		git pull origin develop
	cp -f $? $@
	cd ~/ver/github/gist/sshagent/d*; \
		git ci -am Updated
	cd ~/ver/github/gist/sshagent/d*; \
		git push origin develop
