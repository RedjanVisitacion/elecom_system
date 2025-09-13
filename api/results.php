<?php
include 'initialize.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get voting results (admin only)
    if (!isset($_SESSION['is_login']) || $_SESSION['is_login'] != true || $_SESSION['user_role'] != 'admin') {
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required'
        ]);
        exit();
    }
    
    // Get results grouped by position
    $sql = "SELECT 
                c.position,
                c.name as candidate_name,
                c.id as candidate_id,
                COUNT(v.id) as vote_count
            FROM candidates c
            LEFT JOIN votes v ON c.id = v.candidate_id
            WHERE c.is_active = 1
            GROUP BY c.position, c.id, c.name
            ORDER BY c.position, vote_count DESC";
    
    $result = $connection->query($sql);
    
    $results = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $position = $row['position'];
            if (!isset($results[$position])) {
                $results[$position] = [];
            }
            $results[$position][] = $row;
        }
    }
    
    // Get total votes per position
    $total_sql = "SELECT 
                    position,
                    COUNT(*) as total_votes
                  FROM votes 
                  GROUP BY position";
    
    $total_result = $connection->query($total_sql);
    $total_votes = [];
    if ($total_result->num_rows > 0) {
        while ($row = $total_result->fetch_assoc()) {
            $total_votes[$row['position']] = $row['total_votes'];
        }
    }
    
    echo json_encode([
        'success' => true,
        'results' => $results,
        'total_votes' => $total_votes
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

$connection->close();
?>


