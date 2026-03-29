import React, { useState, useEffect } from 'react'
import { supabase } from '../utils/supabase'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import './DashboardPage.css'

const PARALEGAL_API_URL = 'http://localhost:5001/api'

function DashboardPage({ paralegal, onLogout }) {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('requests')
  const [cases, setCases] = useState([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    total: 0,
    open: 0,
    in_progress: 0,
    completed: 0
  })

  useEffect(() => {
    fetchCases()
  }, [paralegal])

  const fetchCases = async () => {
    try {
      setLoading(true)

      // Fetch cases assigned to me
      const myCasesRes = await axios.get(`${PARALEGAL_API_URL}/cases?paralegal_id=${paralegal.id}`);
      const myCases = myCasesRes.data.data || [];

      // Fetch unassigned user requests (excluding ones I rejected)
      const availableRes = await axios.get(`${PARALEGAL_API_URL}/cases?unassigned=true&paralegal_id=${paralegal.id}`);
      const availableCases = availableRes.data.data || [];

      // Combine them
      const allCases = [...availableCases, ...myCases];
      
      // Sort: Open requests first, then by date (assigned_at or created_at)
      allCases.sort((a, b) => {
          if (a.status === 'open' && b.status !== 'open') return -1;
          if (a.status !== 'open' && b.status === 'open') return 1;
          
          const dateA = new Date(a.created_at || a.assigned_at);
          const dateB = new Date(b.created_at || b.assigned_at);
          return dateB - dateA;
      });

      setCases(allCases)

      // Calculate stats
      const total = allCases.length
      const open = availableCases.length // Open requests
      const in_progress = myCases.filter(c => c.status === 'in_progress').length
      const completed = myCases.filter(c => c.status === 'completed').length

      setStats({ total, open, in_progress, completed })
    } catch (error) {
      console.error('Error fetching cases:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = () => {
    if (onLogout) onLogout()
    navigate('/login')
  }

  const getStatusBadge = (status) => {
    const badges = {
      open: 'status-open',
      in_progress: 'status-progress',
      completed: 'status-completed'
    }
    return badges[status] || 'status-open'
  }

  const handleAcceptCase = async (caseId) => {
    if (!window.confirm('Accept this case?')) return

    try {
      const response = await axios.put(
        `${PARALEGAL_API_URL}/cases/${caseId}`,
        {
          paralegal_id: paralegal.id,
          status: 'in_progress'
        }
      )

      if (response.data.success) {
        alert('Case accepted!')
        fetchCases()
      }
    } catch (error) {
      console.error('Error accepting case:', error)
      alert(error.response?.data?.error || 'Failed to accept case')
    }
  }

  const handleRejectCase = async (caseId) => {
    // Check if it's an unassigned request or an active case
    const caseItem = cases.find(c => c.id === caseId)
    if (!caseItem) return

    if (caseItem.status === 'open') {
        // It's a new request - just hide it from me
        if (!window.confirm('Reject and hide this request?')) return
        try {
            const response = await axios.post(
                `${PARALEGAL_API_URL}/cases/${caseId}/reject`,
                {
                    paralegal_id: paralegal.id,
                    reason: 'Declined by paralegal'
                }
            )
            if (response.data.success) {
                alert('Request removed from your view')
                fetchCases()
            }
        } catch (error) {
            console.error('Error rejecting request:', error)
            alert('Failed to reject request')
        }
    } else {
        // It's an active case - mark as rejected/completed?
        // Existing logic for "Reject" on active cases seems weird (why reject active?)
        // Maybe "Drop case"? For now I'll keep the old logic but clarify it's for non-open cases.
        const reason = window.prompt('Reason for rejection (optional):')
        if (!reason && reason !== '') return // User cancelled prompt
        
        try {
            const response = await axios.put(
                `${PARALEGAL_API_URL}/cases/${caseId}`,
                {
                    paralegal_id: paralegal.id,
                    status: 'completed', // or rejected?
                    notes: reason ? `Rejected: ${reason}` : 'Rejected'
                }
            )
    
            if (response.data.success) {
                alert('Case status updated')
                fetchCases()
            }
        } catch (error) {
            console.error('Error updating case:', error)
            alert('Failed to update case')
        }
    }
  }

  // Filter cases by status
  const openCases = cases.filter(c => c.status === 'open')
  const activeCases = cases.filter(c => c.status === 'in_progress')
  const completedCases = cases.filter(c => c.status === 'completed')

  return (
    <div className="dashboard-page">
      <nav className="navbar">
        <div className="nav-content">
          <h2>🏛️ Paralegal Dashboard</h2>
          <div className="nav-actions">
            <span className="user-email">{paralegal.name} ({paralegal.email})</span>
            <button onClick={handleLogout} className="btn-logout">
              Logout
            </button>
          </div>
        </div>
      </nav>

      <div className="dashboard-content">
        {/* Stats Cards */}
        <div className="stats-grid">
          <div className="stat-card stat-open">
            <h3>{stats.open}</h3>
            <p>User Requests</p>
          </div>
          <div className="stat-card stat-progress">
            <h3>{stats.in_progress}</h3>
            <p>Approved</p>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="tabs">
          <button 
            className={activeTab === 'requests' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('requests')}
          >
            📋 User Requests ({openCases.length})
          </button>
          <button 
            className={activeTab === 'approved' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('approved')}
          >
            ✅ Approved ({activeCases.length})
          </button>
        </div>

        {/* Tab Content */}
        <div className="tab-content">
          {loading ? (
            <div className="loading">Loading...</div>
          ) : (
            <>
              {/* New Requests Tab */}
              {activeTab === 'requests' && (
                <div className="requests-section">
                  <h2>New Case Requests</h2>
                  <p className="section-desc">Review and accept new cases assigned to you</p>
                  
                  {openCases.length === 0 ? (
                    <div className="no-data">
                      <p>📭 No new requests at the moment</p>
                      <p>Check back later for new assignments</p>
                    </div>
                  ) : (
                    <div className="cases-grid">
                      {openCases.map((caseItem) => {
                        // Support both new direct fields and old profile fields
                        const name = caseItem.user_name || caseItem.profile?.name || 'Unknown User';
                        const phone = caseItem.user_phone_number || 'N/A';
                        const location = caseItem.location || caseItem.profile?.address || caseItem.profile?.state_district || 'N/A';
                        const scheme = caseItem.scheme_name || 'General Assistance';
                        
                        return (
                        <div key={caseItem.id} className="case-card" style={{border: '1px solid #ddd', borderRadius: '8px', padding: '15px', position: 'relative', background: '#fff'}}>
                          <div className="case-header" style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px'}}>
                            <h3 style={{margin: 0, fontSize: '1.2rem'}}>{name}</h3>
                            <span className="badge" style={{backgroundColor: '#fff3cd', color: '#856404', padding: '4px 8px', borderRadius: '12px', fontSize: '0.8rem', fontWeight: 'bold'}}>NEW REQUEST</span>
                          </div>
                          <div className="case-body" style={{fontSize: '0.9rem', color: '#444'}}>
                            <div className="case-info">
                              <p style={{margin: '5px 0'}}><strong>Scheme:</strong> {scheme}</p>
                              <p style={{margin: '5px 0'}}><strong>Phone:</strong> {phone}</p>
                              <p style={{margin: '5px 0'}}><strong>Place:</strong> {location}</p>
                              <p style={{margin: '5px 0'}}><strong>Received:</strong> {new Date(caseItem.assigned_at || caseItem.created_at).toLocaleString()}</p>
                            </div>
                          </div>
                          <div className="case-actions" style={{display: 'flex', gap: '10px', marginTop: '15px'}}>
                            <button 
                              className="btn"
                              style={{backgroundColor: '#28a745', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', flex: 1, cursor: 'pointer', fontWeight: 'bold'}}
                              onClick={() => handleAcceptCase(caseItem.id)}
                            >
                              ✓ Accept
                            </button>
                            <button 
                              className="btn"
                              style={{backgroundColor: '#dc3545', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', flex: 1, cursor: 'pointer', fontWeight: 'bold'}}
                              onClick={() => handleRejectCase(caseItem.id)}
                            >
                              ✗ Reject
                            </button>
                          </div>
                        </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              )}

              {/* Approved Cases Tab */}
              {activeTab === 'approved' && (
                <div className="approved-section">
                  <h2>Approved Cases</h2>
                  <p className="section-desc">Cases you are currently working on</p>
                  
                  {activeCases.length === 0 ? (
                    <div className="no-data">
                      <p>📂 No active cases</p>
                      <p>Accept new requests to start working</p>
                    </div>
                  ) : (
                    <div className="cases-table">
                      <table>
                        <thead>
                          <tr>
                            <th>User Name</th>
                            <th>Phone</th>
                            <th>Scheme</th>
                            <th>Started</th>
                          </tr>
                        </thead>
                        <tbody>
                          {activeCases.map((caseItem) => {
                            const name = caseItem.user_name || caseItem.profile?.name || 'Unknown User';
                            const phone = caseItem.user_phone_number || 'N/A';
                            const scheme = caseItem.scheme_name || 'General Assistance';
                            
                            return (
                              <tr 
                                key={caseItem.id} 
                                onClick={() => navigate(`/case/${caseItem.id}`)}
                                style={{cursor: 'pointer'}}
                                className="clickable-row"
                              >
                                <td>{name}</td>
                                <td>{phone}</td>
                                <td>{scheme}</td>
                                <td>{new Date(caseItem.assigned_at).toLocaleDateString()}</td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}

              {/* Completed Cases Tab - Removed */}


              {/* Contact Tab - Removed */}

            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default DashboardPage
