<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get all candidates
    $sql = "SELECT * FROM candidates WHERE is_active = 1 ORDER BY position, name";
    $result = $connection->query($sql);
    
    $candidates = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $candidates[] = $row;
        }
    }
    
    echo json_encode([
        'success' => true,
        'candidates' => $candidates
    ]);
} else if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Add new candidate (admin only)
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    $name = $_POST['name'] ?? '';
    $position = $_POST['position'] ?? '';
    $description = $_POST['description'] ?? '';
    $image_url = $_POST['image_url'] ?? '';
    
    if (empty($name) || empty($position)) {
        echo json_encode([
            'success' => false,
            'message' => 'Name and position are required'
        ]);
        exit();
    }
    
    $sql = "INSERT INTO candidates (name, position, description, image_url) VALUES (?, ?, ?, ?)";
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("ssss", $name, $position, $description, $image_url);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Candidate added successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error adding candidate: ' . $connection->error
        ]);
    }
    
    $stmt->close();
} else if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    // Update candidate (admin only)
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    parse_str(file_get_contents("php://input"), $put_data);
    $id = $put_data['id'] ?? '';
    $name = $put_data['name'] ?? '';
    $position = $put_data['position'] ?? '';
    $description = $put_data['description'] ?? '';
    $image_url = $put_data['image_url'] ?? '';
    
    if (empty($id) || empty($name) || empty($position)) {
        echo json_encode([
            'success' => false,
            'message' => 'ID, name and position are required'
        ]);
        exit();
    }
    
    $sql = "UPDATE candidates SET name = ?, position = ?, description = ?, image_url = ? WHERE id = ?";
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("ssssi", $name, $position, $description, $image_url, $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Candidate updated successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error updating candidate: ' . $connection->error
        ]);
    }
    
    $stmt->close();
} else if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // Delete candidate (admin only)
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    $id = $_GET['id'] ?? '';
    
    if (empty($id)) {
        echo json_encode([
            'success' => false,
            'message' => 'Candidate ID is required'
        ]);
        exit();
    }
    
    $sql = "UPDATE candidates SET is_active = 0 WHERE id = ?";
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Candidate deleted successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error deleting candidate: ' . $connection->error
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


