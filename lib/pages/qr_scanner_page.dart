import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:restfoodblindbox/services/api_service.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  // 手機掃描器控制器
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false; // 用於防止重複處理

  // 掃描成功後的處理邏輯
  Future<void> _handleQrCode(String orderId) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 呼叫 API 將訂單標示為已完成
      await ApiService.completeOrder(orderId);

      if (mounted) {
        // 顯示成功訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('訂單 #$orderId 已成功核銷！'),
            backgroundColor: Colors.green,
          ),
        );
        // 成功後自動返回上一頁
        Navigator.of(context).pop(true); // 返回 true 代表需要刷新列表
      }
    } catch (e) {
      if (mounted) {
        // 顯示失敗訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('核銷失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 短暫延遲後才將 _isProcessing 設回 false，避免相機立刻又掃到同一個碼
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('掃描取貨 QR Code')),
      body: Stack(
        children: [
          // 相機預覽畫面
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrCodeValue = barcodes.first.rawValue;
                if (qrCodeValue != null) {
                  print("掃描到 QR Code: $qrCodeValue");
                  _handleQrCode(qrCodeValue);
                }
              }
            },
          ),
          // 掃描框提示 UI
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
