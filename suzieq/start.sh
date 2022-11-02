SQPATH=/home/vagrant/myclabs/cvx_dcn/suzieq
docker run --rm -it -p 8501:8501 \
  -v $SQPATH/dbdir:/home/suzieq/parquet \
  -v $SQPATH/inventory.yml:/home/suzieq/inventory.yml \
  -v $SQPATH/my-config.yml:/home/suzieq/my-config.yml \
  --name sq-poller --network=clab \
  netenglabs/suzieq:latest
