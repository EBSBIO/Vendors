# Имена образов
- в .env (APP_IMAGE, APP_TAG), в sha256.scv одинаковые <app_image>:<tag>
- имя архива такое же, двоеточие заменяется на подчёркивание <app_image>_<tag>.tar.gz
- образы загруженные из архива (docker load -i <app_image>_<tag>.tar.gz), должны иметь имя ${REGISTRY_Url}/${VENDOR}/${APP_IMAGE}:${APP_TAG}. Это имя складывается из переменных в .env и используется в compose
                   
# sha256.csv
docker inspect --format='{{index .Id}}' <app_image>:<tag>


# Расположение файлов на ftp
    vendor_name
    ├── liveness_engine_cpu_v3.6.2.tar.gz
    ├── liveness_engine_cpu_v3.6.3.tar.gz
    ├── verify_engine_cpu_v1.tar.gz
    ├── verify_engine_cpu_v3.6.2.tar.gz
    ├── verify_proxy_v0.1.tar.gz
    ├── liveness_proxy_v0.1.tar.gz
    ├── v1
    │   ├── verification-cpu
    │   │   ├── docker-compose.yml
    │   │   ├── .env
    │   │   ├── sha256
    │   │   ├── README
    │   │   ├── licence
    ├── v3.6.2
    │   ├── liveness-voice-cpu
    │   │   ├── docker-compose.yml
    │   │   ├── .env
    │   │   ├── sha256
    │   ├── verification-cpu
    │   │   ├── docker-compose.yml
    │   │   ├── .env
    │   │   ├── sha256
    ├── v3.6.3
    │   ├── liveness-voice-cpu
    │   │   ├── docker-compose.yml
    │   │   ├── .env
    │   │   ├── sha256
В таком виде для того чтоб отработал наш скрипт автоматизировано развёртывания, тестирования. Логика скрипта примерно такая:
- запускаем скрипт с указание каталога с вашим compose файлом на ftp
- из этого каталога берется sha256.csv и читаются имена образов
- из каталога 2 уровнями выше берутся tar.gz из sha256.csv, проверяются контрольные суммы и образы заливаются в наш registry
- правиться .env, изменяется REGISTRY_URl на наш
- правиться .env, выставляется CORE_COUNT=1
- запускается нагрузка с увеличением потоков нагрузки
- записывается время ответа при 1 реплике БП и 1 потоке нагрузки (avgmin)
- записывается максимальная утилизация CPU
- высчитывается сколько реплик БП надо чтоб утилизировать 24 ядра (maxrepl)
- правиться .env, выставляется CORE_COUNT=maxrepl
- запускается нагрузка  с увеличением потоков
- находим количество потоков нагрузки при котором время ответа БП > avgmin*1.5
- ...

# NVIDIA
### Установка Gentoo
    eselect enable vowstar
    eix-update
    emerge -av nvidia-container-toolkit

В одиночном режиме все заработает, но для swarm еще нужен файл nvidia-container-runtime, хз почему он не ставится из порта nvidia-container-toolkit  
Скачиваем nvidia-container-toolkit-1.9.0-1.x86_64.rpm (версию берем как установили с порта) и закидываем в /usr/bin/nvidia-container-runtime  
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#id3


### Установка RedOS7.3 (Centos7)
#### Ядро  
    dnf install redos-kernels-release
    dnf update

#### Docker  
    curl -s -L https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo
    sed '7i priority=1' -i /etc/yum.repos.d/docker-ce.repo
    dnf install docker-ce docker-ce-cli

#### Nvidia container toolkit  
    curl -s -L https://nvidia.github.io/libnvidia-container/centos7/libnvidia-container.repo > /etc/yum.repos.d/libnvidia-container.repo
    yum install nvidia-container-toolkit nvidia-kmod nvidia-modprobe nvidia-persistenced xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs

#### Загрузка  
Edit /etc/default/grub. Append the following  to “GRUB_CMDLINE_LINUX” rd.driver.blacklist=nouveau nouveau.modeset=0  
Generate a new grub configuration to include the above changes.  
    grub2-mkconfig -o /boot/grub2/grub.cfg

Edit/create /etc/modprobe.d/blacklist.conf and append: blacklist nouveau


### Настройка  
/etc/docker/daemon.json  
в node-generic-resources прописываем ID своих видеокарт  
    nvidia-smi -a | grep UUID | awk '{print "NVIDIA-GPU="substr($4,0,12)}'

https://gist.github.com/tomlankhorst/33da3c4b9edbde5c83fc1244f010815c?permalink_comment_id=3641014#gistcomment-3641014  
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html#daemon-configuration-file


    {
        "runtimes": {
            "nvidia": {
                "path": "/usr/bin/nvidia-container-runtime",
                "runtimeArgs": [] 
            }
        }, 
        "default-runtime": "nvidia",
        "node-generic-resources": [
            "NVIDIA-GPU=GPU-c0fb513c"
        ]  
    }

/etc/nvidia-container-runtime/config.toml  
разкоментируем строку swarm-resource = "DOCKER_RESOURCE_GPU"


### Проверка
#### Run  
    docker run --rm --gpus all,capabilities=utility nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

#### Service  
https://docs.docker.com/engine/reference/commandline/service_create/#create-services-requesting-generic-resources
    docker service create --generic-resource "NVIDIA-GPU=0" --replicas 1 --name nvidia-cuda --entrypoint "sleep 5000" nvidia/cuda:11.8.0-base-ubuntu22.04
    docker exec -it  $(docker service ps --no-trunc --format "{{.Name}}.{{.ID}}" nvidia-cuda) nvidia-smi
    docker service rm nvidia-cuda

#### Stack  
    echo 'version: "3.5"
    services:
      cuda:
        image: nvidia/cuda:11.8.0-base-ubuntu22.04
        command: "sleep 5000"' > cuda-stack.yml

    docker stack deploy -c cuda-stack.yml nvidia
    docker exec -it  $(docker service ps --no-trunc --format "{{.Name}}.{{.ID}}" nvidia_cuda) nvidia-smi
    docker stack rm nvidia

# Как сократить размер образа
посмотреть инфу о слоях в образе:
    docker history
    docker run --rm -it  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest <имя_образа>
Dockerfile
- Группируйте ваши команды
- Используете multi-stage builds
- Применяйте опцию —squash при docker build
