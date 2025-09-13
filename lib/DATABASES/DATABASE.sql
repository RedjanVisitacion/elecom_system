CREATE DATABASE voting_system;

USE voting_system;

-- Users table with role support
CREATE TABLE users (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    firstname varchar(255) NOT NULL,
    lastname varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Candidates table
CREATE TABLE candidates (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL,
    position varchar(255) NOT NULL,
    description TEXT,
    image_url varchar(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Votes table
CREATE TABLE votes (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id int(12) NOT NULL,
    candidate_id int(12) NOT NULL,
    position varchar(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_position (user_id, position)
);

-- Positions table
CREATE TABLE positions (
    id int(12) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample positions
INSERT INTO positions (name, description) VALUES 
('President', 'Head of the organization'),
('Vice President', 'Assists the President'),
('Secretary', 'Handles documentation'),
('Treasurer', 'Manages finances');

-- Insert sample admin user
INSERT INTO users (username, password, firstname, lastname, email, role) VALUES 
('admin', MD5('admin123'), 'Admin', 'User', 'admin@voting.com', 'admin');

-- Insert sample regular user
INSERT INTO users (username, password, firstname, lastname, email, role) VALUES 
('user1', MD5('user123'), 'John', 'Doe', 'john@example.com', 'user');

-- Insert sample candidates
INSERT INTO candidates (name, position, description, image_url) VALUES 
('Alice Johnson', 'President', 'Experienced leader with 5 years in management', ''),
('Bob Smith', 'President', 'Innovative thinker with fresh ideas', ''),
('Carol Davis', 'Vice President', 'Strong supporter and team player', ''),
('David Wilson', 'Vice President', 'Detail-oriented and reliable', ''),
('Eva Brown', 'Secretary', 'Excellent organizational skills', ''),
('Frank Miller', 'Secretary', 'Tech-savvy and efficient', ''),
('Grace Lee', 'Treasurer', 'Financial expertise and integrity', ''),
('Henry Taylor', 'Treasurer', 'Accounting background and trustworthiness', '');