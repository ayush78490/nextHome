'use strict';

const { supabase } = require('../../config/supabase');

class AuthRepository {
  /**
   * Find user by Firebase UID
   */
  async findByFirebaseUid(firebaseUid) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('firebase_uid', firebaseUid)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  }

  /**
   * Find user by email
   */
  async findByEmail(email) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  }

  /**
   * Find user by ID
   */
  async findById(id) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  }

  /**
   * Create a new user
   */
  async create({ firebaseUid, email, passwordHash, phone, fullName, avatarUrl, role = 'tenant' }) {
    const { data, error } = await supabase
      .from('users')
      .insert([
        {
          firebase_uid: firebaseUid,
          email,
          password_hash: passwordHash || null,
          phone: phone || null,
          full_name: fullName,
          avatar_url: avatarUrl || null,
          role
        }
      ])
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  /**
   * Update FCM token for push notifications
   */
  async updateFcmToken(userId, fcmToken) {
    const { error } = await supabase
      .from('users')
      .update({ fcm_token: fcmToken })
      .eq('id', userId);
    if (error) throw error;
  }

  /**
   * Update user profile
   */
  async updateProfile(userId, { fullName, phone, avatarUrl, email }) {
    const updates = {};
    if (fullName !== undefined) updates.full_name = fullName;
    if (phone !== undefined) updates.phone = phone;
    if (avatarUrl !== undefined) updates.avatar_url = avatarUrl;
    if (email !== undefined) updates.email = email;
    
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();
    if (error) throw error;
    return data;
  }
}

module.exports = new AuthRepository();
