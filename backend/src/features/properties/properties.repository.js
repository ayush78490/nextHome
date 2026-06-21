'use strict';

const { supabase } = require('../../config/supabase');

class PropertiesRepository {
  async list(filters = {}) {
    let query = supabase
      .from('properties')
      .select('*, landlord:users(id, full_name, avatar_url)')
      .order('created_at', { ascending: false });

    if (filters.listing_type) query = query.eq('listing_type', filters.listing_type);
    if (filters.property_type) query = query.eq('property_type', filters.property_type);
    if (filters.city) query = query.ilike('city', `%${filters.city}%`);

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async findById(id) {
    const { data, error } = await supabase
      .from('properties')
      .select('*, landlord:users(id, full_name, avatar_url)')
      .eq('id', id)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  }

  async create(propertyData) {
    const { data, error } = await supabase
      .from('properties')
      .insert([propertyData])
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async updateImages(id, imageUrls) {
    const { data, error } = await supabase
      .from('properties')
      .update({ images: imageUrls })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async updateStatus(id, isApproved) {
    const { data, error } = await supabase
      .from('properties')
      .update({ is_approved: isApproved })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async delete(id) {
    const { error } = await supabase
      .from('properties')
      .delete()
      .eq('id', id);
    if (error) throw error;
    return true;
  }
}

module.exports = new PropertiesRepository();
