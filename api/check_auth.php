<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (isset($_SESSION['is_login']) && $_SESSION['is_login'] == true) {
        echo json_encode([
            'success' => true,
            'message' => 'User is authenticated',
            'user' => [
                'id' => $_SESSION['user_id'],
                'username' => $_SESSION['user_username'],
                'firstname' => $_SESSION['user_firstname'],
                'lastname' => $_SESSION['user_lastname']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'User is not authenticated'
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}
?>
