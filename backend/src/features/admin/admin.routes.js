'use strict';
const express = require('express');
const { authenticateJWT, requireRole } = require('../../middleware/auth');
const authRepository = require('../auth/auth.repository');

const router = express.Router();

// GET /api/v1/admin/users/count
router.get('/users/count', authenticateJWT, requireRole('admin'), async (req, res, next) => {
  try {
    const { supabase } = require('../../config/supabase');
    const { count, error } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true });
      
    if (error) throw error;
    
    res.status(200).json({ success: true, count: count || 0 });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
