import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/models/road_defect.dart';

class DefectRecordPage extends StatefulWidget {
  const DefectRecordPage({super.key});

  @override
  State<DefectRecordPage> createState() => _DefectRecordPageState();
}

class _DefectRecordPageState extends State<DefectRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _roadNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedType = '裂缝';
  String _selectedSeverity = '中等';
  final List<String> _photoPaths = [];
  Position? _currentPosition;

  final List<String> _defectTypes = ['裂缝', '坑槽', '沉陷', '松散', '波浪', '其他'];
  final List<String> _severities = ['轻微', '中等', '严重'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取位置失败: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (photo != null) {
      setState(() => _photoPaths.add(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    setState(() {
      _photoPaths.addAll(images.map((e) => e.path));
    });
  }

  Future<void> _saveDefect() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_photoPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少拍摄一张照片')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置信息获取中，请稍候')),
      );
      return;
    }

    final defect = RoadDefect(
      id: const Uuid().v4(),
      type: _selectedType,
      description: _descController.text,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      photos: _photoPaths,
      severity: _selectedSeverity,
      createdAt: DateTime.now(),
      roadName: _roadNameController.text.isEmpty 
          ? null 
          : _roadNameController.text,
    );

    final box = await Hive.openBox<RoadDefect>('defects');
    await box.add(defect);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('病害记录已保存')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('病害记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDefect,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 位置信息
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('当前位置'),
                subtitle: _currentPosition == null
                    ? const Text('获取中...')
                    : Text(
                        '${_currentPosition!.latitude.toStringAsFixed(6)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(6)}',
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 病害类型
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '病害类型',
                border: OutlineInputBorder(),
              ),
              items: _defectTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),

            // 严重程度
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: const InputDecoration(
                labelText: '严重程度',
                border: OutlineInputBorder(),
              ),
              items: _severities.map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Text(severity),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSeverity = value!),
            ),
            const SizedBox(height: 16),

            // 道路名称
            TextFormField(
              controller: _roadNameController,
              decoration: const InputDecoration(
                labelText: '道路名称（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '病害描述',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入病害描述' : null,
            ),
            const SizedBox(height: 16),

            // 照片
            const Text('病害照片', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._photoPaths.map((path) => Stack(
                  children: [
                    Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() => _photoPaths.remove(path));
                        },
                      ),
                    ),
                  ],
                )),
                InkWell(
                  onTap: _takePhoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 32),
                        Text('拍照'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 32),
                        Text('相册'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _roadNameController.dispose();
    super.dispose();
  }
}
