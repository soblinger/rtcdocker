#!/bin/bash

ORACLE_USER=$1
USER_PASSWORD=$1

ORACLE_SID=XE
ORACLE_VERSION=11.2.0.2.0

ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
ORACLE_DATA=/u01/app/oracle/oradata/XE
PATH=$PATH:$ORACLE_HOME/bin

export ORACLE_SID
export ORACLE_HOME
export ORACLE_DATA
export ORACLE_USER
export USER_PASSWORD

if [ ! -d "$ORACLE_HOME" ]; then
	echo "Invalid ORACLE_HOME: $ORACLE_HOME"
	exit
fi

if [ ! -d "$ORACLE_DATA" ]; then
	echo "Instance does not exist: $ORACLE_SID"
	exit
fi

$ORACLE_HOME/bin/sqlplus sys/oracle as sysdba << EOF
CREATE BIGFILE TABLESPACE ${ORACLE_USER}_tbs DATAFILE '$ORACLE_DATA/${ORACLE_USER}_tbs.dbf' SIZE 1G AUTOEXTEND ON EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
CREATE TEMPORARY TABLESPACE ${ORACLE_USER}_tmp_tbs TEMPFILE '$ORACLE_DATA/${ORACLE_USER}_tmp_tbs.dbf' SIZE 20M AUTOEXTEND ON; 
CREATE USER $ORACLE_USER IDENTIFIED BY $USER_PASSWORD DEFAULT TABLESPACE ${ORACLE_USER}_tbs TEMPORARY TABLESPACE ${ORACLE_USER}_tmp_tbs;
GRANT CREATE SESSION TO $ORACLE_USER;
GRANT CREATE TABLE, ALTER ANY TABLE, DROP ANY TABLE, CREATE ANY INDEX, ALTER ANY INDEX, DROP ANY INDEX TO $ORACLE_USER;
GRANT INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO $ORACLE_USER;
GRANT CREATE PROCEDURE TO $ORACLE_USER;
GRANT CREATE VIEW TO $ORACLE_USER;
GRANT DBA TO $ORACLE_USER;
ALTER PROFILE DEFAULT LIMIT
  FAILED_LOGIN_ATTEMPTS UNLIMITED
      PASSWORD_LIFE_TIME UNLIMITED;

EOF

echo "Done"
