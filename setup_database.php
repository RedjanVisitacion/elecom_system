<?php
// Database setup script for the voting system
error_reporting(0); // Disable error reporting to prevent HTML output
ini_set('display_errors', 0);

$db_hostname = "localhost";
$db_username = "root";
$db_password = "";
$db_name = "voting_system";

// Create connection
$connection = new mysqli($db_hostname, $db_username, $db_password);

// Check connection
if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

// Create database
$sql = "CREATE DATABASE IF NOT EXISTS $db_name";
if ($connection->query($sql) === TRUE) {
    echo "Database created successfully or already exists\n";
} else {
    echo "Error creating database: " . $connection->error . "\n";
}

// Select database
$connection->select_db($db_name);

// Create users table with role support
$sql = "CREATE TABLE IF NOT EXISTS users (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    firstname varchar(255) NOT NULL,
    lastname varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)";

if ($connection->query($sql) === TRUE) {
    echo "Users table created successfully or already exists\n";
} else {
    echo "Error creating users table: " . $connection->error . "\n";
}

// Create candidates table
$sql = "CREATE TABLE IF NOT EXISTS candidates (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL,
    position varchar(255) NOT NULL,
    description TEXT,
    image_url varchar(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)";

if ($connection->query($sql) === TRUE) {
    echo "Candidates table created successfully or already exists\n";
} else {
    echo "Error creating candidates table: " . $connection->error . "\n";
}

// Create votes table
$sql = "CREATE TABLE IF NOT EXISTS votes (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id int(12) NOT NULL,
    candidate_id int(12) NOT NULL,
    position varchar(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_position (user_id, position)
)";

if ($connection->query($sql) === TRUE) {
    echo "Votes table created successfully or already exists\n";
} else {
    echo "Error creating votes table: " . $connection->error . "\n";
}

// Create positions table
$sql = "CREATE TABLE IF NOT EXISTS positions (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($connection->query($sql) === TRUE) {
    echo "Positions table created successfully or already exists\n";
} else {
    echo "Error creating positions table: " . $connection->error . "\n";
}

// Insert sample positions
$positions = [
    ['President', 'Head of the organization'],
    ['Vice President', 'Assists the President'],
    ['Secretary', 'Handles documentation'],
    ['Treasurer', 'Manages finances']
];

foreach ($positions as $position) {
    $sql = "INSERT IGNORE INTO positions (name, description) VALUES (?, ?)";
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("ss", $position[0], $position[1]);
    $stmt->execute();
}
$stmt->close();

// Insert sample admin user
$username = "admin";
$password = md5("admin123");
$firstname = "Admin";
$lastname = "User";
$email = "admin@voting.com";

$sql = "INSERT IGNORE INTO users (username, password, firstname, lastname, email, role) VALUES (?, ?, ?, ?, ?, 'admin')";
$stmt = $connection->prepare($sql);
if ($stmt) {
    $stmt->bind_param("sssss", $username, $password, $firstname, $lastname, $email);
    $stmt->execute();
    $stmt->close();
} else {
    echo "Error preparing statement: " . $connection->error . "<br>";
}

// Insert sample regular user
$username = "user1";
$password = md5("user123");
$firstname = "John";
$lastname = "Doe";
$email = "john@example.com";

$sql = "INSERT IGNORE INTO users (username, password, firstname, lastname, email, role) VALUES (?, ?, ?, ?, ?, 'user')";
$stmt = $connection->prepare($sql);
if ($stmt) {
    $stmt->bind_param("sssss", $username, $password, $firstname, $lastname, $email);
    $stmt->execute();
    $stmt->close();
} else {
    echo "Error preparing statement: " . $connection->error . "<br>";
}

// Insert sample candidates
$candidates = [
    ['Alice Johnson', 'President', 'Experienced leader with 5 years in management', ''],
    ['Bob Smith', 'President', 'Innovative thinker with fresh ideas', ''],
    ['Carol Davis', 'Vice President', 'Strong supporter and team player', ''],
    ['David Wilson', 'Vice President', 'Detail-oriented and reliable', ''],
    ['Eva Brown', 'Secretary', 'Excellent organizational skills', ''],
    ['Frank Miller', 'Secretary', 'Tech-savvy and efficient', ''],
    ['Grace Lee', 'Treasurer', 'Financial expertise and integrity', ''],
    ['Henry Taylor', 'Treasurer', 'Accounting background and trustworthiness', '']
];

foreach ($candidates as $candidate) {
    $sql = "INSERT IGNORE INTO candidates (name, position, description, image_url) VALUES (?, ?, ?, ?)";
    $stmt = $connection->prepare($sql);
    if ($stmt) {
        $stmt->bind_param("ssss", $candidate[0], $candidate[1], $candidate[2], $candidate[3]);
        $stmt->execute();
        $stmt->close();
    } else {
        echo "Error preparing statement: " . $connection->error . "\n";
    }
}

$connection->close();

echo "\n=== Voting System Database setup completed! ===\n";
echo "\nSample Admin Login:\n";
echo "Username: admin\n";
echo "Password: admin123\n";
echo "\nSample User Login:\n";
echo "Username: user1\n";
echo "Password: user123\n";
echo "\nGo to Flutter App: http://localhost/elecom_system/\n";
?>
