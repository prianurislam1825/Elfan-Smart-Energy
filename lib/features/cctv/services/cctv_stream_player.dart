import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../data/models/cctv_model.dart';
import '../../../data/repositories/cctv_repository.dart';
import '../../../data/services/api_exception.dart';
import 'cctv_diagnostics.dart';
import 'whep_signaling_client.dart';

/// Status pemutaran satu kamera.
enum CctvStreamStatus {
  /// Stream belum dimulai atau sudah dihentikan pengguna.
  idle,

  /// Negosiasi WHEP sedang berjalan.
  connecting,

  /// Video sedang diterima.
  live,

  /// Koneksi terputus dan sedang dicoba ulang.
  reconnecting,

  /// Semua percobaan ulang habis.
  failed,
}

/// State pemutaran satu kamera.
class CctvPlayerState {
  const CctvPlayerState({
    this.status = CctvStreamStatus.idle,
    this.renderer,
    this.errorMessage,
    this.attempt = 0,
    this.protocol = '',
  });

  final CctvStreamStatus status;

  /// Renderer video aktif; `null` saat belum ada peer connection.
  final RTCVideoRenderer? renderer;

  /// Pesan siap tampil untuk kegagalan terakhir.
  final String? errorMessage;

  /// Jumlah percobaan ulang yang sudah dijadwalkan.
  final int attempt;

  /// Protokol dari backend, mis. `WebRTC`.
  final String protocol;

  bool get isConnecting => status == CctvStreamStatus.connecting;
  bool get isLive => status == CctvStreamStatus.live;
  bool get isReconnecting => status == CctvStreamStatus.reconnecting;
  bool get isBusy => isConnecting || isReconnecting;
  bool get isFailed => status == CctvStreamStatus.failed;
  bool get isStopped => status == CctvStreamStatus.idle;

  @override
  String toString() =>
      'CctvPlayerState(status: ${status.name}, attempt: $attempt, '
      'hasRenderer: ${renderer != null})';
}

/// Kejadian penting dari peer connection.
enum CctvPeerEvent { connected, disconnected, failed }

/// Abstraksi peer connection agar logika lifecycle dapat diuji tanpa plugin
/// native WebRTC.
abstract interface class CctvPeer {
  RTCVideoRenderer? get renderer;

  Stream<CctvPeerEvent> get events;

  /// Tambahkan transceiver video `recvonly` lalu buat SDP offer.
  Future<String> createOffer();

  Future<void> setLocalDescription(String sdp);

  /// Tunggu ICE gathering selesai lalu kembalikan SDP lokal lengkap dengan
  /// kandidat ICE (non-trickle, sesuai alur WHEP satu langkah).
  Future<String> waitForIceGathering({required Duration timeout});

  Future<void> setRemoteDescription(String sdp);

  /// Tutup peer connection dan renderer; aman dipanggil berulang.
  Future<void> close();
}

/// Pembuat [CctvPeer] agar player dapat memakai peer palsu pada test.
abstract interface class CctvPeerFactory {
  Future<CctvPeer> create();
}

final class WebRtcCctvPeerFactory implements CctvPeerFactory {
  const WebRtcCctvPeerFactory();

  @override
  Future<CctvPeer> create() => WebRtcCctvPeer.create();
}

/// Implementasi [CctvPeer] berbasis `flutter_webrtc`.
///
/// Video ditampilkan melalui [RTCVideoRenderer]. Tidak ada track audio yang
/// dirender atau diputar: tampilan CCTV hanya memakai track video.
final class WebRtcCctvPeer implements CctvPeer {
  WebRtcCctvPeer._(this._peer, this._renderer) {
    _wireEvents();
  }

  final RTCPeerConnection _peer;
  final RTCVideoRenderer _renderer;
  final StreamController<CctvPeerEvent> _events =
      StreamController<CctvPeerEvent>.broadcast();
  final Completer<void> _iceGathering = Completer<void>();
  final List<String> _localCandidates = <String>[];

  bool _closed = false;

  static Future<WebRtcCctvPeer> create() async {
    final RTCVideoRenderer renderer = RTCVideoRenderer();
    await renderer.initialize();
    try {
      final RTCPeerConnection peer = await createPeerConnection(
        <String, dynamic>{
          // MediaMTX berjalan di LAN yang sama dengan perangkat, sehingga
          // kandidat ICE host sudah cukup dan tidak ada STUN/TURN publik yang
          // dibutuhkan (maupun di-hardcode).
          'iceServers': <Map<String, String>>[],
          'sdpSemantics': 'unified-plan',
          'bundlePolicy': 'max-bundle',
          'iceTransportPolicy': 'all',
        },
      );
      return WebRtcCctvPeer._(peer, renderer);
    } catch (_) {
      await renderer.dispose();
      rethrow;
    }
  }

  @override
  RTCVideoRenderer? get renderer => _closed ? null : _renderer;

  @override
  Stream<CctvPeerEvent> get events => _events.stream;

  void _wireEvents() {
    _peer.onConnectionState = (RTCPeerConnectionState state) {
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'peer connection state: ${_connectionStateName(state)}',
      );
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _emit(CctvPeerEvent.connected);
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _emit(CctvPeerEvent.disconnected);
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _emit(CctvPeerEvent.failed);
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        case RTCPeerConnectionState.RTCPeerConnectionStateNew:
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          break;
      }
    };

    _peer.onIceConnectionState = (RTCIceConnectionState state) {
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'ice connection state: ${_iceConnectionStateName(state)}',
      );
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _emit(CctvPeerEvent.failed);
      }
    };

    _peer.onIceGatheringState = (RTCIceGatheringState state) {
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'ice gathering state: ${_iceGatheringStateName(state)}',
      );
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !_iceGathering.isCompleted) {
        _iceGathering.complete();
      }
    };

    _peer.onIceCandidate = (RTCIceCandidate candidate) {
      _localCandidates.add(candidate.candidate ?? '');
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'ice candidate lokal diterima '
        '(total=${_localCandidates.length})',
      );
    };

    _peer.onTrack = (RTCTrackEvent event) {
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'ontrack kind=${event.track.kind} streams=${event.streams.length} '
        'id=${event.track.id}',
      );
      if (event.streams.isEmpty) {
        return;
      }
      unawaited(_attachStream(event.streams.first));
    };
  }

  static String _connectionStateName(RTCPeerConnectionState state) {
    return state.toString().replaceFirst('RTCPeerConnectionState.', '');
  }

  static String _iceConnectionStateName(RTCIceConnectionState state) {
    return state.toString().replaceFirst('RTCIceConnectionState.', '');
  }

  static String _iceGatheringStateName(RTCIceGatheringState state) {
    return state.toString().replaceFirst('RTCIceGatheringState.', '');
  }

  Future<void> _attachStream(MediaStream stream) async {
    if (_closed) {
      return;
    }
    try {
      await _renderer.setSrcObject(stream: stream);
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'media stream dipasang ke renderer '
        '(tracks=${stream.getTracks().length})',
      );
      _logFirstFrame();
    } catch (_) {
      // Renderer yang sudah di-dispose tidak perlu ditangani lebih lanjut;
      // player akan membuat sesi baru saat reconnect.
    }
  }

  /// Catat ukuran frame pertama sebagai bukti video benar-benar diterima.
  void _logFirstFrame() {
    int attempts = 0;
    Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      attempts++;
      final int width = _renderer.videoWidth;
      final int height = _renderer.videoHeight;
      if (width > 0 && height > 0) {
        CctvDiagnostics.log(
          CctvDiagnostics.cctvTag,
          'frame video pertama ${width}x$height',
        );
        timer.cancel();
      } else if (_closed || attempts >= 20) {
        timer.cancel();
        if (!_closed) {
          CctvDiagnostics.log(
            CctvDiagnostics.cctvTag,
            'belum ada frame video setelah 10s',
          );
        }
      }
    });
  }

  void _emit(CctvPeerEvent event) {
    if (_closed || _events.isClosed) {
      return;
    }
    _events.add(event);
  }

  @override
  Future<String> createOffer() async {
    await _peer.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );
    final RTCSessionDescription offer = await _peer.createOffer();
    final String? sdp = offer.sdp;
    if (sdp == null || sdp.isEmpty) {
      throw StateError('SDP offer kosong.');
    }
    return sdp;
  }

  @override
  Future<void> setLocalDescription(String sdp) {
    return _peer.setLocalDescription(RTCSessionDescription(sdp, 'offer'));
  }

  @override
  Future<String> waitForIceGathering({required Duration timeout}) async {
    if (!_iceGathering.isCompleted) {
      await _iceGathering.future.timeout(
        timeout,
        onTimeout: () {
          // Tetap lanjut dengan kandidat yang sudah terkumpul.
        },
      );
    }
    final RTCSessionDescription? local = await _peer.getLocalDescription();
    final String? sdp = local?.sdp;
    if (sdp == null || sdp.isEmpty) {
      throw StateError('SDP lokal tidak tersedia.');
    }
    return sdp;
  }

  @override
  Future<void> setRemoteDescription(String sdp) {
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'setRemoteDescription ${CctvDiagnostics.describeSdp(sdp)}',
    );
    return _peer.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    try {
      await _renderer.setSrcObject(stream: null);
    } catch (_) {
      // Renderer mungkin sudah tidak aktif; abaikan saat teardown.
    }
    await _events.close();
    try {
      await _peer.close();
    } catch (_) {
      // Peer yang sudah tertutup di sisi native tidak boleh menggagalkan
      // pelepasan resource berikutnya.
    }
    try {
      await _peer.dispose();
    } catch (_) {
      // Sama seperti di atas: teardown bersifat best effort.
    }
    try {
      await _renderer.dispose();
    } catch (_) {
      // Renderer yang sudah di-dispose aman diabaikan.
    }
  }
}

/// Pengelola satu sesi live view kamera.
///
/// Tanggung jawab: mengambil `whep_url` dari backend, negosiasi SDP, memantau
/// status koneksi, reconnect dengan jeda bertingkat, dan melepaskan seluruh
/// resource (peer, renderer, sesi WHEP) saat stream berhenti atau player
/// di-dispose. Hanya satu sesi aktif per instance sehingga beberapa kamera
/// tidak pernah diputar bersamaan tanpa kendali.
class CctvStreamPlayer {
  CctvStreamPlayer({
    required this.cameraId,
    required CctvRepository repository,
    required CctvSignaling signaling,
    required this.onStateChanged,
    CctvPeerFactory? peerFactory,
    this.reconnectDelays = const <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ],
    this.connectTimeout = const Duration(seconds: 20),
    this.iceGatherTimeout = const Duration(seconds: 3),
  }) : _repository = repository,
       _signaling = signaling,
       _peerFactory = peerFactory ?? const WebRtcCctvPeerFactory();

  final String cameraId;
  final void Function(CctvPlayerState state) onStateChanged;
  final List<Duration> reconnectDelays;
  final Duration connectTimeout;
  final Duration iceGatherTimeout;

  final CctvRepository _repository;
  final CctvSignaling _signaling;
  final CctvPeerFactory _peerFactory;

  CctvPlayerState _state = const CctvPlayerState();
  CctvPlayerState get state => _state;

  CctvPeer? _peer;
  WhepSession? _session;
  StreamSubscription<CctvPeerEvent>? _peerEvents;
  Completer<void> _connected = Completer<void>();
  Timer? _reconnectTimer;

  int _generation = 0;
  int _attempt = 0;
  bool _disposed = false;
  bool _handlingFailure = false;

  /// Mulai pemutaran dari awal dan reset hitungan reconnect.
  Future<void> start() async {
    if (_disposed) {
      return;
    }
    _attempt = 0;
    await _beginAttempt();
  }

  /// Coba hubungkan ulang secara manual (mis. tombol Refresh stream).
  Future<void> retry() async {
    if (_disposed) {
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _attempt = 0;
    await _beginAttempt();
  }

  /// Hentikan stream dan lepaskan resource kamera.
  Future<void> stop() async {
    if (_disposed) {
      return;
    }
    _generation++;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _attempt = 0;
    if (!_connected.isCompleted) {
      _connected.complete();
    }
    await _releaseResources();
    if (_disposed) {
      return;
    }
    _emit(CctvPlayerState(protocol: _state.protocol));
  }

  /// Lepaskan semua resource. State tidak lagi diubah setelah ini.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _generation++;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (!_connected.isCompleted) {
      _connected.complete();
    }
    await _releaseResources();
  }

  Future<void> _beginAttempt() async {
    if (_disposed) {
      return;
    }
    final int generation = ++_generation;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final bool reconnecting = _attempt > 0;
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'mulai percobaan gen=$generation kamera=$cameraId '
      'reconnect=$reconnecting attempt=$_attempt',
    );
    _emit(
      CctvPlayerState(
        status: reconnecting
            ? CctvStreamStatus.reconnecting
            : CctvStreamStatus.connecting,
        attempt: _attempt,
        protocol: _state.protocol,
      ),
    );

    await _releaseResources();
    if (!_isCurrent(generation)) {
      return;
    }
    _connected = Completer<void>();

    try {
      await _establish(generation).timeout(connectTimeout);
    } on TimeoutException {
      // Jangan ubah state bila percobaan ini sudah tidak berlaku (mis. stream
      // dihentikan atau percobaan baru dimulai saat menunggu koneksi).
      if (!_isCurrent(generation)) {
        return;
      }
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'gen=$generation timeout setelah ${connectTimeout.inSeconds}s',
      );
      await _failAttempt('Waktu koneksi ke media server CCTV habis.');
    } catch (error, stackTrace) {
      CctvDiagnostics.log(
        CctvDiagnostics.cctvTag,
        'gen=$generation gagal: ${error.runtimeType}: $error',
      );
      CctvDiagnostics.log(CctvDiagnostics.cctvTag, 'stack: $stackTrace');
      if (!_isCurrent(generation)) {
        return;
      }
      await _failAttempt(_describeError(error));
    }
  }

  Future<void> _establish(int generation) async {
    final CctvStreamInfo stream = await _repository.getStream(cameraId);
    final Uri? whepUri = stream.whepUri;
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation stream info: whep=${CctvDiagnostics.safeUrl(whepUri)} '
      'protocol=${stream.protocol}',
    );
    if (whepUri == null) {
      throw const ApiException(
        kind: ApiExceptionKind.unexpected,
        message: 'Alamat WHEP dari backend tidak valid.',
      );
    }
    if (!_isCurrent(generation)) {
      return;
    }

    final CctvPeer peer = await _peerFactory.create();
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation peer dibuat, renderer=${peer.renderer != null}',
    );
    if (!_isCurrent(generation)) {
      await peer.close();
      return;
    }
    _peer = peer;
    _peerEvents = peer.events.listen(
      (CctvPeerEvent event) => _onPeerEvent(generation, event),
      onError: (Object _) => _scheduleReconnect('Koneksi WebRTC terputus.'),
    );
    _emit(
      CctvPlayerState(
        status: _state.status,
        renderer: peer.renderer,
        attempt: _attempt,
        protocol: stream.protocol,
      ),
    );

    final String offer = await peer.createOffer();
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation offer ${CctvDiagnostics.describeSdp(offer)}',
    );
    await peer.setLocalDescription(offer);
    final String localSdp = await peer.waitForIceGathering(
      timeout: iceGatherTimeout,
    );
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation offer setelah ICE '
      '${CctvDiagnostics.describeSdp(localSdp)}',
    );
    if (!_isCurrent(generation)) {
      return;
    }

    final WhepSession session = await _signaling.connect(
      whepUrl: whepUri,
      offerSdp: localSdp,
    );
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation answer ${CctvDiagnostics.describeSdp(session.answerSdp)}',
    );
    if (!_isCurrent(generation)) {
      await _signaling.disconnect(session);
      return;
    }
    _session = session;
    await peer.setRemoteDescription(session.answerSdp);

    if (!_isCurrent(generation)) {
      return;
    }
    await _connected.future;
  }

  void _onPeerEvent(int generation, CctvPeerEvent event) {
    if (!_isCurrent(generation)) {
      return;
    }
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'gen=$generation event=${event.name}',
    );
    switch (event) {
      case CctvPeerEvent.connected:
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _attempt = 0;
        if (!_connected.isCompleted) {
          _connected.complete();
        }
        _emit(
          CctvPlayerState(
            status: CctvStreamStatus.live,
            renderer: _peer?.renderer,
            protocol: _state.protocol,
          ),
        );
      case CctvPeerEvent.disconnected:
        _scheduleReconnect('Koneksi stream terputus.');
      case CctvPeerEvent.failed:
        _scheduleReconnect('Koneksi WebRTC gagal.');
    }
  }

  void _scheduleReconnect(String reason) {
    if (_disposed || _handlingFailure) {
      return;
    }
    unawaited(_failAttempt(reason));
  }

  Future<void> _failAttempt(String message) async {
    if (_disposed || _handlingFailure) {
      return;
    }
    CctvDiagnostics.log(
      CctvDiagnostics.cctvTag,
      'percobaan gagal: $message (attempt=$_attempt)',
    );
    _handlingFailure = true;
    try {
      _generation++;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      if (!_connected.isCompleted) {
        _connected.complete();
      }
      await _releaseResources();
      if (_disposed) {
        return;
      }

      if (_attempt >= reconnectDelays.length) {
        _emit(
          CctvPlayerState(
            status: CctvStreamStatus.failed,
            errorMessage: message,
            attempt: _attempt,
            protocol: _state.protocol,
          ),
        );
        return;
      }

      final Duration delay = reconnectDelays[_attempt];
      _attempt++;
      _emit(
        CctvPlayerState(
          status: CctvStreamStatus.reconnecting,
          errorMessage: message,
          attempt: _attempt,
          protocol: _state.protocol,
        ),
      );
      _reconnectTimer = Timer(delay, () {
        _reconnectTimer = null;
        if (_disposed) {
          return;
        }
        unawaited(_beginAttempt());
      });
    } finally {
      _handlingFailure = false;
    }
  }

  Future<void> _releaseResources() async {
    final StreamSubscription<CctvPeerEvent>? events = _peerEvents;
    _peerEvents = null;
    final CctvPeer? peer = _peer;
    _peer = null;
    final WhepSession? session = _session;
    _session = null;

    if (events != null) {
      await events.cancel();
    }
    if (session != null) {
      try {
        await _signaling.disconnect(session);
      } catch (_) {
        // Penutupan sesi server bersifat best effort.
      }
    }
    if (peer != null) {
      await peer.close();
    }
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _emit(CctvPlayerState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    onStateChanged(next);
  }

  String _describeError(Object error) {
    // flutter_webrtc melempar `String`/`PlatformException` mentah untuk
    // kegagalan native (mis. SDP ditolak); jangan tampilkan pesan generik.
    if (error is String) {
      return 'Negosiasi video dengan media server gagal diproses perangkat.';
    }
    if (error is PlatformException) {
      return 'Negosiasi video dengan media server gagal diproses perangkat.';
    }
    if (error is ApiException) {
      return switch (error.kind) {
        ApiExceptionKind.unexpected ||
        ApiExceptionKind.unsupported ||
        ApiExceptionKind.notFound => error.message,
        _ => error.userMessage,
      };
    }
    if (error is TimeoutException) {
      return 'Waktu koneksi ke media server CCTV habis.';
    }
    return 'Gagal memulai stream kamera.';
  }
}
