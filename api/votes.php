<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Submit vote
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true) {
        echo json_encode([
            'success' => false,
            'message' => 'Please login to vote'
        ]);
        exit();
    }
    
    $candidate_id = $_POST['candidate_id'] ?? '';
    $position = $_POST['position'] ?? '';
    $user_id = $_SESSION['user_id'];
    
    if (empty($candidate_id) || empty($position)) {
        echo json_encode([
            'success' => false,
            'message' => 'Candidate ID and position are required'
        ]);
        exit();
    }
    
    // Check if user already voted for this position
    $check_sql = "SELECT id FROM votes WHERE user_id = ? AND position = ?";
    $check_stmt = $connection->prepare($check_sql);
    $check_stmt->bind_param("is", $user_id, $position);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'You have already voted for this position'
        ]);
        $check_stmt->close();
        exit();
    }
    $check_stmt->close();
    
    // Insert vote
    $sql = "INSERT INTO votes (user_id, candidate_id, position) VALUES (?, ?, ?)";
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("iis", $user_id, $candidate_id, $position);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Vote submitted successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error submitting vote: ' . $connection->error
        ]);
    }
    
    $stmt->close();
} else if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get user's votes
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true) {
        echo json_encode([
            'success' => false,
            'message' => 'Please login to view votes'
        ]);
        exit();
    }
    
    $user_id = $_SESSION['user_id'];
    $sql = "SELECT v.*, c.name as candidate_name, c.position 
            FROM votes v 
            JOIN candidates c ON v.candidate_id = c.id 
            WHERE v.user_id = ? 
            ORDER BY v.created_at DESC";
    
    $stmt = $connection->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $votes = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $votes[] = $row;
        }
    }
    
    echo json_encode([
        'success' => true,
        'votes' => $votes
    ]);
    
    $stmt->close();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

$connection->close();
?>


