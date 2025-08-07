docker pull ubuntu:jammy
docker-compose build
docker-compose up -d
docker-compose exec --user root dev-environment bash