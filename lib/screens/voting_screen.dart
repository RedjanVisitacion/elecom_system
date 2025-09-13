import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/candidate.dart';
import '../services/voting_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  List<Candidate> _candidates = [];
  Map<String, int?> _selectedCandidates = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _showReview = false;
  bool _hasVoted = false;
  List<Map<String, dynamic>> _userVotes = [];

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    _checkExistingVotes();
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.logout();

    if (success && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Logout failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _areAllPositionsSelected() {
    final positions = _getPositions();
    return positions.every((position) => _selectedCandidates[position] != null);
  }

  void _toggleReview() {
    setState(() {
      _showReview = !_showReview;
    });
  }

  Future<void> _submitAllVotes() async {
    if (!_areAllPositionsSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select candidates for all positions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool allSuccessful = true;
      String? errorMessage;

      for (final entry in _selectedCandidates.entries) {
        final position = entry.key;
        final candidateId = entry.value!;

        final result = await VotingService.submitVote(
          candidateId: candidateId,
          position: position,
        );
        if (!result['success']) {
          allSuccessful = false;
          errorMessage = result['message'];
          break;
        }
      }

      if (allSuccessful && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votes submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to submit votes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting votes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await VotingService.getCandidates();
      if (result['success']) {
        setState(() {
          _candidates = result['candidates'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load candidates: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkExistingVotes() async {
    try {
      final result = await VotingService.getUserVotes();
      if (result['success']) {
        final votes = result['votes'] as List<dynamic>;
        setState(() {
          _userVotes = votes.cast<Map<String, dynamic>>();
          _hasVoted = votes.isNotEmpty;
        });
      }
    } catch (e) {
      // Silently handle error - user can still try to vote
      print('Error checking existing votes: $e');
    }
  }

  List<Candidate> _getCandidatesForPosition(String position) {
    return _candidates
        .where((candidate) => candidate.position == position)
        .toList();
  }

  List<String> _getPositions() {
    return _candidates.map((candidate) => candidate.position).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f6f8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFc72583),
        foregroundColor: Colors.white,
        title: const Text('Voting'),
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    authProvider.user?.firstname[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFFc72583)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.fullName ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authProvider.user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFc72583)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCandidates,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFc72583),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _hasVoted
          ? _buildAlreadyVotedView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cast Your Vote',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your preferred candidate for each position',
                    style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 24),

                  // Selection Progress
                  _buildProgressCard(),
                  const SizedBox(height: 16),

                  // Review Button (only show if all positions selected)
                  if (_areAllPositionsSelected()) _buildReviewButton(),

                  const SizedBox(height: 16),

                  // Review Section
                  if (_showReview) _buildReviewSection(),

                  const SizedBox(height: 16),

                  // Position Cards
                  ..._getPositions().map(
                    (position) => _buildPositionCard(position),
                  ),

                  const SizedBox(height: 24),

                  // Submit All Votes Button
                  if (_areAllPositionsSelected() && _showReview)
                    _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildPositionCard(String position) {
    final candidates = _getCandidatesForPosition(position);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              position,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            ...candidates.map(
              (candidate) => _buildCandidateTile(candidate, position),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateTile(Candidate candidate, String position) {
    final isSelected = _selectedCandidates[position] == candidate.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCandidates[position] = candidate.id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFc72583)
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? const Color(0xFFc72583).withOpacity(0.1)
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFc72583)
                      : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.person,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFc72583)
                            : const Color(0xFF333333),
                      ),
                    ),
                    if (candidate.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        candidate.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final positions = _getPositions();
    final selectedCount = _selectedCandidates.values
        .where((id) => id != null)
        .length;
    final progress = selectedCount / positions.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selection Progress',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  '$selectedCount / ${positions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : const Color(0xFFc72583),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress == 1.0
                  ? 'All positions selected! You can now review and submit your votes.'
                  : 'Select candidates for ${positions.length - selectedCount} more position${positions.length - selectedCount == 1 ? '' : 's'}.',
              style: TextStyle(
                fontSize: 12,
                color: progress == 1.0
                    ? Colors.green[700]
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: _showReview
              ? Colors.orange
              : const Color(0xFFc72583),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: Icon(_showReview ? Icons.edit : Icons.visibility),
        label: Text(
          _showReview ? 'Edit Selections' : 'Review Selections',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Review Your Selections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Please review your selections before submitting:',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            ..._selectedCandidates.entries.map(
              (entry) => _buildReviewItem(entry.key, entry.value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String position, int candidateId) {
    final candidate = _candidates.firstWhere((c) => c.id == candidateId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFe9ecef)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFc72583),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Ready to Submit Your Votes?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once submitted, you cannot change your votes.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitAllVotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.how_to_vote),
                label: Text(
                  _isSubmitting ? 'Submitting Votes...' : 'Submit All Votes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyVotedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green[600],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You Have Already Voted!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you for participating in the election. Your vote has been recorded.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Votes:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._userVotes.map((vote) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFc72583),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${vote['position']}: ${vote['candidate_name']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you believe there is an error with your vote or need assistance, please contact your administrator.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
