const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload'); 
const { verifyToken } = require('../middleware/auth'); 

router.post('/', [verifyToken, upload.single('image')], (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Tidak ada file yang di-upload.' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    
    // Kembalikan URL ke client (Flutter)
    res.status(201).json({ 
      message: 'File berhasil di-upload', 
      imageUrl: imageUrl 
    });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;