
.PHONY: test git github

test: 
	prove --exec perl6 -lr

git:
	git add .
	git commit 
	git push origin master

github: git
	git push github master
