const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Akses ditolak. Token tidak ada.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next(); 
  } catch (err) {
    res.status(400).json({ message: 'Token tidak valid.' });
  }
};

const isPerangkat = (req, res, next) => {
  if (req.user.role !== 'perangkat') {
    return res.status(403).json({ message: 'Akses ditolak. Hanya untuk Perangkat.' });
  }
  next();
};

const isMasyarakat = (req, res, next) => {
  if (req.user.role !== 'masyarakat') {
    return res.status(403).json({ message: 'Akses ditolak. Hanya untuk Masyarakat.' });
  }
  next();
};

module.exports = {
  verifyToken,
  isPerangkat,
  isMasyarakat
};