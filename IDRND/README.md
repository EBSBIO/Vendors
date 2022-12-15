Архитектура
===

Композиция состоит из двух частей:

 1. Движка обработки звуковых записей idrnd (осуществляет непосредственную проверку записи);
 
 2. Прокси сервера, согласующего вызовы движка idrnd с API ЕБС. 


Краткая инструкция по запуску
===

# 1. Загрузить все docker-образы из архива в локальное хранилище

``` /bin/bash
for f in *.tar.gz ; do docker load -i $f ; done
``` 

# 2. Запустить дефолтную композицию

``` /bin/bash
env $(cat .env | grep ^[A-Z] | xargs) docker stack deploy --with-registry-auth -c docker-compose.yml idrnd
```

При необходимости, отредактировать файлы `.env` и docker-compose.yaml

# 3. Проверить работоспособность

``` /bin/bash
curl http://localhost:8888/v1/voice/liveness/health
```

В случае корректной работы всех частей композиции должен прийти ответ с json объектом вида: {"status": 0}


