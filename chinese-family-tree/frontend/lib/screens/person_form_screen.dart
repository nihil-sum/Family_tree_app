import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/person.dart';
import '../services/person_provider.dart';

class PersonFormScreen extends StatefulWidget {
  final Person? person;

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _familyNameController;
  late TextEditingController _givenNameController;
  late TextEditingController _generationNameController;
  late TextEditingController _courtesyNameController;
  late TextEditingController _artNameController;
  late TextEditingController _englishNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _birthDateLunarController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _deathDateController;
  late TextEditingController _deathPlaceController;
  late TextEditingController _burialPlaceController;
  late TextEditingController _occupationController;
  late TextEditingController _achievementsController;
  late TextEditingController _biographyController;

  String _gender = 'M';
  bool _isDeceased = false;
  bool _isAdopted = false;

  bool get isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    _familyNameController = TextEditingController(text: widget.person?.familyName ?? '');
    _givenNameController = TextEditingController(text: widget.person?.givenName ?? '');
    _generationNameController = TextEditingController(text: widget.person?.generationName ?? '');
    _courtesyNameController = TextEditingController(text: widget.person?.courtesyName ?? '');
    _artNameController = TextEditingController(text: widget.person?.artName ?? '');
    _englishNameController = TextEditingController(text: widget.person?.englishName ?? '');
    _birthDateController = TextEditingController(text: widget.person?.birthDate ?? '');
    _birthDateLunarController = TextEditingController(text: widget.person?.birthDateLunar ?? '');
    _birthPlaceController = TextEditingController(text: widget.person?.birthPlace ?? '');
    _deathDateController = TextEditingController(text: widget.person?.deathDate ?? '');
    _deathPlaceController = TextEditingController(text: widget.person?.deathPlace ?? '');
    _burialPlaceController = TextEditingController(text: widget.person?.burialPlace ?? '');
    _occupationController = TextEditingController(text: widget.person?.occupation ?? '');
    _achievementsController = TextEditingController(text: widget.person?.achievements ?? '');
    _biographyController = TextEditingController(text: widget.person?.biography ?? '');
    _gender = widget.person?.gender ?? 'M';
    _isDeceased = widget.person?.isDeceased ?? false;
    _isAdopted = widget.person?.isAdopted ?? false;
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _givenNameController.dispose();
    _generationNameController.dispose();
    _courtesyNameController.dispose();
    _artNameController.dispose();
    _englishNameController.dispose();
    _birthDateController.dispose();
    _birthDateLunarController.dispose();
    _birthPlaceController.dispose();
    _deathDateController.dispose();
    _deathPlaceController.dispose();
    _burialPlaceController.dispose();
    _occupationController.dispose();
    _achievementsController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑族人' : '添加族人'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Section
            _buildSectionTitle('姓名'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _familyNameController,
                      decoration: const InputDecoration(
                        labelText: '姓 *',
                        hintText: '李',
                        prefixIcon: Icon(Icons.family_restroom),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入姓氏';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _givenNameController,
                      decoration: const InputDecoration(
                        labelText: '名 *',
                        hintText: '明',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入名字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _generationNameController,
                      decoration: const InputDecoration(
                        labelText: '字辈',
                        hintText: '光',
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _courtesyNameController,
                      decoration: const InputDecoration(
                        labelText: '字',
                        hintText: '子明',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _artNameController,
                      decoration: const InputDecoration(
                        labelText: '号',
                        hintText: '青莲居士',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _englishNameController,
                      decoration: const InputDecoration(
                        labelText: '英文名',
                        hintText: 'Michael Li',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Gender & Status
            _buildSectionTitle('基本信息'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('性别', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'M',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() => _gender = value!);
                              },
                            ),
                            const Text('男'),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: 'F',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() => _gender = value!);
                              },
                            ),
                            const Text('女'),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('已故'),
                      subtitle: const Text('此人已去世'),
                      value: _isDeceased,
                      onChanged: (value) {
                        setState(() => _isDeceased = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('收养'),
                      subtitle: const Text('收养或过继'),
                      value: _isAdopted,
                      onChanged: (value) {
                        setState(() => _isAdopted = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Birth & Death
            _buildSectionTitle('生卒信息'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        labelText: '出生日期',
                        hintText: '1990-01-15',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1800),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _birthDateController.text = 
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthDateLunarController,
                      decoration: const InputDecoration(
                        labelText: '农历生日',
                        hintText: '腊月二十',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthPlaceController,
                      decoration: const InputDecoration(
                        labelText: '出生地',
                        hintText: '北京市',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    if (_isDeceased) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deathDateController,
                        decoration: const InputDecoration(
                          labelText: '逝世日期',
                          hintText: '2020-05-20',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1800),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _deathDateController.text = 
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deathPlaceController,
                        decoration: const InputDecoration(
                          labelText: '逝世地',
                          hintText: '上海市',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _burialPlaceController,
                        decoration: const InputDecoration(
                          labelText: '墓地',
                          hintText: 'XX 公墓',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Life Info
            _buildSectionTitle('生平信息'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: '职业',
                        hintText: '工程师',
                        prefixIcon: Icon(Icons.work),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _achievementsController,
                      decoration: const InputDecoration(
                        labelText: '成就',
                        hintText: '获得 XX 奖项',
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _biographyController,
                      decoration: const InputDecoration(
                        labelText: '传记',
                        hintText: '此人生平事迹...',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditing ? '保存修改' : '添加族人'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final person = Person(
      id: widget.person?.id,
      uuid: widget.person?.uuid ?? const Uuid().v4(),
      familyName: _familyNameController.text,
      givenName: _givenNameController.text,
      generationName: _generationNameController.text.isEmpty 
          ? null 
          : _generationNameController.text,
      courtesyName: _courtesyNameController.text.isEmpty 
          ? null 
          : _courtesyNameController.text,
      artName: _artNameController.text.isEmpty 
          ? null 
          : _artNameController.text,
      englishName: _englishNameController.text.isEmpty 
          ? null 
          : _englishNameController.text,
      gender: _gender,
      birthDate: _birthDateController.text.isEmpty 
          ? null 
          : _birthDateController.text,
      birthDateLunar: _birthDateLunarController.text.isEmpty 
          ? null 
          : _birthDateLunarController.text,
      birthPlace: _birthPlaceController.text.isEmpty 
          ? null 
          : _birthPlaceController.text,
      deathDate: _deathDateController.text.isEmpty 
          ? null 
          : _deathDateController.text,
      deathPlace: _deathPlaceController.text.isEmpty 
          ? null 
          : _deathPlaceController.text,
      burialPlace: _burialPlaceController.text.isEmpty 
          ? null 
          : _burialPlaceController.text,
      isDeceased: _isDeceased,
      isAdopted: _isAdopted,
      occupation: _occupationController.text.isEmpty 
          ? null 
          : _occupationController.text,
      achievements: _achievementsController.text.isEmpty 
          ? null 
          : _achievementsController.text,
      biography: _biographyController.text.isEmpty 
          ? null 
          : _biographyController.text,
    );

    final provider = context.read<PersonProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updatePerson(person);
    } else {
      success = await provider.createPerson(person);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? '修改成功' : '添加成功'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('操作失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
