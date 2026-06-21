'use strict';

const multer = require('multer');
const { Upload } = require('@aws-sdk/lib-storage');
const { v4: uuidv4 } = require('uuid');
const s3Client = require('../config/s3');
const logger = require('../config/logger');

// Configure Multer to use memory storage
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB limit
  },
});

/**
 * Upload a buffer to S3 and return the public URL
 * @param {Buffer} buffer - The file buffer
 * @param {string} mimetype - The file MIME type
 * @param {string} folder - The destination folder in S3 (e.g., 'avatars' or 'properties')
 * @returns {Promise<string>} The public S3 URL of the uploaded file
 */
const uploadToS3 = async (buffer, mimetype, folder = 'uploads') => {
  const bucketName = process.env.AWS_S3_BUCKET_NAME;
  if (!bucketName) {
    throw new Error('AWS_S3_BUCKET_NAME is not defined in environment variables');
  }

  const extension = mimetype.split('/')[1] || 'bin';
  const key = `${folder}/${uuidv4()}.${extension}`;

  try {
    const uploader = new Upload({
      client: s3Client,
      params: {
        Bucket: bucketName,
        Key: key,
        Body: buffer,
        ContentType: mimetype,
      },
    });

    await uploader.done();

    const publicUrl = `https://${bucketName}.s3.${process.env.AWS_REGION || 'ap-south-1'}.amazonaws.com/${key}`;
    logger.info(`File uploaded successfully to S3: ${publicUrl}`);
    
    return publicUrl;
  } catch (error) {
    logger.error(`Error uploading file to S3: ${error.message}`);
    throw error;
  }
};

module.exports = {
  upload,
  uploadToS3,
};
