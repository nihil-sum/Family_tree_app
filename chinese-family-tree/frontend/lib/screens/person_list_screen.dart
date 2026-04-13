import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/person_provider.dart';
import '../models/person.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  String? _selectedFamilyName;
  String? _selectedGeneration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonProvider>().loadPersons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('族人列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
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

          var persons = provider.persons;

          // Apply filters
          if (_selectedFamilyName != null) {
            persons = persons.where((p) => p.familyName == _selectedFamilyName).toList();
          }
          if (_selectedGeneration != null) {
            persons = persons.where((p) => p.generationName == _selectedGeneration).toList();
          }

          if (persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有找到族人',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_selectedFamilyName != null || _selectedGeneration != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFamilyName = null;
                          _selectedGeneration = null;
                        });
                      },
                      child: const Text('清除筛选'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: persons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _PersonListItem(person: persons[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PersonFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<PersonProvider>();
    final familyNames = provider.getFamilyNames();
    final generations = provider.getGenerationNames();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              value: _selectedFamilyName,
              decoration: const InputDecoration(labelText: '姓氏'),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ...familyNames.map((name) => DropdownMenuItem(
                  value: name,
                  child: Text(name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFamilyName = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedGeneration,
              decoration: const InputDecoration(labelText: '字辈'),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ...generations.map((gen) => DropdownMenuItem(
                  value: gen,
                  child: Text(gen),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGeneration = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFamilyName = null;
                _selectedGeneration = null;
              });
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _PersonListItem extends StatelessWidget {
  final Person person;

  const _PersonListItem({required this.person});

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
        title: Text(
          person.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.generationName != null)
              Text('字辈：${person.generationName}'),
            Text([
              if (person.birthDate != null) '生于 ${person.birthDate}',
              if (person.birthPlace != null) person.birthPlace!,
            ].join(' · ')),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (person.isHeir)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('长子', style: TextStyle(fontSize: 12)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonDetailScreen(person: person),
            ),
          );
        },
        onLongPress: () {
          _showActionSheet(context, person);
        },
      ),
    );
  }

  void _showActionSheet(BuildContext context, Person person) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonFormScreen(person: person),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, person);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${person.displayName} 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PersonProvider>().deletePerson(person.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
