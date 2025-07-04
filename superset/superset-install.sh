git clone --depth=1  https://github.com/apache/superset.git

cd superset

docker compose -f docker-compose-non-dev.yml up --build
