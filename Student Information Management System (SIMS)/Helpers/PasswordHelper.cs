using System;
using System.Security.Cryptography;
using System.Text;

namespace SIMS.Helpers
{
    /// <summary>
    /// Utility class for hashing and verifying passwords using SHA-256.
    /// Also generates secure random tokens for password reset emails.
    /// </summary>
    public static class PasswordHelper
    {
        // ---------------------------------------------------------------
        // Hash a plain-text password with SHA-256 + salt.
        // Returns: "SALT:HASH" stored in PasswordHash column.
        // ---------------------------------------------------------------
        public static string HashPassword(string plainText)
        {
            // Generate a 16-byte random salt
            byte[] saltBytes = new byte[16];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(saltBytes);

            string salt = Convert.ToBase64String(saltBytes);
            string hash = ComputeHash(plainText, salt);

            return $"{salt}:{hash}";
        }

        // ---------------------------------------------------------------
        // Verify a plain-text password against the stored "SALT:HASH".
        // ---------------------------------------------------------------
        public static bool VerifyPassword(string plainText, string storedHash)
        {
            if (string.IsNullOrWhiteSpace(storedHash) ||
                !storedHash.Contains(":"))
                return false;

            string[] parts = storedHash.Split(new[] { ':' }, 2);
            string salt = parts[0];
            string expectedHash = parts[1];

            string actualHash = ComputeHash(plainText, salt);
            return string.Equals(actualHash, expectedHash,
                                  StringComparison.Ordinal);
        }

        // ---------------------------------------------------------------
        // Generate a cryptographically secure reset token (URL-safe).
        // ---------------------------------------------------------------
        public static string GenerateResetToken()
        {
            byte[] tokenBytes = new byte[32];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(tokenBytes);

            // URL-safe base64
            return Convert.ToBase64String(tokenBytes)
                          .Replace("+", "-")
                          .Replace("/", "_")
                          .Replace("=", "");
        }

        // ---------------------------------------------------------------
        // Internal: SHA-256 hash of (password + salt).
        // ---------------------------------------------------------------
        private static string ComputeHash(string password, string salt)
        {
            byte[] combined = Encoding.UTF8.GetBytes(salt + password);
            using (SHA256 sha = SHA256.Create())
            {
                byte[] hash = sha.ComputeHash(combined);
                return Convert.ToBase64String(hash);
            }
        }
    }
}