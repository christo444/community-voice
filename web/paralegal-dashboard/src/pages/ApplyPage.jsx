import React, { useState } from 'react'
import { supabase } from '../utils/supabase'
import './ApplyPage.css'

function ApplyPage() {
  const [formData, setFormData] = useState({
    name: '',
    qualification: '',
    email: '',
    phone_number: '',
    message: ''
  })
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState('')

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const { data, error } = await supabase
        .from('paralegal_requests')
        .insert([
          {
            name: formData.name,
            qualification: formData.qualification,
            email: formData.email,
            phone_number: formData.phone_number || null,
            message: formData.message || null,
            status: 'pending'
          }
        ])

      if (error) throw error

      setSuccess(true)
      setFormData({
        name: '',
        qualification: '',
        email: '',
        phone_number: '',
        message: ''
      })
    } catch (err) {
      setError(err.message || 'Failed to submit application')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="apply-page">
        <div className="success-container">
          <h1>✅ Application Submitted!</h1>
          <p>Thank you for applying to become a paralegal with Community Voice.</p>
          <p>We'll review your application and contact you via email within 48 hours.</p>
          <button onClick={() => setSuccess(false)} className="btn-secondary">
            Submit Another Application
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="apply-page">
      <div className="apply-container">
        <div className="header">
          <h1>🏛️ Join as a Paralegal</h1>
          <p>Help communities access welfare schemes and legal services</p>
        </div>

        <form onSubmit={handleSubmit} className="apply-form">
          <div className="form-group">
            <label htmlFor="name">Full Name *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
              placeholder="Enter your full name"
            />
          </div>

          <div className="form-group">
            <label htmlFor="qualification">Qualification *</label>
            <select
              id="qualification"
              name="qualification"
              value={formData.qualification}
              onChange={handleChange}
              required
            >
              <option value="">Select qualification</option>
              <option value="Law Graduate">Law Graduate</option>
              <option value="Social Worker">Social Worker</option>
              <option value="Legal Assistant">Legal Assistant</option>
              <option value="Community Worker">Community Worker</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="email">Email Address *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
              placeholder="your.email@example.com"
            />
          </div>

          <div className="form-group">
            <label htmlFor="phone_number">Phone Number</label>
            <input
              type="tel"
              id="phone_number"
              name="phone_number"
              value={formData.phone_number}
              onChange={handleChange}
              placeholder="+91 1234567890"
            />
          </div>

          <div className="form-group">
            <label htmlFor="message">Why do you want to join? (Optional)</label>
            <textarea
              id="message"
              name="message"
              value={formData.message}
              onChange={handleChange}
              rows="4"
              placeholder="Tell us about your motivation..."
            />
          </div>

          {error && <div className="error-message">{error}</div>}

          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Submitting...' : 'Submit Application'}
          </button>
        </form>

        <div className="footer-links">
          <a href="/login">Already approved? Login here</a>
        </div>
      </div>
    </div>
  )
}

export default ApplyPage
