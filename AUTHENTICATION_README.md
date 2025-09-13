# Flutter Login-Logout System with PHP Backend

A complete authentication system converted from PHP to Flutter with a modern UI and secure backend.

## 🚀 Features

- **User Registration** - Create new accounts with validation
- **User Login** - Secure authentication with session management
- **User Dashboard** - Protected area for logged-in users
- **Email System** - Send emails from the dashboard
- **Session Management** - Persistent login sessions
- **Form Validation** - Client and server-side validation
- **Modern UI** - Beautiful Material Design interface
- **State Management** - Provider pattern for state management

## 📁 Project Structure

```
elecom_system/
├── lib/
│   ├── models/
│   │   ├── user.dart              # User data model
│   │   └── auth_response.dart     # API response model
│   ├── providers/
│   │   └── auth_provider.dart     # Authentication state management
│   ├── services/
│   │   └── auth_service.dart      # API service for authentication
│   ├── screens/
│   │   ├── login_screen.dart      # Login interface
│   │   ├── register_screen.dart   # Registration interface
│   │   ├── dashboard_screen.dart  # Main dashboard
│   │   └── email_form_screen.dart # Email sending form
│   └── main.dart                  # App entry point
├── api/
│   ├── initialize.php             # Database connection
│   ├── login.php                  # Login API endpoint
│   ├── register.php               # Registration API endpoint
│   ├── logout.php                 # Logout API endpoint
│   └── check_auth.php             # Authentication check endpoint
├── send.php                       # Email sending script
└── setup_database.php             # Database setup script
```

## 🛠️ Setup Instructions

### 1. Database Setup
1. Make sure XAMPP is running
2. Open `http://localhost/elecom_system/setup_database.php` in your browser
3. This will create the database and sample user

### 2. Flutter Dependencies
```bash
flutter pub get
```

### 3. Run the Application
```bash
flutter run
```

## 🔐 Default Login Credentials

- **Username:** admin
- **Password:** admin123

## 📱 App Flow

1. **Login Screen** - Users enter credentials
2. **Registration Screen** - New users can create accounts
3. **Dashboard** - Main interface for logged-in users
4. **Email Form** - Send emails from the dashboard
5. **Logout** - Secure session termination

## 🔧 API Endpoints

- `POST /api/login.php` - User login
- `POST /api/register.php` - User registration
- `POST /api/logout.php` - User logout
- `GET /api/check_auth.php` - Check authentication status

## 🎨 UI Features

- **Responsive Design** - Works on all screen sizes
- **Material Design 3** - Modern UI components
- **Form Validation** - Real-time input validation
- **Loading States** - Visual feedback during operations
- **Error Handling** - User-friendly error messages
- **Password Visibility** - Toggle password visibility
- **Navigation** - Smooth screen transitions

## 🔒 Security Features

- **Password Hashing** - MD5 encryption (can be upgraded to bcrypt)
- **Session Management** - Secure PHP sessions
- **Input Validation** - Both client and server-side
- **SQL Injection Protection** - Prepared statements
- **CORS Headers** - Cross-origin request handling

## 📧 Email System

The system includes a complete email sending functionality:
- Uses PHPMailer for reliable email delivery
- Gmail SMTP configuration
- HTML email support
- Error handling and validation

## 🚀 Getting Started

1. **Clone/Download** the project
2. **Setup XAMPP** and start Apache and MySQL
3. **Run database setup** script
4. **Install Flutter dependencies**
5. **Run the Flutter app**
6. **Login** with default credentials or register new account

## 🛡️ Security Notes

- Change default credentials in production
- Use HTTPS in production
- Consider upgrading to bcrypt for password hashing
- Implement rate limiting for API endpoints
- Add CSRF protection for forms

## 📝 Original PHP System

This Flutter app is a complete conversion of the original PHP login-logout system found in `lib/Login-Logout-PHP/` directory, featuring:
- Same database structure
- Same authentication logic
- Enhanced UI/UX
- Better error handling
- Mobile-first design

## 👨‍💻 By RPSV_CODES

A complete authentication system with modern Flutter UI and secure PHP backend.
