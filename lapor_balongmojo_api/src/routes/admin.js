const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat } = require('../middleware/auth');

router.put('/verifikasi/:userId', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { userId } = req.params;
    await db.execute(
      'UPDATE users SET is_verified = true WHERE id = ? AND role = "masyarakat"',
      [userId]
    );
    res.json({ message: 'User berhasil diverifikasi.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/tolak/:userId', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { userId } = req.params;

    await db.execute(
      'DELETE FROM users WHERE id = ? AND role = "masyarakat" AND is_verified = false',
      [userId]
    );

    res.json({ message: 'User berhasil ditolak (dihapus).' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/users-pending', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const [users] = await db.execute(
      'SELECT id, nama_lengkap, email, no_telepon FROM users WHERE role = "masyarakat" AND is_verified = false'
    );
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


module.exports = router;