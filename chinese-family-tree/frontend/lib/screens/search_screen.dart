import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/person_provider.dart';
import '../models/person.dart';
import 'person_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Person> _searchResults = [];
  bool _isSearching = false;
  String? _searchType; // 'name', 'generation', 'family'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索姓名、字辈...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    _performSearch(value);
                  },
                ),
                const SizedBox(height: 12),
                // Search Type Filter
                Row(
                  children: [
                    const Text('搜索范围:'),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('全部'),
                      selected: _searchType == null,
                      onSelected: (selected) {
                        setState(() {
                          _searchType = null;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('姓名'),
                      selected: _searchType == 'name',
                      onSelected: (selected) {
                        setState(() {
                          _searchType = selected ? 'name' : null;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('字辈'),
                      selected: _searchType == 'generation',
                      onSelected: (selected) {
                        setState(() {
                          _searchType = selected ? 'generation' : null;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('姓氏'),
                      selected: _searchType == 'family',
                      onSelected: (selected) {
                        setState(() {
                          _searchType = selected ? 'family' : null;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<PersonProvider>(
              builder: (context, provider, child) {
                if (_isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '没有找到匹配的族人',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '输入关键词搜索族人',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '可以搜索姓名、字辈、姓氏等',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _SearchResultCard(person: _searchResults[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final provider = context.read<PersonProvider>();
    List<Person> results;

    try {
      if (_searchType == 'generation') {
        results = await provider.getByGenerationName(query);
      } else if (_searchType == 'family') {
        results = await provider.getByFamilyName(query);
      } else {
        results = await provider.searchPersons(query);
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败：$e')),
        );
      }
    }
  }
}

class _SearchResultCard extends StatelessWidget {
  final Person person;

  const _SearchResultCard({required this.person});

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
