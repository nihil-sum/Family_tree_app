import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/person_provider.dart';
import '../models/person.dart';
import 'person_detail_screen.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  String? _selectedFamilyName;
  double _zoomLevel = 1.0;

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
        title: const Text('家族树'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectFamily,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 2.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 2.0);
              });
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
          if (_selectedFamilyName != null) {
            persons = persons.where((p) => p.familyName == _selectedFamilyName).toList();
          }

          if (persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFamilyName == null 
                        ? '还没有族人' 
                        : '该姓氏没有族人',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_selectedFamilyName != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFamilyName = null;
                        });
                      },
                      child: const Text('清除筛选'),
                    ),
                  ],
                ],
              ),
            );
          }

          // Group by generation
          final generations = _groupByGeneration(persons);

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 2.0,
            scaleEnabled: true,
            panEnabled: true,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildFamilyTree(generations),
            ),
          );
        },
      ),
    );
  }

  Map<String?, List<Person>> _groupByGeneration(List<Person> persons) {
    final Map<String?, List<Person>> generations = {};
    for (var person in persons) {
      final gen = person.generationName;
      if (!generations.containsKey(gen)) {
        generations[gen] = [];
      }
      generations[gen]!.add(person);
    }
    return generations;
  }

  Widget _buildFamilyTree(Map<String?, List<Person>> generations) {
    final sortedGens = generations.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Generation labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sortedGens.map((gen) {
            return SizedBox(
              width: 150,
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    gen ?? '未知辈分',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Tree nodes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sortedGens.map((gen) {
            final persons = generations[gen]!;
            return _buildGenerationColumn(persons);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerationColumn(List<Person> persons) {
    return Column(
      children: persons.map((person) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _TreePersonCard(person: person),
        );
      }).toList(),
    );
  }

  void _selectFamily() {
    final provider = context.read<PersonProvider>();
    final familyNames = provider.getFamilyNames();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择姓氏'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: familyNames.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('全部'),
                  onTap: () {
                    setState(() {
                      _selectedFamilyName = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }
              final name = familyNames[index - 1];
              return ListTile(
                title: Text(name),
                onTap: () {
                  setState(() {
                    _selectedFamilyName = name;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _TreePersonCard extends StatelessWidget {
  final Person person;

  const _TreePersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonDetailScreen(person: person),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: person.gender == 'M' 
              ? Colors.blue[50] 
              : Colors.pink[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: person.gender == 'M' 
                ? Colors.blue 
                : Colors.pink,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              person.gender == 'M' ? Icons.male : Icons.female,
              size: 32,
              color: person.gender == 'M' ? Colors.blue : Colors.pink,
            ),
            const SizedBox(height: 8),
            Text(
              person.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (person.birthDate != null) ...[
              const SizedBox(height: 4),
              Text(
                person.birthDate!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (person.isHeir) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('长子', style: TextStyle(fontSize: 10)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
