import 'http_service.dart';

class UserService {
  // Get all users
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      HttpService.initialize();
      final response = await HttpService.get('/users.php');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'],
          'users': data['users'] ?? [],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Create a new user (admin only)
  static Future<Map<String, dynamic>> createUser({
    required String firstname,
    required String lastname,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      HttpService.initialize();
      final response = await HttpService.post(
        '/users.php',
        data: {
          'action': 'create',
          'firstname': firstname,
          'lastname': lastname,
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Reset a specific user's votes
  static Future<Map<String, dynamic>> resetUserVotes(int userId) async {
    try {
      HttpService.initialize();
      final response = await HttpService.post(
        '/users.php',
        data: {
          'action': 'reset_user_votes',
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Reset all votes
  static Future<Map<String, dynamic>> resetAllVotes() async {
    try {
      HttpService.initialize();
      final response = await HttpService.post(
        '/users.php',
        data: {
          'action': 'reset_all_votes',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
