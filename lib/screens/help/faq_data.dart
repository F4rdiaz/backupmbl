/// Model data untuk satu item FAQ.
class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

/// Contoh data FAQ untuk geo_attend.
/// Ganti/tambah sesuai kebutuhan, atau ambil dari API/backend
/// supaya bisa dikelola admin tanpa rilis ulang aplikasi.
const List<FaqItem> faqList = [
  FaqItem(
    category: 'Absensi',
    question: 'Kenapa saya tidak bisa melakukan absen masuk?',
    answer:
        'Pastikan GPS/lokasi perangkat aktif dan kamu berada dalam radius '
        'kantor yang ditentukan. Periksa juga koneksi internet. Jika masih '
        'gagal, coba keluar dan masuk ulang ke aplikasi.',
  ),
  FaqItem(
    category: 'Absensi',
    question: 'Bagaimana cara melihat riwayat absensi saya?',
    answer:
        'Buka menu "Riwayat" di halaman utama, lalu pilih rentang tanggal '
        'yang ingin dilihat. Data absensi harian akan ditampilkan lengkap '
        'dengan jam masuk dan pulang.',
  ),
  FaqItem(
    category: 'Izin & Cuti',
    question: 'Bagaimana cara mengajukan izin atau cuti?',
    answer:
        'Masuk ke menu "Pengajuan", pilih jenis (Izin/Sakit/Cuti), isi '
        'tanggal dan alasan, lalu unggah dokumen pendukung jika diminta. '
        'Pengajuan akan diteruskan ke atasan untuk disetujui.',
  ),
  FaqItem(
    category: 'Akun',
    question: 'Saya lupa password, bagaimana cara reset?',
    answer:
        'Pada halaman login, tekan "Lupa Password", masukkan email '
        'terdaftar, lalu ikuti instruksi yang dikirimkan.',
  ),
  FaqItem(
    category: 'Akun',
    question: 'Bagaimana cara mengubah foto profil atau nama?',
    answer:
        'Buka menu "Profil", tekan foto untuk mengganti foto, atau tekan '
        'kolom nama untuk mengeditnya, lalu tekan "Simpan Perubahan".',
  ),
];
