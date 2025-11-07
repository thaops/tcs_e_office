import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Isolate helper để tải PDF bytes từ URL
/// Tải PDF trong isolate để không block UI thread
class PdfLoaderIsolate {
  /// Tải PDF bytes trong isolate
  /// 
  /// [url] - URL của PDF file
  /// 
  /// Returns [Uint8List] nếu thành công
  /// Throws [TimeoutException] nếu timeout
  /// Throws [Exception] nếu có lỗi khác
  static Future<Uint8List> loadPdfBytes(String url) async {
    return await Isolate.run(() => _loadPdfInIsolate(url));
  }

  /// Isolate entry point để tải PDF bytes
  static Future<Uint8List> _loadPdfInIsolate(String url) async {
    http.Client? client;
    
    try {
      client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      
      // Connection timeout: 25s
      final streamedResponse = await client
          .send(request)
          .timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          client?.close();
          throw TimeoutException(
            'Connection timeout',
            const Duration(seconds: 25),
          );
        },
      );

      if (streamedResponse.statusCode == 200) {
        // Read timeout: 10s
        final response = await http.Response.fromStream(streamedResponse)
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(
              'Read timeout',
              const Duration(seconds: 10),
            );
          },
        );
        
        client.close();
        return Uint8List.fromList(response.bodyBytes);
      } else {
        client.close();
        throw Exception('HTTP ${streamedResponse.statusCode}');
      }
    } catch (e) {
      client?.close();
      rethrow;
    }
  }
}

