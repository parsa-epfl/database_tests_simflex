#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Wrong use. Command no_warehouses no_steps"
    exit 1
fi
echo -e "[mysqld]\nmax_connections=10000\nmax_prepared_stmt_count=100000\n" >> /etc/mysql/my.cnf
service mysql start
mysqladmin create tpcc1000
mysql tpcc1000 < create_table.sql

mysql tpcc1000 < add_fkey_idx.sql
mysql --execute "set global max_connections = 10000;"
mysql --execute "set global max_prepared_stmt_count = 1000000;"
./load.sh tpcc1000 $1 $2
#tpcc_load -h127.0.0.1 -d tpcc1000 -u root -p "" -w 2
bash
