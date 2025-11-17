const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth'); // Hanya butuh verifikasi token

// Rute untuk update FCM token
// PUT /profile/update-fcm  <-- Sesuai dengan ApiService Anda
router.post('/update-fcm', verifyToken, async (req, res) => {
  try {
    const { fcm_token } = req.body; // Ambil token dari body
    const userId = req.user.id;     // Ambil ID user dari token JWT

    if (!fcm_token) {
      return res.status(400).json({ message: 'FCM token tidak boleh kosong' });
    }

    // Update token di database untuk user yang sedang login
    await db.execute(
      'UPDATE users SET fcm_token = ? WHERE id = ?',
      [fcm_token, userId]
    );

    res.status(200).json({ message: 'FCM token berhasil diperbarui.' });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;