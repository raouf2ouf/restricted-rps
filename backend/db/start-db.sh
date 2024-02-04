docker run -d --rm \
    --name ethpoir \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=ethpoir \
    -p 5432:5432 \
    -v data:/var/lib/postgresql/data \
    postgres