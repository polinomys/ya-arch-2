Задание 2. Шардирование.

0. Схема draw.io лежит в корне. 

1. Модифицировал файл compose.yaml в соответствии с условием.

2. Провел инициализацию сервера конфигурации, роутера и шардов.

3. Наполнил данными роутер.

4. Проверил количество данных на шардах.

5. Страница по адресу браузере http://localhost:8080 открывается.

==================================================================

Скрипты для проверки.

1. Запускаем.

docker compose up -d

2. Инициализируем сервер конфигурации.

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

3. Инициализируем шард 1.

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" }
      ]
    }
);
EOF

4. Инициализируем шард 2.

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27019" }
      ]
    }
);
EOF

5. Инициализируем роутер и наполняем его данными.

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

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

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments();
EOF

(492)

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments();
EOF

(508)

8. Проверяем 
http://localhost:8080
http://localhost:8080/helloDoc/users

==================================================================
