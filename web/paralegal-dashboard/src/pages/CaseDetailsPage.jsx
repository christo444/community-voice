import React, { useState, useEffect } from 'react'
import { supabase } from '../utils/supabase'
import { useParams, useNavigate } from 'react-router-dom'
import './CaseDetailsPage.css'

function CaseDetailsPage({ paralegal, onLogout }) {
  const { caseId } = useParams()
  const navigate = useNavigate()
  const [caseData, setCase] = useState(null)
  const [loading, setLoading] = useState(true)
  const [notes, setNotes] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    fetchCaseDetails()
  }, [caseId])

  const fetchCaseDetails = async () => {
    try {
      setLoading(true)
      
      const { data, error } = await supabase
        .from('paralegal_cases')
        .select(`
          *,
          profile:profile_details!paralegal_cases_user_phone_number_fkey(*)
        `)
        .eq('id', caseId)
        .single()

      if (error) throw error

      setCase(data)
      setNotes(data.notes || '')
    } catch (error) {
      console.error('Error fetching case:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusChange = async (newStatus) => {
    try {
      setSaving(true)
      
      const { error } = await supabase
        .from('paralegal_cases')
        .update({ 
          status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('id', caseId)

      if (error) throw error

      setCase({ ...caseData, status: newStatus })
      alert('Status updated successfully')
    } catch (error) {
      console.error('Error updating status:', error)
      alert('Failed to update status')
    } finally {
      setSaving(false)
    }
  }

  const handleSaveNotes = async () => {
    try {
      setSaving(true)
      
      const { error } = await supabase
        .from('paralegal_cases')
        .update({ 
          notes,
          updated_at: new Date().toISOString()
        })
        .eq('id', caseId)

      if (error) throw error

      alert('Notes saved successfully')
    } catch (error) {
      console.error('Error saving notes:', error)
      alert('Failed to save notes')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="case-details-page">
        <div className="loading">Loading case details...</div>
      </div>
    )
  }

  if (!caseData) {
    return (
      <div className="case-details-page">
        <div className="error">Case not found</div>
      </div>
    )
  }

  const profile = caseData.profile || {}

  return (
    <div className="case-details-page">
      <nav className="navbar">
        <div className="nav-content">
          <button onClick={() => navigate('/dashboard')} className="btn-back">
            ← Back to Dashboard
          </button>
          <h2>Case Details</h2>
          <span className="user-email">{paralegal.name}</span>
        </div>
      </nav>

      <div className="case-content">
        <div className="case-header">
          <div>
            <h1>{profile.name || 'Unknown User'}</h1>
            <p className="phone">{caseData.user_phone_number}</p>
          </div>
          <div className="status-controls">
            <label>Status:</label>
            <select 
              value={caseData.status} 
              onChange={(e) => handleStatusChange(e.target.value)}
              disabled={saving}
            >
              <option value="open">Open</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
            </select>
          </div>
        </div>

        <div className="details-grid">
          <div className="detail-card">
            <h3>Personal Information</h3>
            <div className="detail-row">
              <span className="label">Name:</span>
              <span className="value">{profile.name || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="label">Phone:</span>
              <span className="value">{caseData.user_phone_number}</span>
            </div>
            <div className="detail-row">
              <span className="label">Date of Birth:</span>
              <span className="value">{profile.date_of_birth || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="label">Age:</span>
              <span className="value">{profile.age || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="label">Gender:</span>
              <span className="value">{profile.gender || 'N/A'}</span>
            </div>
          </div>

          <div className="detail-card">
            <h3>Address</h3>
            <p className="address">{profile.address || 'No address available'}</p>
          </div>

          <div className="detail-card full-width">
            <h3>Case Information</h3>
            <div className="detail-row">
              <span className="label">Assigned On:</span>
              <span className="value">
                {new Date(caseData.assigned_at).toLocaleString()}
              </span>
            </div>
            <div className="detail-row">
              <span className="label">Last Updated:</span>
              <span className="value">
                {new Date(caseData.updated_at).toLocaleString()}
              </span>
            </div>
          </div>

          <div className="detail-card full-width notes-card">
            <h3>Case Notes</h3>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Add notes about this case..."
              rows="6"
            />
            <button 
              onClick={handleSaveNotes} 
              className="btn-save"
              disabled={saving}
            >
              {saving ? 'Saving...' : 'Save Notes'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CaseDetailsPage
