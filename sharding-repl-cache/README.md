Задание 4. Шардирование + Репликация + Кеширование.

0. Схема draw.io лежит в корне. 

1. Модифицировал файл compose.yaml в соответствии с условием.

2. Провел инициализацию сервера конфигурации, роутера и шардов.

3. Наполнил данными роутер.

4. Проверил количество данных на шардах.

5. Страница по адресу браузере http://localhost:8080 открывается.
Скорость загрузки данных при повторном запросе менее 10мс.

==================================================================

Скрипты для проверки.

1. Запускаем.

docker compose up -d

2. Инициализируем сервер конфигурации.

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{ _id : 0, host : "configSrv:27017" }]
})
EOF

3. Инициализируем шард 1.

docker compose exec -T shard1-1 mongosh --port 27018 <<EOF
rs.initiate({
    _id: "rs1", 
    members: 
    [
        {_id: 0, host: "shard1-1:27018"},
        {_id: 1, host: "shard1-2:27021"},
        {_id: 2, host: "shard1-3:27022"}
    ]
}) 
EOF

4. Инициализируем шард 2.

docker compose exec -T shard2-1 mongosh --port 27019 <<EOF
rs.initiate({
    _id: "rs2", 
    members: 
    [
        {_id: 0, host: "shard2-1:27019"},
        {_id: 1, host: "shard2-2:27023"},
        {_id: 2, host: "shard2-3:27024"}
    ]
}) 
EOF

5. Инициализируем роутер и наполняем его данными.

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard("rs1/shard1-1:27018")
sh.addShard("rs2/shard2-1:27019")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", {"name": "hashed"})

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
EOF

6. Проверка количества документов всего в базе.

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
db.helloDoc.countDocuments() 
EOF

(1000)

7. Проверка количества документов шардах.

docker compose exec -T shard1-1 mongosh --port 27018 <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

(492)

docker compose exec -T shard2-1 mongosh --port 27019 <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

(508)

8. Дополнительно проверим количество документов в репликах.

docker compose exec -T shard1-2 mongosh --port 27021 <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

(492)

docker compose exec -T shard2-3 mongosh --port 27024 <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

(508)

9. Проверяем.

http://localhost:8080

http://localhost:8080/helloDoc/users
Скорость загрузки данных менее 10мс.

==================================================================
