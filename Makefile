run-images:
	docker run -d --name=redis redis
	docker run -d --name=db --env POSTGRES_PASSWORD=postgres --env POSTGRES_USER=postgres postgres:15-alpine
	docker run -d --name=vote -p 5423:80 --link redis:redis dockersamples/examplevotingapp_vote
	docker run -d --name=result -p 4141:80 --link db:db dockersamples/examplevotingapp_result
	docker run -d --name=worker --link redis:redis --link db:db dockersamples/examplevotingapp_worker