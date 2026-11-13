/// Menyimpan stream terakhir per kunci.
///
/// `StreamBuilder(stream: service.query(...))` di dalam `build()` membuat
/// listener Firestore baru di setiap rebuild — boros kuota baca. Dengan
/// memo ini listener hanya dibuat ulang bila kuncinya (mis. tanggal) berubah.
class StreamMemo<T> {
  String? _key;
  Stream<T>? _stream;

  Stream<T> get(String key, Stream<T> Function() create) {
    if (_stream == null || key != _key) {
      _key = key;
      _stream = create();
    }
    return _stream!;
  }
}
