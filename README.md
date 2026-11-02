### Оглавление
1. [API тесты](#api-тесты)
2. [Нагрузочные тесты](#нагрузочные-тесты)
3. [Настройка окружения с GPU](#настройка-окружения-с-gpu)

---
### API тесты
Вызов скрипта без параметров показывает справку.

Для liveness скрипт представляет один исполняемый файл для всех типов лайвнесс:
- выбор типа БП осуществляется при запуске скрипта;
- есть возможность выбрать связку из нескольких типов;
- для active liveness video требуется передать в параметры запуска мнемонику;
- для active liveness video, если была выбрана мнемоника move, требуется передать в параметры запуска типы действий.

**Если БП liveness поддерживает одновременно работу по нескольким типам**, например, фото + пассивный по видео, то при запуске автотеста следует указывать именно фото+пассивное видео, чтобы корректно подобрался пул запросов.

Пример запуска API-автотеста верификации по фото метода extract:
```bash
./api_test_verification_photo.sh -vv -t extract 127.0.0.1:{SOME_PORT} 10
```

Пример запуска API-автотеста всех методов верификации по фото:
```bash
./api_test_verification_photo.sh -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста passive liveness photo (по умолчанию тип passive photo):
```bash
./api_test_liveness.sh -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста passive liveness video:
```bash
./api_test_liveness.sh -t p_video -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста photo + passive liveness video:
```bash
./api_test_liveness.sh -t photo+p_video -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста active liveness video мнемоники move-instructions:
```bash
./api_test_liveness.sh -t a_video -m move -a 1,2,3,4 -vv 127.0.0.1:{SOME_PORT} 10
```
<br>

### Нагрузочные тесты
Скрипты являются обертками над jmeter.

Во всех нагрузочных сценариях по умолчанию используется плагин [PerfMon](https://jmeter-plugins.org/wiki/PerfMon/) для сбора метрик загруженности серверов.
<br>Для доступа к системным метрикам на серверах следует также настроить [PerfMon Server Agent](https://github.com/undera/perfmon-agent/blob/master/README.md). При необходимости можно отключить плагин в сценарии jmx.

Скрипты для нагрузочного тестирования могут выполнять тест в двух режимах:
* "один сэмпл" – не требуется указывать опцию -s;
* "много сэмплов" – требуется указать опцию -s.

Вызов скрипта без параметров показывает справку.

Опция **-d**:
* запускает процесс удаления ранее извлеченных векторов в процессе тестирования;
* опция актуальна, если перед тестированием новой версии БП или другого БП требуется очистить предыдущие данные.

Опция **-b** запускает тест в screen для 8 часового теста на стабильность.
<br>Вывод jmeter можно посмотреть так: `tail -f tmp/jmeter.log`

Опция **-s**:
* указывает на абсолютный путь к директории с сэмплами для тестирования;
* опция актуальна для тестирования нагрузки в режиме "много сэмплов";
* для БП типа video liveness опция является обязательной.

Нагрузочная база для video liveness должна содержать файлы с метаданными .json и соответствующие им файлы видеосэмплов.
Например:
- 001_SMILE.json
- 001_SMILE_SAMPLE_MOV
- 002_TURN_DOWN.json
- 002_TURN_DOWN_SAMPLE_MOV
- ...

<br>Опция **-r** задает RAMP-UP период.
<br>Опция **-p** задает префикс.
<br>Опция **-t** указывает тип биопроцессора (sound/photo/video). Без опции, по умолчанию, тестируется photo.

Скрипт `stop_load.sh` останавливает тест, который был запущен с опцией **-b**.

Для проверки работы методов идентификации требуется предварительно наполнить базу данных БП.
<br>Для этого можно последовательно выполнить следующие действия с помощью `start_load_identification_photo.sh`:
- извлечь шаблоны из сэмплов, запустив скрипт для метода `extract`
- добавить их в базу данных БП, запустив скрипт для метода `add`*

Далее можно выполнять нагрузочные тесты для методов `match` и `identify`.
<br>Также появится возможность выполнить тест для методов `update` и `delete`**.

Идентификаторы добавленных в БД шаблонов можно найти `resources/csv_configs/template_ids.csv`

\* для запросов на добавление шаблонов в БД настроена генерация случайных template_id
<br>\*\* метод `delete` выполнит удаление ранее добавленных в БД шаблонов, после чего тест может начать возвращать ошибки

<br>Пример запуска теста в режиме "один сэмпл":
```bash
./start_load_verification.sh tevian_gpu extract 3 127.0.0.1 {SOME_PORT}
```

Пример запуска теста в режиме "много сэмплов":
```bash
./start_load_verification.sh -s /opt/photo/ tevian_gpu extract 3 127.0.0.1 {SOME_PORT}
```
<br>

### Настройка окружения с GPU
#### RED OS 7.3

На примере драйвера NVIDIA версии 580.76.05 (CUDA Version: 13.0).

1\. Добавление репозитория и обновление ядра
```bash
dnf install redos-kernels6-release
dnf update

dnf install \ 
    kernel-lt-6.1.148-1.el7.3.x86_64 \
    kernel-lt-tools-6.1.148-1.el7.3.x86_64 \
    kernel-lt-tools-libs-6.1.148-1.el7.3.x86_64
```    
После установки выполняем `reboot`

2\. Установка драйвера
```bash    
dnf install \
    nvidia-kmod-3:580.76.05-1.el7.x86_64 \
    nvidia-persistenced-3:580.76.05-1.el7.x86_64 \
    nvidia-modprobe-3:580.76.05-1.el7.x86_64 \
    xorg-x11-drv-nvidia-cuda-libs-3:580.76.05-1.el7.x86_64 \
    xorg-x11-drv-nvidia-cuda-3:580.76.05-1.el7.x86_64
```

3\. Установка NVIDIA CONTAINER TOOLKIT

Ссылка на офиц. источник: [https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.17.8/install-guide html#with-dnf-rhel-centos-fedora-amazon-linux](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.17.8/install-guide.html#with-dnf-rhel-centos-fedora-amazon-linux)

```bash
# добавление офиц. репозитория
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# установка пакетов
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
dnf install -y \
    nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```

4\. Настройка NVIDIA CONTAINER TOOLKIT и DOCKER SWARM

Выполняем:
```bash
nvidia-ctk runtime configure --runtime=docker
```

Указываем в конфигурации docker `/etc/docker/daemon.json` дефолтную среду выполнения:
```json
{
    "log-driver": "json-file",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "args": []
        }
    },
    "default-runtime": "nvidia"
}
```
Выполняем перезапуск docker `systemctl restart docker.service`

---
Далее есть два основных способа контроля GPU для сервисов в swarm:
- контроль ресурсов через docker swarm
- контроль ресурсов через окружение сервиса с помощью переменной `NVIDIA_VISIBLE_DEVICES`.

<br>**Контроль ресурсов через docker swarm:**
- в файле `/etc/nvidia-container-runtime/config.toml` следует добавить или раскомментировать `swarm-resource = "DOCKER_RESOURCE_GPU"`
- выводим идентификаторы GPU `nvidia-smi -a | grep UUID | awk '{print $NF}'`
- в конфигурации docker вносим полные идентификаторы GPU:
```json
{
    "log-driver": "json-file",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "args": []
        }
    },
    "default-runtime": "nvidia"
    "node-generic-resources": [
        "gpu={GPU_ID_1}",
        "gpu={GPU_ID_2}",
        ...
    ]    
}
```
- выполняем перезапуск docker `systemctl restart docker.service`
- в compose-файле следует указать кол-во GPU, которое swarm должен выделить для работы сервиса:
```yml
resources:
  reservations:
    generic_resources:
      - discrete_resource_spec:
          kind: 'gpu'
          value: 1
```

В окружение сервиса будет проброшена переменная `DOCKER_RESOURCE_GPU`, значение которой будет соответствовать одному из UUID GPU. Swarm будет самостоятельно вести подсчет зарезервированных GPU. Недостатком такого способа может являться то, что одна GPU будет доступна только для одного процесса.

Кроме того, данный способ подразумевает, что приложение при сканировании доступных GPU будет ориентироваться именно на переменную `DOCKER_RESOURCE_GPU`. В окружении не должно быть переменной `NVIDIA_VISIBLE_DEVICES`, которая имеет приоритет над другими вариантами настройки.

<br>**Контроль ресурсов c помощью переменной NVIDIA_VISIBLE_DEVICES:**
- обязательным условием является использование в окружении сервиса переменной `NVIDIA_VISIBLE_DEVICES`
- допустимые значения указаны в документации https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.17.8/docker-specialized.html

---
**Дополнительные настройки**

Может потребоваться настройка SELinux и создание кастомной политики, если драйвер блокируется.

