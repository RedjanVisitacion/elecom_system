<?php 
// Disable error reporting to prevent HTML output
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

try {
    require 'lib/phpmailer/src/Exception.php';
    require 'lib/phpmailer/src/PHPMailer.php';
    require 'lib/phpmailer/src/SMTP.php';
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'PHPMailer files not found: ' . $e->getMessage()
    ]);
    exit;
}

try {
    if(isset($_POST["send"])){
        $mail = new PHPMailer(true);

        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'rpsvcodes@gmail.com';
        $mail->Password = 'tjzs vbre crtu xttp';
        $mail->SMTPSecure = 'ssl';
        $mail->Port = '465';

        $mail->setFrom('rpsvcodes@gmail.com');

        $mail->addAddress($_POST["email"]);

        $mail->isHTML(true);

        $mail->Subject = $_POST["subject"];
        $mail->Body = $_POST["message"];

        $mail->send();

        echo json_encode([
            'success' => true,
            'message' => 'Email sent successfully!'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid request'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error sending email: ' . $e->getMessage()
    ]);
}
?>