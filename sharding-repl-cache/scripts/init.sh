docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{ _id : 0, host : "configSrv:27017" }]
})
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
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

docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
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

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("rs1/shard1-1:27018")
sh.addShard("rs2/shard2-1:27019")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", {"name": "hashed"})

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
EOF


docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
db.helloDoc.countDocuments() 
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF


docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard1-2 mongosh --port 27021 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard2-3 mongosh --port 27024 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
