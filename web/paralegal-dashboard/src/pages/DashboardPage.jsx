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

      // Fetch cases using Backend API instead of direct Supabase to bypass RLS
      const response = await axios.get(`${PARALEGAL_API_URL}/cases?paralegal_id=${paralegal.id}`);
      const casesData = response.data.data;

      setCases(casesData || [])

      // Calculate stats
      const total = casesData?.length || 0
      const open = casesData?.filter(c => c.status === 'open').length || 0
      const in_progress = casesData?.filter(c => c.status === 'in_progress').length || 0
      const completed = casesData?.filter(c => c.status === 'completed').length || 0

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
    const reason = window.prompt('Reason for rejection (optional):')
    
    try {
      const response = await axios.put(
        `${PARALEGAL_API_URL}/cases/${caseId}`,
        {
          paralegal_id: paralegal.id,
          status: 'completed',
          notes: reason ? `Rejected: ${reason}` : 'Rejected'
        }
      )

      if (response.data.success) {
        alert('Case rejected')
        fetchCases()
      }
    } catch (error) {
      console.error('Error rejecting case:', error)
      alert(error.response?.data?.error || 'Failed to reject case')
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
          <div className="stat-card stat-total">
            <h3>{stats.total}</h3>
            <p>Total Cases</p>
          </div>
          <div className="stat-card stat-open">
            <h3>{stats.open}</h3>
            <p>New Requests</p>
          </div>
          <div className="stat-card stat-progress">
            <h3>{stats.in_progress}</h3>
            <p>In Progress</p>
          </div>
          <div className="stat-card stat-completed">
            <h3>{stats.completed}</h3>
            <p>Completed</p>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="tabs">
          <button 
            className={activeTab === 'requests' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('requests')}
          >
            📋 New Requests ({openCases.length})
          </button>
          <button 
            className={activeTab === 'approved' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('approved')}
          >
            ✅ Approved ({activeCases.length})
          </button>
          <button 
            className={activeTab === 'completed' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('completed')}
          >
            ✓ Completed ({completedCases.length})
          </button>
          <button 
            className={activeTab === 'contact' ? 'tab-btn active' : 'tab-btn'}
            onClick={() => setActiveTab('contact')}
          >
            📞 Contact
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
                        const address = caseItem.profile?.address || caseItem.profile?.state_district || 'N/A';
                        return (
                        <div key={caseItem.id} className="case-card" style={{border: '1px solid #ddd', borderRadius: '8px', padding: '15px', position: 'relative'}}>
                          <div className="case-header" style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px'}}>
                            <h3 style={{margin: 0, fontSize: '1.2rem'}}>{caseItem.profile?.name || 'Unknown User'}</h3>
                            <span className="badge" style={{backgroundColor: '#fff3cd', color: '#856404', padding: '4px 8px', borderRadius: '12px', fontSize: '0.8rem', fontWeight: 'bold'}}>NEW</span>
                          </div>
                          <div className="case-body" style={{fontSize: '0.9rem', color: '#444'}}>
                            <div className="case-info">
                              <p style={{margin: '5px 0'}}><strong>Scheme:</strong> General Assistance</p>
                              <p style={{margin: '5px 0'}}><strong>Phone:</strong> {caseItem.user_phone_number}</p>
                              <p style={{margin: '5px 0'}}><strong>Address:</strong> {address}</p>
                              <p style={{margin: '5px 0'}}><strong>Age:</strong> {caseItem.profile?.age || 'N/A'}</p>
                              <p style={{margin: '5px 0'}}><strong>Gender:</strong> {caseItem.profile?.gender || 'N/A'}</p>
                              <p style={{margin: '5px 0'}}><strong>Assigned:</strong> {new Date(caseItem.assigned_at).toLocaleDateString()}</p>
                            </div>
                          </div>
                          <div className="case-actions" style={{display: 'flex', gap: '10px', marginTop: '15px'}}>
                            <button 
                              className="btn"
                              style={{backgroundColor: '#28a745', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', flex: 1, cursor: 'pointer', fontWeight: 'bold'}}
                              onClick={() => handleAcceptCase(caseItem.id)}
                            >
                              ✓ Approve
                            </button>
                            <button 
                              className="btn"
                              style={{backgroundColor: '#dc3545', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', flex: 1, cursor: 'pointer', fontWeight: 'bold'}}
                              onClick={() => handleRejectCase(caseItem.id)}
                            >
                              ✗ Reject
                            </button>
                            <button 
                              className="btn"
                              style={{backgroundColor: '#4A0000', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', flex: 1, cursor: 'pointer', fontWeight: 'bold'}}
                              onClick={() => navigate(`/case/${caseItem.id}`)}
                            >
                              👁 View
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
                            <th>Age</th>
                            <th>Started</th>
                            <th>Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          {activeCases.map((caseItem) => (
                            <tr key={caseItem.id}>
                              <td>{caseItem.profile?.name || 'N/A'}</td>
                              <td>{caseItem.user_phone_number}</td>
                              <td>General Assistance</td>
                              <td>{caseItem.profile?.age || 'N/A'}</td>
                              <td>{new Date(caseItem.assigned_at).toLocaleDateString()}</td>
                              <td style={{display: 'flex', gap: '5px'}}>
                                <button
                                  onClick={() => navigate(`/case/${caseItem.id}`)}
                                  className="btn btn-primary"
                                >
                                  Manage
                                </button>
                                <button
                                  onClick={async () => {
                                    if(window.confirm('Mark this case as completed?')) {
                                      try {
                                        await axios.put(`${PARALEGAL_API_URL}/cases/${caseItem.id}`, { status: 'completed' });
                                        fetchCases();
                                      } catch (err) {}
                                    }
                                  }}
                                  className="btn btn-success"
                                  style={{backgroundColor: '#28a745', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold'}}
                                >
                                  ✓ Complete
                                </button>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}

              {/* Completed Cases Tab */}
              {activeTab === 'completed' && (
                <div className="completed-section">
                  <h2>Completed Cases</h2>
                  <p className="section-desc">Your case history and completed work</p>
                  
                  {completedCases.length === 0 ? (
                    <div className="no-data">
                      <p>📋 No completed cases yet</p>
                      <p>Your completed work will appear here</p>
                    </div>
                  ) : (
                    <div className="cases-table">
                      <table>
                        <thead>
                          <tr>
                            <th>User Name</th>
                            <th>Phone</th>
                            <th>Completed On</th>
                            <th>Notes</th>
                            <th>Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          {completedCases.map((caseItem) => (
                            <tr key={caseItem.id}>
                              <td>{caseItem.profile?.name || 'N/A'}</td>
                              <td>{caseItem.user_phone_number}</td>
                              <td>{new Date(caseItem.updated_at).toLocaleDateString()}</td>
                              <td>{caseItem.notes ? caseItem.notes.substring(0, 50) + '...' : 'No notes'}</td>
                              <td>
                                <button
                                  onClick={() => navigate(`/case/${caseItem.id}`)}
                                  className="btn btn-secondary"
                                >
                                  View
                                </button>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}

              {/* Contact Tab */}
              {activeTab === 'contact' && (
                <div className="contact-section">
                  <h2>Contact & Support</h2>
                  <p className="section-desc">Get help and contact information</p>
                  
                  <div className="contact-grid">
                    <div className="contact-card">
                      <h3>📧 Email Support</h3>
                      <p>admin@communityvoice.org</p>
                      <p className="help-text">For general inquiries and support</p>
                    </div>
                    
                    <div className="contact-card">
                      <h3>📞 Phone Support</h3>
                      <p>+91 1800-XXX-XXXX</p>
                      <p className="help-text">Mon-Fri, 9 AM - 6 PM</p>
                    </div>
                    
                    <div className="contact-card">
                      <h3>🏛️ Admin Dashboard</h3>
                      <p>Contact your admin for:</p>
                      <ul>
                        <li>Case assignment issues</li>
                        <li>Account access problems</li>
                        <li>Technical difficulties</li>
                      </ul>
                    </div>
                    
                    <div className="contact-card">
                      <h3>📚 Resources</h3>
                      <ul>
                        <li><a href="#">Paralegal Guidelines</a></li>
                        <li><a href="#">Case Management Manual</a></li>
                        <li><a href="#">FAQ</a></li>
                        <li><a href="#">Best Practices</a></li>
                      </ul>
                    </div>
                  </div>

                  <div className="profile-info">
                    <h3>Your Profile</h3>
                    <div className="profile-details">
                      <p><strong>Name:</strong> {paralegal.name}</p>
                      <p><strong>Email:</strong> {paralegal.email}</p>
                      <p><strong>Qualification:</strong> {paralegal.qualification}</p>
                      {paralegal.phone_number && (
                        <p><strong>Phone:</strong> {paralegal.phone_number}</p>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default DashboardPage
