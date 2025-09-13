<?php
// Database setup script for the authentication system
$db_hostname = "localhost";
$db_username = "root";
$db_password = "";
$db_name = "sample_db";

// Create connection
$connection = new mysqli($db_hostname, $db_username, $db_password);

// Check connection
if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

// Create database
$sql = "CREATE DATABASE IF NOT EXISTS $db_name";
if ($connection->query($sql) === TRUE) {
    echo "Database created successfully or already exists<br>";
} else {
    echo "Error creating database: " . $connection->error . "<br>";
}

// Select database
$connection->select_db($db_name);

// Create users table
$sql = "CREATE TABLE IF NOT EXISTS users (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    firstname varchar(255) NOT NULL,
    lastname varchar(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($connection->query($sql) === TRUE) {
    echo "Users table created successfully or already exists<br>";
} else {
    echo "Error creating table: " . $connection->error . "<br>";
}

// Insert sample user for testing
$username = "admin";
$password = md5("admin123");
$firstname = "Admin";
$lastname = "User";

$sql = "INSERT IGNORE INTO users (username, password, firstname, lastname) VALUES ('$username', '$password', '$firstname', '$lastname')";

if ($connection->query($sql) === TRUE) {
    echo "Sample user created successfully or already exists<br>";
} else {
    echo "Error creating sample user: " . $connection->error . "<br>";
}

$connection->close();

echo "<br><strong>Database setup completed!</strong><br>";
echo "Sample login credentials:<br>";
echo "Username: admin<br>";
echo "Password: admin123<br>";
echo "<br><a href='http://localhost/elecom_system/'>Go to Flutter App</a>";
?>
