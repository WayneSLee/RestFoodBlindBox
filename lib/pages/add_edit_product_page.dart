import 'package:flutter/material.dart';
import 'package:restfoodblindbox/models/product_model.dart';
import 'package:restfoodblindbox/services/api_service.dart'; // 稍後會用到

class AddEditProductPage extends StatefulWidget {
  final String storeId;
  final Product? productToEdit; // 用於判斷是新增還是編輯模式

  const AddEditProductPage({
    super.key,
    required this.storeId,
    this.productToEdit,
  });

  bool get isEditing => productToEdit != null;

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 如果是編輯模式，將現有商品資料填入表單
    if (widget.isEditing) {
      final product = widget.productToEdit!;
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descriptionController.text = product.description;
      _imageUrlController.text = product.imageUrl;
      // _quantityController.text = product.quantity.toString(); // 假設 Product model 未來有 quantity
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final productData = {
        "name": _nameController.text,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "description": _descriptionController.text,
        "imageUrl": _imageUrlController.text,
        "quantity": int.tryParse(_quantityController.text) ?? 0,
      };

      try {
        if (widget.isEditing) {
          // 呼叫更新 API
          await ApiService.updateProduct(widget.productToEdit!.id, productData);
        } else {
          // 呼叫新增 API
          await ApiService.createProduct(widget.storeId, productData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('商品已成功${widget.isEditing ? '更新' : '新增'}！')),
          );
          Navigator.of(context).pop(true); // 返回 true 代表需要刷新列表
        }
      } catch (e) {
        if (mounted) {

          print('[AddEditProductPage] 新增商品失敗，捕捉到的錯誤: $e');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作失敗: $e')),
          );
        }
      } finally {
        if(mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '編輯商品' : '新增商品'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '商品名稱'),
                validator: (v) => v!.isEmpty ? '請輸入商品名稱' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '價格'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? '請輸入價格' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: '數量'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? '請輸入數量' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '描述'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? '請輸入描述' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: '商品照片 URL'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.isEditing ? '儲存變更' : '上架商品'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
