USE mysql;
FLUSH PRIVILEGES;

-- remove anonymous user
DELETE FROM mysql.user WHERE User='';
-- Disable remote root access
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
ALTER USER 'mysql'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
FLUSH PRIVILEGES;

-- Create database and user
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;

-- Use the specified database
USE ${MYSQL_DATABASE};

-- Create the info table if it doesn't exist
CREATE TABLE IF NOT EXISTS info (
    name VARCHAR(255),
    level INT
);

-- Insert initial data into the info table
INSERT INTO info (name, level) VALUES ('${MYSQL_USER}', 6);
