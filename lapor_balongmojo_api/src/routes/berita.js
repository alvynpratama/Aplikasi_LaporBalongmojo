const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat } = require('../middleware/auth');

// --- 1. IMPORT FUNGSI FCM HELPER ---
const { kirimNotifikasiDarurat } = require('../../utils/fcm_helper');

router.post('/', [verifyToken, isPerangkat], async (req, res) => {
  try {
    // --- [CCTV 3] DEBUG BACKEND ---
    console.log("================================================");
    console.log(">>> [BACKEND] Menerima Data dari Flutter:");
    console.log("Body Lengkap:", req.body);
    console.log("Nilai is_peringatan_darurat:", req.body.is_peringatan_darurat);
    console.log("Tipe Data:", typeof req.body.is_peringatan_darurat);
    console.log("================================================");
    // -----------------------------

    const { judul, isi, gambar_url, is_peringatan_darurat } = req.body;
    const author_id = req.user.id;

    // Query INSERT ke Database
    await db.execute(
      'INSERT INTO berita (author_id, judul, isi, gambar_url, is_peringatan_darurat) VALUES (?, ?, ?, ?, ?)',
      [author_id, judul, isi, gambar_url, is_peringatan_darurat ?? false] 
    );
    
    // Logika Kirim Notifikasi
    // Menggunakan loose equality (==) agar 'true' dan "true" sama-sama bisa
    if (is_peringatan_darurat == true) { 
      console.log('>>> [BACKEND] PERINGATAN DARURAT TERDETEKSI. MENGIRIM NOTIFIKASI...');
      kirimNotifikasiDarurat(judul, isi); 
    } else {
      console.log('>>> [BACKEND] Bukan berita darurat (Nilai false/0). Tidak kirim notif.');
    }
    
    res.status(201).json({ message: 'Berita berhasil dipublikasikan.' });
  } catch (err) {
    console.error(">>> [BACKEND ERROR]:", err);
    res.status(500).json({ message: err.message });
  }
});

// router.get tidak perlu diubah
router.get('/', async (req, res) => {
  try {
    const [berita] = await db.execute(
      'SELECT b.*, u.nama_lengkap AS author_name FROM berita b JOIN users u ON b.author_id = u.id ORDER BY b.created_at DESC'
    );
    res.json(berita);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;