// Unit test klien WHEP dengan adapter Dio palsu (tanpa jaringan).

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/core/config/app_config.dart';
import 'package:elfan_mobile/data/services/api_exception.dart';
import 'package:elfan_mobile/features/cctv/services/whep_signaling_client.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

WhepSignalingClient _client(
  _FakeAdapter adapter, {
  Duration connectTimeout = const Duration(seconds: 5),
  Duration receiveTimeout = const Duration(seconds: 5),
}) {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = adapter;
  return WhepSignalingClient(
    config: const AppConfig(apiBaseUrl: 'https://api.example.test'),
    dio: dio,
  );
}

const String _offerSdp = 'v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\n';
const String _answerSdp = 'v=0\r\no=- 0 0 IN IP4 192.168.20.253\r\n';

final Uri _whepUrl = Uri.parse('http://192.168.20.253:8889/elfan-class/whep');

void main() {
  group('WhepSignalingClient.connect', () {
    test(
      'mengirim SDP offer sebagai application/sdp dan membaca answer',
      () async {
        final _FakeAdapter adapter = _FakeAdapter((
          RequestOptions options,
        ) async {
          return ResponseBody.fromString(
            _answerSdp,
            201,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/sdp'],
              'location': <String>['/elfan-class/whep/session-1'],
            },
          );
        });

        final WhepSession session = await _client(
          adapter,
        ).connect(whepUrl: _whepUrl, offerSdp: _offerSdp);

        expect(session.answerSdp, _answerSdp);
        expect(
          session.resourceUri,
          Uri.parse('http://192.168.20.253:8889/elfan-class/whep/session-1'),
        );

        final RequestOptions request = adapter.requests.single;
        expect(request.method, 'POST');
        expect(request.uri, _whepUrl);
        expect(request.data, _offerSdp);
        final String contentType =
            request.headers[Headers.contentTypeHeader]?.toString() ??
            request.contentType ??
            '';
        expect(contentType, contains('application/sdp'));
        expect(request.headers['Accept'], 'application/sdp');
      },
    );

    test('menerima sesi tanpa header Location', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        return ResponseBody.fromString(
          _answerSdp,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/sdp'],
          },
        );
      });

      final WhepSession session = await _client(
        adapter,
      ).connect(whepUrl: _whepUrl, offerSdp: _offerSdp);

      expect(session.answerSdp, _answerSdp);
      expect(session.resourceUri, isNull);
    });

    test('memetakan penolakan media server menjadi ApiException', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        return ResponseBody.fromString(
          '{"detail":"no stream"}',
          404,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        );
      });

      await expectLater(
        _client(adapter).connect(whepUrl: _whepUrl, offerSdp: _offerSdp),
        throwsA(
          isA<ApiException>()
              .having(
                (ApiException error) => error.kind,
                'kind',
                ApiExceptionKind.notFound,
              )
              .having(
                (ApiException error) => error.message,
                'message',
                contains('Media server menolak'),
              ),
        ),
      );
    });

    test('menolak body yang bukan SDP', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        return ResponseBody.fromString(
          'ok',
          201,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/plain'],
          },
        );
      });

      await expectLater(
        _client(adapter).connect(whepUrl: _whepUrl, offerSdp: _offerSdp),
        throwsA(
          isA<ApiException>().having(
            (ApiException error) => error.kind,
            'kind',
            ApiExceptionKind.unexpected,
          ),
        ),
      );
    });
  });

  group('WhepSignalingClient.disconnect', () {
    test('menghapus resource sesi di media server', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        if (options.method == 'DELETE') {
          return ResponseBody.fromString('', 200);
        }
        return ResponseBody.fromString(
          _answerSdp,
          201,
          headers: <String, List<String>>{
            'location': <String>['/elfan-class/whep/session-1'],
          },
        );
      });
      final WhepSignalingClient client = _client(adapter);
      final WhepSession session = await client.connect(
        whepUrl: _whepUrl,
        offerSdp: _offerSdp,
      );

      await client.disconnect(session);

      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.method, 'DELETE');
      expect(
        adapter.requests.last.uri,
        Uri.parse('http://192.168.20.253:8889/elfan-class/whep/session-1'),
      );
    });

    test('tidak memanggil jaringan saat tidak ada resource sesi', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        return ResponseBody.fromString(_answerSdp, 200);
      });
      final WhepSignalingClient client = _client(adapter);
      final WhepSession session = await client.connect(
        whepUrl: _whepUrl,
        offerSdp: _offerSdp,
      );

      await client.disconnect(session);

      expect(adapter.requests, hasLength(1));
    });

    test('kegagalan DELETE tidak dilempar ke pemanggil', () async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        if (options.method == 'DELETE') {
          return ResponseBody.fromString('gone', 404);
        }
        return ResponseBody.fromString(
          _answerSdp,
          201,
          headers: <String, List<String>>{
            'location': <String>['/elfan-class/whep/session-1'],
          },
        );
      });
      final WhepSignalingClient client = _client(adapter);
      final WhepSession session = await client.connect(
        whepUrl: _whepUrl,
        offerSdp: _offerSdp,
      );

      await expectLater(client.disconnect(session), completes);
    });
  });
}
