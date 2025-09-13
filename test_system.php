<?php
// Test script to verify the voting system functionality
error_reporting(0);
ini_set('display_errors', 0);

echo "=== VOTING SYSTEM TEST ===\n\n";

// Test 1: Login as admin
echo "1. Testing admin login...\n";
$login_data = http_build_query([
    'username' => 'admin',
    'password' => 'admin123'
]);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost/elecom_system/api/login.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $login_data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_COOKIEJAR, 'cookies.txt');
curl_setopt($ch, CURLOPT_COOKIEFILE, 'cookies.txt');

$response = curl_exec($ch);
$login_result = json_decode($response, true);
echo "Login result: " . ($login_result['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if (!$login_result['success']) {
    echo "Error: " . $login_result['message'] . "\n";
    exit;
}

// Test 2: Get users
echo "\n2. Testing get users...\n";
curl_setopt($ch, CURLOPT_URL, 'http://localhost/elecom_system/api/users.php');
curl_setopt($ch, CURLOPT_POST, false);
curl_setopt($ch, CURLOPT_POSTFIELDS, null);

$response = curl_exec($ch);
$users_result = json_decode($response, true);
echo "Get users result: " . ($users_result['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if ($users_result['success']) {
    echo "Found " . count($users_result['users']) . " users\n";
    foreach ($users_result['users'] as $user) {
        echo "- " . $user['firstname'] . " " . $user['lastname'] . " (" . $user['role'] . ") - " . ($user['has_voted'] ? 'VOTED' : 'NOT VOTED') . "\n";
    }
} else {
    echo "Error: " . $users_result['message'] . "\n";
}

// Test 3: Create a test user
echo "\n3. Testing create user...\n";
$create_data = http_build_query([
    'action' => 'create',
    'firstname' => 'Test',
    'lastname' => 'User',
    'username' => 'testuser',
    'email' => 'test@example.com',
    'password' => 'test123'
]);

curl_setopt($ch, CURLOPT_URL, 'http://localhost/elecom_system/api/users.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $create_data);

$response = curl_exec($ch);
$create_result = json_decode($response, true);
echo "Create user result: " . ($create_result['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if (!$create_result['success']) {
    echo "Error: " . $create_result['message'] . "\n";
}

// Test 4: Test voting with test user
echo "\n4. Testing voting with test user...\n";
// First login as test user
$test_login_data = http_build_query([
    'username' => 'testuser',
    'password' => 'test123'
]);

curl_setopt($ch, CURLOPT_URL, 'http://localhost/elecom_system/api/login.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $test_login_data);
curl_setopt($ch, CURLOPT_COOKIEJAR, 'test_cookies.txt');
curl_setopt($ch, CURLOPT_COOKIEFILE, 'test_cookies.txt');

$response = curl_exec($ch);
$test_login_result = json_decode($response, true);
echo "Test user login: " . ($test_login_result['success'] ? 'SUCCESS' : 'FAILED') . "\n";

if ($test_login_result['success']) {
    // Try to vote
    $vote_data = http_build_query([
        'candidate_id' => '1',
        'position' => 'President'
    ]);
    
    curl_setopt($ch, CURLOPT_URL, 'http://localhost/elecom_system/api/votes.php');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $vote_data);
    
    $response = curl_exec($ch);
    $vote_result = json_decode($response, true);
    echo "Vote result: " . ($vote_result['success'] ? 'SUCCESS' : 'FAILED') . "\n";
    if (!$vote_result['success']) {
        echo "Error: " . $vote_result['message'] . "\n";
    }
    
    // Try to vote again (should fail)
    echo "\n5. Testing duplicate vote prevention...\n";
    $response = curl_exec($ch);
    $vote_result2 = json_decode($response, true);
    echo "Duplicate vote result: " . ($vote_result2['success'] ? 'SUCCESS' : 'FAILED') . "\n";
    if (!$vote_result2['success']) {
        echo "Error: " . $vote_result2['message'] . "\n";
    }
}

curl_close($ch);

echo "\n=== TEST COMPLETE ===\n";
?>
