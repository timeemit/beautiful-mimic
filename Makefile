worker: 
	docker build -t worker -f app/docker/worker app
app: 
	docker build -t app -f app/docker/app app
