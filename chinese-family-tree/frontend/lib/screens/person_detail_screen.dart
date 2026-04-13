import 'package:flutter/material.dart';
import '../models/person.dart';
import 'person_form_screen.dart';

class PersonDetailScreen extends StatelessWidget {
  final Person person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonFormScreen(person: person),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(context),
            
            const SizedBox(height: 24),
            
            // Basic Info
            _buildSection(
              context,
              title: '基本信息',
              icon: Icons.person,
              children: [
                _InfoRow(label: '姓名', value: person.fullName),
                if (person.generationName != null)
                  _InfoRow(label: '字辈', value: person.generationName!),
                if (person.courtesyName != null)
                  _InfoRow(label: '字', value: person.courtesyName!),
                if (person.artName != null)
                  _InfoRow(label: '号', value: person.artName!),
                if (person.englishName != null)
                  _InfoRow(label: '英文名', value: person.englishName!),
                _InfoRow(label: '性别', value: person.genderChinese),
                if (person.isAdopted)
                  _InfoRow(label: '身份', value: '收养', valueColor: Colors.orange),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Life Dates
            _buildSection(
              context,
              title: '生卒信息',
              icon: Icons.calendar_today,
              children: [
                _InfoRow(
                  label: '出生日期',
                  value: person.birthDate ?? '未知',
                ),
                if (person.birthDateLunar != null)
                  _InfoRow(label: '农历生日', value: person.birthDateLunar!),
                if (person.birthPlace != null)
                  _InfoRow(label: '出生地', value: person.birthPlace!),
                if (person.isDeceased) ...[
                  _InfoRow(
                    label: '逝世日期',
                    value: person.deathDate ?? '未知',
                  ),
                  if (person.deathPlace != null)
                    _InfoRow(label: '逝世地', value: person.deathPlace!),
                  if (person.burialPlace != null)
                    _InfoRow(label: '墓地', value: person.burialPlace!),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Life Info
            if (person.occupation != null ||
                person.achievements != null ||
                person.biography != null)
              _buildSection(
                context,
                title: '生平信息',
                icon: Icons.menu_book,
                children: [
                  if (person.occupation != null)
                    _InfoRow(label: '职业', value: person.occupation!),
                  if (person.achievements != null)
                    _InfoRow(label: '成就', value: person.achievements!),
                ],
              ),
            
            if (person.biography != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '传记',
                icon: Icons.description,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      person.biography!,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: person.gender == 'M'
                  ? Colors.blue[100]
                  : Colors.pink[100],
              child: Icon(
                person.gender == 'M' ? Icons.male : Icons.female,
                size: 40,
                color: person.gender == 'M' ? Colors.blue : Colors.pink,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.familyName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (person.age != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('${person.age}岁'),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
