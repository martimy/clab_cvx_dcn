docker run --rm -it -p 8501:8501 \
  -v $(pwd)/dbdir:/home/suzieq/parquet \
  -v $(pwd)/inventory.yml:/home/suzieq/inventory.yml \
  -v $(pwd)/my-config.yml:/home/suzieq/my-config.yml \
  --name sq-poller --network=clab \
  netenglabs/suzieq:latest
