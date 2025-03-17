# Observium

Observium provides real-time information about network health and performance. It uses ICMP, SNMP, and Syslog protocols to automatically discover network devices and services, collect performance metrics, and generate alerts when problems are detected. It supports a wide range of device types, platforms and operating systems, and offers features such as traffic accounting, threshold alerting, and integration with third party applications. Observium has three editions: Community, Professional, and Enterprise. The Community Edition is free and open source,

To able to use Observium, you must [enable SNMP](snmp.md) on all routers after the topology is deployed.


Change to the Observium directory and create three sub directories (you need to do this only once):

```
~/dcn$ cd observium
~/dcn/observium$ mkdir {config,logs,rrd}
```

Start Observium:

```
~/dcn/observium$ docker compose up -d
```

Wait a few minutes then open a browser and access Observium via (http://localhost:8888/). Use the username and password found in the `docker-compose.yaml` file. You may change them later. If you are still unable to log in, add a user manually:

```
docker exec -it observium /opt/observium/adduser.php <username> <password> 10
```

You can explore all Observium features from the GUI. You can also execute some functions from the command line.

To add devices to Observium from the command line, use the following example:

```
docker compose exec observium /opt/observium/add_device.php 172.20.20.11 snmpcumulus v2c
```

Run the discovery and polling scripts for the first time:

```
docker compose exec observium /opt/observium/discovery.php -h all
docker compose exec observium /opt/observium/poller.php -h all
```

Note: discovery and polling will occur periodically.

![Observium](img/observium.png)

To stop Observium:

```
docker compose down
```

Note: all configuration changes as well as data collected from devices will be persistent even after stopping and removing the containers. The data is saved in the directories you created above.
