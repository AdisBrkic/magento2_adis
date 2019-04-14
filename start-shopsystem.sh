#!/bin/bash
set -e

export MAGENTO_CONTAINER_NAME=web

docker-compose build --build-arg GATEWAY=API-TEST web
docker-compose up > /dev/null &

while ! $(curl --output /dev/null --silent --head --fail "${NGROK_URL}"); do
    echo "Waiting for docker container to initialize"
    sleep 20
done

docker exec -it ${MAGENTO_CONTAINER_NAME} install-magento
docker exec -it ${MAGENTO_CONTAINER_NAME} install-sampledata
docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento setup:static-content:deploy -f de_DE
docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento indexer:reindex
#rm -rf var/cache var/generation var/pagecache var/di
#docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento setup:di:compile
docker exec -it ${MAGENTO_CONTAINER_NAME} bash -c "chmod -R 777 ./"
echo "Deploy finished!"
sleep 120s
#docker exec -it ${MAGENTO_CONTAINER_NAME} composer require wirecard/magento2-ee
#docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento setup:upgrade
#docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento setup:di:compile
#docker exec -it ${MAGENTO_CONTAINER_NAME} php bin/magento module:status

#docker exec -it ${MAGENTO_CONTAINER_NAME} bash -c "cd ~/ && chmod -R 777 ./"