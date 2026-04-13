import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/person_provider.dart';
import '../models/person.dart';
import '../models/marriage.dart';
import 'person_detail_screen.dart';

class MarriageManagementScreen extends StatefulWidget {
  const MarriageManagementScreen({super.key});

  @override
  State<MarriageManagementScreen> createState() => _MarriageManagementScreenState();
}

class _MarriageManagementScreenState extends State<MarriageManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonProvider>().loadMarriages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('婚姻管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PersonProvider>().loadMarriages();
            },
          ),
        ],
      ),
      body: Consumer<PersonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.marriages.isEmpty) {
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
                      provider.loadMarriages();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.marriages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有婚姻记录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击下方按钮添加第一条婚姻记录',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMarriages(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.marriages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final marriage = provider.marriages[index];
                return _MarriageCard(
                  marriage: marriage,
                  persons: provider.persons,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MarriageFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MarriageCard extends StatelessWidget {
  final Marriage marriage;
  final List<Person> persons;

  const _MarriageCard({
    required this.marriage,
    required this.persons,
  });

  @override
  Widget build(BuildContext context) {
    final husband = persons.firstWhere(
      (p) => p.id == marriage.husbandId,
      orElse: () => Person(
        id: -1,
        uuid: '',
        familyName: 'Unknown',
        givenName: 'Husband',
        gender: 'M',
      ),
    );

    final wife = persons.firstWhere(
      (p) => p.id == marriage.wifeId,
      orElse: () => Person(
        id: -1,
        uuid: '',
        familyName: 'Unknown',
        givenName: 'Wife',
        gender: 'F',
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.male,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              husband.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            husband.familyName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: Colors.pink),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              wife.displayName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.pink[100],
                            child: Icon(
                              Icons.female,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            wife.familyName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.person, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('婚姻类型: ${marriage.typeChinese}'),
                      if (marriage.marriageDate != null)
                        Text('结婚日期: ${marriage.marriageDate}'),
                      if (marriage.marriagePlace != null)
                        Text('结婚地点: ${marriage.marriagePlace}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarriageFormScreen extends StatefulWidget {
  const MarriageFormScreen({super.key});

  @override
  State<MarriageFormScreen> createState() => _MarriageFormScreenState();
}

class _MarriageFormScreenState extends State<MarriageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _husbandIdController = TextEditingController();
  final _wifeIdController = TextEditingController();
  final _marriageDateController = TextEditingController();
  final _marriagePlaceController = TextEditingController();
  String _marriageType = 'primary';

  @override
  void dispose() {
    _husbandIdController.dispose();
    _wifeIdController.dispose();
    _marriageDateController.dispose();
    _marriagePlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加婚姻'),
      ),
      body: Consumer<PersonProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Husband Selection
                const Text('丈夫', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: '选择丈夫',
                    border: OutlineInputBorder(),
                  ),
                  value: _husbandIdController.text.isEmpty ? null : int.tryParse(_husbandIdController.text),
                  items: provider.persons
                      .where((person) => person.gender == 'M')
                      .map((person) => DropdownMenuItem(
                            value: person.id,
                            child: Text(person.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _husbandIdController.text = value.toString();
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return '请选择丈夫';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Wife Selection
                const Text('妻子', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: '选择妻子',
                    border: OutlineInputBorder(),
                  ),
                  value: _wifeIdController.text.isEmpty ? null : int.tryParse(_wifeIdController.text),
                  items: provider.persons
                      .where((person) => person.gender == 'F')
                      .map((person) => DropdownMenuItem(
                            value: person.id,
                            child: Text(person.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _wifeIdController.text = value.toString();
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return '请选择妻子';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Marriage Type
                const Text('婚姻类型', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'primary',
                      label: Text('正室'),
                    ),
                    ButtonSegment(
                      value: 'secondary',
                      label: Text('侧室'),
                    ),
                    ButtonSegment(
                      value: 'concubine',
                      label: Text('妾'),
                    ),
                  ],
                  selected: {_marriageType},
                  onSelectionChanged: (values) {
                    setState(() {
                      _marriageType = values.first;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Marriage Date
                const Text('结婚日期', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _marriageDateController,
                  decoration: const InputDecoration(
                    labelText: 'YYYY-MM-DD',
                    hintText: '例如: 1990-05-15',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1800),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _marriageDateController.text = 
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Marriage Place
                const Text('结婚地点', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _marriagePlaceController,
                  decoration: const InputDecoration(
                    labelText: '地点',
                    hintText: '例如: 北京市朝阳区',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('添加婚姻'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final marriage = Marriage(
      uuid: '', // Will be generated by backend
      husbandId: int.parse(_husbandIdController.text),
      wifeId: int.parse(_wifeIdController.text),
      marriageDate: _marriageDateController.text.isEmpty ? null : _marriageDateController.text,
      marriagePlace: _marriagePlaceController.text.isEmpty ? null : _marriagePlaceController.text,
      marriageType: _marriageType,
    );

    final provider = context.read<PersonProvider>();
    final success = await provider.createMarriage(marriage);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('婚姻记录添加成功')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('添加失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}