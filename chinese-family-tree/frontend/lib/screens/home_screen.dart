import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/person_provider.dart';
import '../models/person.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('家谱', style: TextStyle(fontSize: 20)),
            Text('Chinese Family Tree', style: TextStyle(fontSize: 12, height: 0.7)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PersonProvider>().loadPersons();
            },
          ),
        ],
      ),
      body: Consumer<PersonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.persons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadPersons();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPersons(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  _buildStatsCard(context, provider),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Persons
                  Text(
                    '最近添加',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  if (provider.persons.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildRecentPersons(context, provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonFormScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('添加族人'),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, PersonProvider provider) {
    final persons = provider.persons;
    final maleCount = persons.where((p) => p.gender == 'M').length;
    final femaleCount = persons.where((p) => p.gender == 'F').length;
    final familyNames = provider.getFamilyNames();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '家族统计',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.people,
                    label: '总人数',
                    value: persons.length.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.male,
                    label: '男性',
                    value: maleCount.toString(),
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.female,
                    label: '女性',
                    value: femaleCount.toString(),
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.family_restroom,
                    label: '姓氏',
                    value: familyNames.length.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '还没有族人',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮添加第一位族人',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPersons(BuildContext context, PersonProvider provider) {
    final recent = provider.persons.take(5).toList();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final person = recent[index];
        return _PersonCard(person: person);
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: person.gender == 'M' 
              ? Colors.blue[100] 
              : Colors.pink[100],
          child: Icon(
            person.gender == 'M' ? Icons.male : Icons.female,
            color: person.gender == 'M' ? Colors.blue : Colors.pink,
          ),
        ),
        title: Text(person.displayName),
        subtitle: Text([
          if (person.birthDate != null) '生于 ${person.birthDate}',
          if (person.birthPlace != null) person.birthPlace!,
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonDetailScreen(person: person),
            ),
          );
        },
      ),
    );
  }
}
