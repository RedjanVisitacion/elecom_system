<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Check if user is admin
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'create':
            _createUser();
            break;
        case 'reset_user_votes':
            _resetUserVotes();
            break;
        case 'reset_all_votes':
            _resetAllVotes();
            break;
        default:
            echo json_encode([
                'success' => false,
                'message' => 'Invalid action'
            ]);
    }
} else if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get all users
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    _getUsers();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

function _createUser() {
    global $connection;
    
    $firstname = $_POST['firstname'] ?? '';
    $lastname = $_POST['lastname'] ?? '';
    $username = $_POST['username'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    // Validation
    if (empty($firstname) || empty($lastname) || empty($username) || empty($email) || empty($password)) {
        echo json_encode([
            'success' => false,
            'message' => 'All fields are required'
        ]);
        return;
    }
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email format'
        ]);
        return;
    }
    
    if (strlen($password) < 6) {
        echo json_encode([
            'success' => false,
            'message' => 'Password must be at least 6 characters'
        ]);
        return;
    }
    
    // Check if username or email already exists
    $check_sql = "SELECT id FROM users WHERE username = ? OR email = ?";
    $check_stmt = $connection->prepare($check_sql);
    if (!$check_stmt) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $connection->error
        ]);
        return;
    }
    
    $check_stmt->bind_param("ss", $username, $email);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Username or email already exists'
        ]);
        $check_stmt->close();
        return;
    }
    $check_stmt->close();
    
    // Create user
    $encrypted_password = md5($password);
    $sql = "INSERT INTO users (firstname, lastname, username, email, password, role) VALUES (?, ?, ?, ?, ?, 'user')";
    $stmt = $connection->prepare($sql);
    if (!$stmt) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $connection->error
        ]);
        return;
    }
    
    $stmt->bind_param("sssss", $firstname, $lastname, $username, $email, $encrypted_password);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'User created successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error creating user: ' . $connection->error
        ]);
    }
    
    $stmt->close();
}

function _resetUserVotes() {
    global $connection;
    
    $user_id = $_POST['user_id'] ?? '';
    
    if (empty($user_id)) {
        echo json_encode([
            'success' => false,
            'message' => 'User ID is required'
        ]);
        return;
    }
    
    $sql = "DELETE FROM votes WHERE user_id = ?";
    $stmt = $connection->prepare($sql);
    if (!$stmt) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $connection->error
        ]);
        return;
    }
    
    $stmt->bind_param("i", $user_id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'User votes reset successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error resetting votes: ' . $connection->error
        ]);
    }
    
    $stmt->close();
}

function _resetAllVotes() {
    global $connection;
    
    $sql = "DELETE FROM votes";
    $stmt = $connection->prepare($sql);
    if (!$stmt) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $connection->error
        ]);
        return;
    }
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'All votes reset successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error resetting votes: ' . $connection->error
        ]);
    }
    
    $stmt->close();
}

function _getUsers() {
    global $connection;
    
    $sql = "SELECT u.*, 
            CASE WHEN v.user_id IS NOT NULL THEN 1 ELSE 0 END as has_voted
            FROM users u 
            LEFT JOIN votes v ON u.id = v.user_id 
            ORDER BY u.role DESC, u.firstname ASC";
    
    $stmt = $connection->prepare($sql);
    if (!$stmt) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $connection->error
        ]);
        return;
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $users = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
    }
    
    echo json_encode([
        'success' => true,
        'users' => $users
    ]);
    
    $stmt->close();
}

$connection->close();
?>
