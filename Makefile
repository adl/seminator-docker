.PHONY: build-image push-image run

build-image:
	sudo docker build $(BUILDFLAGS) -t gadl/seminator .

push-image:
	sudo docker push gadl/seminator

run:
	sudo docker run -p 8888:8888 -t gadl/seminator run-nb
