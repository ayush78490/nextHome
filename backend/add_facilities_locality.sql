-- SQL script to add facilities and locality columns to properties table
-- Run this in the Supabase SQL Editor

ALTER TABLE properties ADD COLUMN facilities TEXT[] DEFAULT '{}';
ALTER TABLE properties ADD COLUMN locality VARCHAR(255);
