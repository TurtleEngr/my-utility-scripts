
update copy :
	for i in $$(cat copy-list.txt); do \
		cp ../$$i bin; \
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
