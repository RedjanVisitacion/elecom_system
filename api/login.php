<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        echo json_encode([
            'success' => false,
            'message' => 'Username and password are required'
        ]);
        exit();
    }

    $encrypted_password = md5($password);
    $sql = "SELECT * FROM users WHERE username = ? AND password = ?";
    
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("ss", $username, $encrypted_password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $_SESSION['is_login'] = true;
        $_SESSION['user_id'] = $row['id'];
        $_SESSION['user_firstname'] = $row['firstname'];
        $_SESSION['user_lastname'] = $row['lastname'];
        $_SESSION['user_username'] = $row['username'];
        $_SESSION['user_role'] = $row['role'];
        $_SESSION['user_email'] = $row['email'];

        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $row['id'],
                'username' => $row['username'],
                'firstname' => $row['firstname'],
                'lastname' => $row['lastname'],
                'email' => $row['email'],
                'role' => $row['role']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Username and password not found'
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
