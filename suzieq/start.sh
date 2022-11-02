docker run --rm -it -p 8501:8501 \
  -v /home/vagrant/suzieq/dbdir:/home/suzieq/parquet \
  -v /home/vagrant/suzieq/inventory.yml:/home/suzieq/inventory.yml \
  -v /home/vagrant/suzieq/my-config.yml:/home/suzieq/my-config.yml \
  --name sq-poller --network=clab \
  netenglabs/suzieq:latest
