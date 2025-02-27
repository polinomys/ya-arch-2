Добавлены 4 директории в корень:
- "mongo-sharding" - внутри измененый в соответствии с условиями compose.yaml и readme.md (задание 2);
- "mongo-sharding-repl" - аналогично (задание 3);
- "sharding-repl-cache" - аналигично, финальный вариант (задание 4);
- "Scheme_screen" - схемы draw.io (все задания, 2-6) и скрины в формате jpg (финальная схема после задания 6 и скрин из браузера после задания 4).

Прилагаю скрипт для инициации: sharding-repl-cache\scripts\init.sh

Т.о. для проверки заданий 2,3,4:

1) запустить в директории sharding-repl-cache
    docker compose up -d
2) запустить
    sharding-repl-cache\scripts\init.sh
3) http://localhost:8080/
