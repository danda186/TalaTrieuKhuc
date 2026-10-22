/// Kết quả có kiểu của một thao tác có thể bị từ chối: [Ok] hoặc [Err].
sealed class Result<T, F> {
  const Result();
}

/// Thao tác thành công với giá trị [value].
final class Ok<T, F> extends Result<T, F> {
  /// Bọc giá trị thành công.
  const Ok(this.value);

  /// Giá trị trả về.
  final T value;
}

/// Thao tác bị từ chối với lý do [failure].
final class Err<T, F> extends Result<T, F> {
  /// Bọc lý do thất bại.
  const Err(this.failure);

  /// Lý do bị từ chối.
  final F failure;
}
