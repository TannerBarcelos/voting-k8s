# Microservices Architecture with Kubernetes; An Example

> This document serves as an outline of the sample docker / Kubernetes microservices application on Dockers public examples repo. As I am learning Kubernetes, I am creating a repo of my own to practice building this from scratch and not using the repo directly.

**Sample Application**

Voting app and vote result app

| App                                                | Technology |
| -------------------------------------------------- | ---------- |
| voting app                                         | Python     |
| in-memory db to store votes                        | Redis      |
| Worker to get updates in Redis and update Postgres | C#         |
| DB for result app                                  | Postgres   |
| Result App                                         | NodeJS     |

- As we can see, the architecture is simple but there are a lot of different applications / technologies in this micro-service app.
- The reason it is so verbose is to demonstrate how Kubernetes can span / deploy / manage etc. any application, regardless of the language. It abstracts that all away and solely focuses on the main underlying needs of deployment, scaling, high availability etc.

![Image.tiff](https://res.craft.do/user/full/23a94566-d418-41a0-9075-ac543852aabd/doc/37DAB8E1-845C-47B4-9BBF-34A07D3EEB28/598FBAE3-6D68-4C24-AD40-9F3E793D914F_2/pLL3vJAoMjOaj4tqWd0mdZkUY5MNkgm4WmCookndepwz/Image.tiff)

## Commands to Run Each App Image

> You can see the sample app at the link below. It is from the docker examples repo.

[](https://github.com/TannerBarcelos/example-voting-app)

**_In the link above, there is a docker-compose file which automates this all. For learning purposes, we are going to spin it all up from scratch_**

| **Command**                                                                                                | **Explanation**                     |
| ---------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `docker run -d --name=redis redis`                                                                         | Run the redis service               |
| `docker run -d --name=db --env POSTGRES_PASSWORD=postgres --env POSTGRES_USER=postgres postgres:15-alpine` | Run the db service                  |
| `docker run -d --name=vote -p 5423:80 --link redis:redis dockersamples/examplevotingapp_vote`              | Run the voting service              |
| `docker run -d --name=result -p 4141:80 --link db:db dockersamples/examplevotingapp_result`                | Run the result service              |
| `docker run -d --name=worker --link redis:redis --link db:db dockersamples/examplevotingapp_worker`        | Run the worker service for redis→PG |

> Since using scratch docker run commands, we need to link containers so they can talk to each other by container name (like we get in Docker-Compose). Since we are not using Compose, we need to do the manual links ourselves.

---

## Deployment Goals

#### What to do

1. Deploy the containers on K8s
2. Enable connectivity between the pods
3. Enable external connectivity from host to the clusters pods for voting and result apps

#### Steps

1. Create pods for each micro-service
2. Create services for each pod

   - We can define what service type to use by referencing the architecture diagram
   - It seems that the `redis` and `db` services are only accessed internally in the cluster by different services. This seems like a good use for `ClusterIP`
     - `ClusterIP` services:
       - redis
       - db
   - It seems that the voting app and result app talk to the db and redis, but need to be accessible by the outside world. This means we can use a `NodePort` or `LoadBalancer` . Because we are running this on our laptop, we have a single node cluster and therefore should use `NodePort` types as we don't want to set up a mock-cluster server
     - `NodePort` services:
       - vote
       - result
   - Lastly, it seems that the worker service is only talks to redis and db services to do some work, but is not directly hit by redis or db, therefore **we do not need a service for this pod. We can just run it as a pod and leave it as is.**

   > Remember, if an application needs to be exposed (accessed by others i.e Pods, external users etc.) it need a `Service` . If it does work but is not accessed by anything, then it can live on its own.

3. Access the voting app
