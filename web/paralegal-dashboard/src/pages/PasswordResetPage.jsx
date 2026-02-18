import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import './PasswordResetPage.css'

const API_URL = 'http://localhost:5001/api'

function PasswordResetPage({ paralegal, onPasswordReset }) {
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  const handleResetPassword = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    // Validation
    if (newPassword.length < 8) {
      setError('Password must be at least 8 characters long')
      setLoading(false)
      return
    }

    if (newPassword !== confirmPassword) {
      setError('New passwords do not match')
      setLoading(false)
      return
    }

    try {
      const response = await fetch(`${API_URL}/auth/reset-password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          paralegal_id: paralegal.id,
          current_password: currentPassword,
          new_password: newPassword,
        }),
      })

      const result = await response.json()

      if (!response.ok || !result.success) {
        throw new Error(result.error || 'Password reset failed')
      }

      // Update paralegal data to remove reset flag
      const updatedParalegal = { ...paralegal, must_reset_password: false }
      if (onPasswordReset) {
        onPasswordReset(updatedParalegal)
      }

      alert('Password changed successfully! You can now access your dashboard.')
      navigate('/dashboard')
    } catch (err) {
      setError(err.message || 'Failed to reset password')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="password-reset-page">
      <div className="reset-container">
        <div className="header">
          <h1>🔐 Set Your Password</h1>
          <p>Welcome, {paralegal.name}!</p>
          <p className="instruction">
            For security reasons, please change your temporary password to a new one of your choice.
          </p>
        </div>

        <form onSubmit={handleResetPassword} className="reset-form">
          <div className="form-group">
            <label htmlFor="current-password">Temporary Password</label>
            <input
              type="password"
              id="current-password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              required
              placeholder="Enter the password sent by admin"
              autoComplete="current-password"
            />
            <small>Enter the temporary password you received from the admin</small>
          </div>

          <div className="form-group">
            <label htmlFor="new-password">New Password</label>
            <input
              type="password"
              id="new-password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              required
              placeholder="Create a strong password (min 8 characters)"
              autoComplete="new-password"
            />
            <small>Must be at least 8 characters long</small>
          </div>

          <div className="form-group">
            <label htmlFor="confirm-password">Confirm New Password</label>
            <input
              type="password"
              id="confirm-password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              placeholder="Re-enter your new password"
              autoComplete="new-password"
            />
          </div>

          {error && <div className="error-message">{error}</div>}

          <div className="password-tips">
            <h4>Password Tips:</h4>
            <ul>
              <li>Use at least 8 characters</li>
              <li>Mix uppercase and lowercase letters</li>
              <li>Include numbers and special characters</li>
              <li>Avoid common words or personal info</li>
            </ul>
          </div>

          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Updating Password...' : 'Set My Password'}
          </button>
        </form>
      </div>
    </div>
  )
}

export default PasswordResetPage
