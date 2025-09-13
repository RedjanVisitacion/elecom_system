<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $firstname = $_POST['firstname'] ?? '';
    $lastname = $_POST['lastname'] ?? '';
    $username = $_POST['username'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $confirm_password = $_POST['confirm_password'] ?? '';

    // Validation
    if (empty($firstname)) {
        echo json_encode([
            'success' => false,
            'message' => 'Firstname is required'
        ]);
        exit();
    }
    
    if (empty($lastname)) {
        echo json_encode([
            'success' => false,
            'message' => 'Lastname is required'
        ]);
        exit();
    }
    
    if (empty($username)) {
        echo json_encode([
            'success' => false,
            'message' => 'Username is required'
        ]);
        exit();
    }
    
    if (empty($email)) {
        echo json_encode([
            'success' => false,
            'message' => 'Email is required'
        ]);
        exit();
    }
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email format'
        ]);
        exit();
    }
    
    if (empty($password)) {
        echo json_encode([
            'success' => false,
            'message' => 'Password is required'
        ]);
        exit();
    }
    
    if (empty($confirm_password)) {
        echo json_encode([
            'success' => false,
            'message' => 'Confirm Password is required'
        ]);
        exit();
    }
    
    if ($password !== $confirm_password) {
        echo json_encode([
            'success' => false,
            'message' => 'Password and Confirm Password do not match'
        ]);
        exit();
    }

    // Check if username or email already exists
    $check_sql = "SELECT id FROM users WHERE username = ? OR email = ?";
    $check_stmt = $connection->prepare($check_sql);
    $check_stmt->bind_param("ss", $username, $email);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Username or email already exists'
        ]);
        $check_stmt->close();
        exit();
    }
    $check_stmt->close();

    // Insert new user
    $encrypted_password = md5($password);
    $sql = "INSERT INTO users (firstname, lastname, username, email, password) VALUES (?, ?, ?, ?, ?)";
    
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("sssss", $firstname, $lastname, $username, $email, $encrypted_password);

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Account successfully created!'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error creating account: ' . $connection->error
        ]);
    }
    
    $stmt->close();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

$connection->close();
?>
