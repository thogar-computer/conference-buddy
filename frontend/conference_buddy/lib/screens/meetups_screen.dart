import 'package:flutter/material.dart';
import '../models/meetup.dart';
import '../services/meetup_service.dart';

class MeetupsScreen extends StatefulWidget {
  const MeetupsScreen({super.key});

  @override
  State<MeetupsScreen> createState() => _MeetupsScreenState();
}

class _MeetupsScreenState extends State<MeetupsScreen> {
  final MeetupService _meetupService = MeetupService();
  List<Meetup> _meetups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMeetups();
  }

  Future<void> _loadMeetups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final meetups = await _meetupService.getMeetups();
      setState(() {
        _meetups = meetups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _respondToMeetup(String meetupId, bool accept) async {
    try {
      final result = await _meetupService.respondToMeetup(meetupId, accept);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['meetsThreshold'] == true 
                  ? 'Meetup confirmed!' 
                  : accept 
                      ? 'You accepted. Waiting for others...' 
                      : 'You declined the meetup',
            ),
          ),
        );
        _loadMeetups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeetups,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeetups,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_meetups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No meetups yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a meetup from your conference page',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeetups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meetups.length,
        itemBuilder: (context, index) {
          final meetup = _meetups[index];
          return _MeetupCard(
            meetup: meetup,
            onAccept: () => _respondToMeetup(meetup.id, true),
            onDecline: () => _respondToMeetup(meetup.id, false),
          );
        },
      ),
    );
  }
}

class _MeetupCard extends StatelessWidget {
  final Meetup meetup;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _MeetupCard({
    required this.meetup,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(status: meetup.status),
                const Spacer(),
                Text(
                  meetup.conferenceName ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (meetup.venueName != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meetup.venueName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (meetup.venueAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  meetup.venueAddress!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
            const SizedBox(height: 12),
            if (meetup.participants != null) ...[
              const Text(
                'Participants:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: meetup.participants!.map((p) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: _getStatusColor(p.status),
                      child: Text(
                        p.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    label: Text(p.fullName),
                    backgroundColor: _getStatusColor(p.status).withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
            if (meetup.isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'creator':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}