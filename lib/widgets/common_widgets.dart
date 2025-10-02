import 'package:flutter/material.dart';

import '../data/models.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.black26),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: 240,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.black54)),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class AgentCard extends StatelessWidget {
  const AgentCard({super.key, required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: agent.avatarUrl.trim().isEmpty
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .1)
                    : null,
                image: agent.avatarUrl.trim().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(agent.avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: agent.avatarUrl.trim().isEmpty
                  ? Icon(
                      Icons.person_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(agent.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (agent.isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(agent.company,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(agent.phone,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.mail_outline_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(agent.email,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.chat_rounded,
                  color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
