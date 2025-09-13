import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/candidate.dart';
import '../models/vote.dart';

class VotingService {
  static const String baseUrl = 'http://localhost/elecom_system/api';

  // Get all candidates
  static Future<Map<String, dynamic>> getCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/candidates.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final candidates = (data['candidates'] as List)
              .map((json) => Candidate.fromJson(json))
              .toList();
          return {'success': true, 'candidates': candidates};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to fetch candidates',
          };
        }
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

  // Submit a vote
  static Future<Map<String, dynamic>> submitVote({
    required int candidateId,
    required String position,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/votes.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'candidate_id': candidateId.toString(), 'position': position},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
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

  // Get user's votes
  static Future<Map<String, dynamic>> getUserVotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/votes.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final votes = (data['votes'] as List)
              .map((json) => Vote.fromJson(json))
              .toList();
          return {'success': true, 'votes': votes};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to fetch votes',
          };
        }
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

  // Get voting results (admin only)
  static Future<Map<String, dynamic>> getResults() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/results.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'results': data['results'] ?? {},
          'total_votes': data['total_votes'] ?? {},
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

  // Add candidate (admin only)
  static Future<Map<String, dynamic>> addCandidate({
    required String name,
    required String position,
    required String description,
    String imageUrl = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/candidates.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'position': position,
          'description': description,
          'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
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

  // Update candidate (admin only)
  static Future<Map<String, dynamic>> updateCandidate({
    required int id,
    required String name,
    required String position,
    required String description,
    String imageUrl = '',
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/candidates.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
          'name': name,
          'position': position,
          'description': description,
          'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
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

  // Delete candidate (admin only)
  static Future<Map<String, dynamic>> deleteCandidate(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/candidates.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
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

