import 'package:flutter/material.dart';
import '../services/voting_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, dynamic> _results = {};
  Map<String, int> _totalVotes = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await VotingService.getResults();
      if (result['success']) {
        setState(() {
          _results = result['results'] ?? {};
          _totalVotes = Map<String, int>.from(result['total_votes'] ?? {});
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
        _errorMessage = 'Failed to load results: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f6f8),
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
                    onPressed: _loadResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFc72583),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Voting Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      IconButton(
                        onPressed: _loadResults,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh Results',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _results.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 64,
                                color: Color(0xFFCCCCCC),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No voting results yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Results will appear here once voting begins',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Summary Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Total Votes',
                                      _totalVotes.values
                                          .fold(0, (sum, count) => sum + count)
                                          .toString(),
                                      Icons.how_to_vote,
                                      const Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Positions',
                                      _results.length.toString(),
                                      Icons.work,
                                      const Color(0xFF2196F3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Results by Position
                              ..._results.keys.map(
                                (position) => _buildPositionResults(position),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionResults(String position) {
    final candidates = _results[position] as List<dynamic>? ?? [];
    final totalVotes = _totalVotes[position] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
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
                  position,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc72583).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalVotes votes',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFc72583),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No candidates for this position',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...candidates.map(
                (candidate) =>
                    _buildCandidateResult(candidate, totalVotes, position),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateResult(
    Map<String, dynamic> candidate,
    int totalVotes,
    String position,
  ) {
    final voteCount = candidate['vote_count'] as int? ?? 0;
    final percentage = totalVotes > 0 ? (voteCount / totalVotes * 100) : 0.0;
    final candidates = _results[position] as List<dynamic>? ?? [];
    final isWinner =
        voteCount > 0 &&
        voteCount ==
            (candidates
                .map((c) => c['vote_count'] as int? ?? 0)
                .reduce((a, b) => a > b ? a : b));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isWinner ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          width: isWinner ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isWinner
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isWinner
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFc72583),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWinner ? Icons.emoji_events : Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      candidate['candidate_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isWinner
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF333333),
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.emoji_events,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$voteCount votes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: totalVotes > 0 ? voteCount / totalVotes : 0,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinner ? const Color(0xFF4CAF50) : const Color(0xFFc72583),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
