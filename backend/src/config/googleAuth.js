'use strict';

const { OAuth2Client } = require('google-auth-library');
const https = require('https');
const logger = require('./logger');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Fetch user info from Google's tokeninfo endpoint.
 * Used as fallback when email is missing from the ID token
 * (common with google_sign_in v7 on Android).
 */
async function fetchGoogleTokenInfo(idToken) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: 'oauth2.googleapis.com',
        path: '/tokeninfo?id_token=' + idToken,
        method: 'GET',
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          try { resolve(JSON.parse(data)); }
          catch (e) { reject(e); }
        });
      }
    );
    req.on('error', reject);
    req.end();
  });
}

/**
 * Verify a Google OAuth ID token and return decoded payload.
 * Falls back to client-provided email or tokeninfo endpoint if email is missing from the token.
 * @param {string} idToken
 * @param {string} [clientEmail]
 */
async function verifyGoogleToken(idToken, clientEmail) {
  if (!process.env.GOOGLE_CLIENT_ID) {
    throw new Error('GOOGLE_CLIENT_ID is not configured in environment');
  }

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    let payload = ticket.getPayload();
    logger.info('Google token payload: ' + JSON.stringify({ sub: payload.sub, email: payload.email, name: payload.name }));

    // Email is missing from ID token (common with google_sign_in v7 on Android)
    if (!payload.email) {
      if (clientEmail) {
        logger.info(`Email missing from ID token — using client provided email: ${clientEmail}`);
        payload.email = clientEmail;
      } else {
        logger.info('Email missing from ID token and no client email — fetching from Google tokeninfo endpoint');
        const tokenInfo = await fetchGoogleTokenInfo(idToken);
        logger.info('Tokeninfo email: ' + tokenInfo.email);
        payload = {
          ...payload,
          email: tokenInfo.email,
          name:  tokenInfo.name  || payload.name,
        };
      }
    }

    if (!payload.email) {
      throw new Error('Could not retrieve email from Google token');
    }

    return {
      uid:            payload.sub,
      email:          payload.email,
      name:           payload.name,
      picture:        payload.picture,
      email_verified: payload.email_verified,
    };
  } catch (err) {
    logger.error('Google Token verification failed:', err.message);
    throw new Error('Invalid Google ID token');
  }
}

module.exports = { verifyGoogleToken };
