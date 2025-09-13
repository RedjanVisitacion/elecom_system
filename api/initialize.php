<?php
session_start();

$db_hostname = "localhost";
$db_username = "root";
$db_password = "";
$db_name = "sample_db";

$connection = new mysqli($db_hostname, $db_username, $db_password, $db_name);

if($connection->connect_error){
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $connection->connect_error
    ]));
}

// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
