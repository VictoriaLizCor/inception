-- Ensure the root user has the correct password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;

-- Grant all privileges to root user from any host
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create the user if it doesn't exist and grant privileges
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
-- -- Grant all privileges to root user from any host
-- GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- FLUSH PRIVILEGES;

-- -- Create the database if it doesn't exist
-- CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- -- Create the user if it doesn't exist and grant privileges
-- CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
-- GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
-- FLUSH PRIVILEGES;

-- -- Ensure the root user has the correct password
-- ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- FLUSH PRIVILEGES;
-- ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- FLUSH PRIVILEGES;

-- -- Use the specified database
-- USE ${MYSQL_DATABASE};

-- -- Create the info table if it doesn't exist
-- CREATE TABLE IF NOT EXISTS info (
--     name VARCHAR(255),
--     level INT
-- );

-- -- Insert initial data into the info table
-- INSERT INTO info (name, level) VALUES ('${MYSQL_USER}', 6);

