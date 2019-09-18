all: docker cells-install

get-cells-install:
	go get -u github.com/pashazz/cells-install

cells-install: get-cells-install
	go build github.com/pashazz/cells-install

docker: cells-install
	docker-compose build
	docker-compose up
