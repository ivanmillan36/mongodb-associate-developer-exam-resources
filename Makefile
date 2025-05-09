# Makefile for automating git commit and push
commit-and-push:
	git add .
	git commit -m "$(m)"
	git push