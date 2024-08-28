`. <(wget -qO- https://raw.githubusercontent.com/g7AzaZLO/ocean_protocol_auto_installer/main/ocean_install.sh)` </br>
ждем установку примерно минут 15. Далее вводим свой приватный ключ, айпи ноды, адрес кошелька</br>
после того как пойдут первые логи и нода выключится через 3 секунды - в начале логов нужно достать id ноды

![image](https://github.com/user-attachments/assets/2378406a-d76f-47ed-8561-8fd15459f0ac)
После этого открываем .env файл командой </br>
`nano .env` </br>

![image](https://github.com/user-attachments/assets/ab647a89-08a3-4327-b88b-eb5f01eaaec8)

В эти места вставляем свой id. Удаляем старый докер контейнер и поднимаем новый</br>
`docker ps -a`</br>
`docker rm айди_контейнера_с_статусом_excited`</br>
`docker run --env-file .env -e 'getP2pNetworkStats' -p 8000:8000 -p 9000:9000 -p 9001:9001 -p 9002:9002 -p 9003:9003  ocean-node:mybuild`

