import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './ParalegalTab.css';

const PARALEGAL_API_URL = 'http://localhost:5001/api';

function ParalegalTab() {
  const [activeView, setActiveView] = useState('applications');
  const [applications, setApplications] = useState([]);
  const [paralegals, setParalegals] = useState([]);
  const [users, setUsers] = useState([]);
  const [cases, setCases] = useState([]);
  const [casesSummary, setCasesSummary] = useState({});
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });
  const [showApprovalModal, setShowApprovalModal] = useState(false);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [tempPassword, setTempPassword] = useState('');
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [selectedParalegal, setSelectedParalegal] = useState('');
  const [showReassignModal, setShowReassignModal] = useState(false);
  const [selectedCase, setSelectedCase] = useState(null);
  const [caseStatusFilter, setCaseStatusFilter] = useState('all');

  useEffect(() => {
    fetchApplications();
    fetchParalegals();
    fetchUsers();
    fetchCases();
    fetchCasesSummary();
  }, []);

  const fetchApplications = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`${PARALEGAL_API_URL}/paralegal/requests?status=pending`);
      setApplications(response.data.data || []);
    } catch (error) {
      console.error('Error fetching applications:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchParalegals = async () => {
    try {
      const response = await axios.get(`${PARALEGAL_API_URL}/paralegals`);
      setParalegals(response.data.data || []);
    } catch (error) {
      console.error('Error fetching paralegals:', error);
    }
  };

  const fetchUsers = async () => {
    try {
      const response = await axios.get(`${PARALEGAL_API_URL}/users`);
      setUsers(response.data.data || []);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const fetchCases = async () => {
    try {
      const response = await axios.get(`${PARALEGAL_API_URL}/cases`);
      setCases(response.data.data || []);
    } catch (error) {
      console.error('Error fetching cases:', error);
    }
  };

  const fetchCasesSummary = async () => {
    try {
      const response = await axios.get(`${PARALEGAL_API_URL}/cases-summary`);
      setCasesSummary(response.data.data || {});
    } catch (error) {
      console.error('Error fetching cases summary:', error);
    }
  };

  const handleApprove = async (request) => {
    setSelectedRequest(request);
    
    try {
      const response = await axios.post(
        `${PARALEGAL_API_URL}/paralegal/requests/${request.id}/approve`,
        { admin_email: 'admin@communityvoice.com' }
      );

      if (response.data.success) {
        setTempPassword(response.data.temporary_password);
        setShowApprovalModal(true);
        setMessage({ 
          text: `Approved successfully! Use this password: ${response.data.temporary_password}`, 
          type: 'success' 
        });
        fetchApplications();
        fetchParalegals();
      }
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.error || 'Error approving application', 
        type: 'error' 
      });
    }
  };

  const handleReject = async (requestId) => {
    const reason = prompt('Enter rejection reason (optional):');
    
    try {
      await axios.post(
        `${PARALEGAL_API_URL}/paralegal/requests/${requestId}/reject`,
        { 
          rejection_reason: reason,
          admin_email: 'admin@communityvoice.com'
        }
      );

      setMessage({ text: 'Application rejected', type: 'success' });
      fetchApplications();
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.error || 'Error rejecting application', 
        type: 'error' 
      });
    }
  };

  const handleToggleStatus = async (paralegalId, currentStatus) => {
    try {
      await axios.post(
        `${PARALEGAL_API_URL}/paralegals/${paralegalId}/toggle-status`,
        { is_active: !currentStatus }
      );

      setMessage({ text: 'Status updated successfully', type: 'success' });
      fetchParalegals();
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.error || 'Error updating status', 
        type: 'error' 
      });
    }
  };

  const handleAssignCase = async () => {
    if (!selectedParalegal || !selectedUser) {
      setMessage({ text: 'Please select both paralegal and user', type: 'error' });
      return;
    }

    try {
      await axios.post(`${PARALEGAL_API_URL}/cases`, {
        paralegal_id: selectedParalegal,
        user_phone_number: selectedUser.phone_number
      });

      setMessage({ text: 'Case assigned successfully', type: 'success' });
      setShowAssignModal(false);
      setSelectedParalegal('');
      setSelectedUser(null);
      fetchCases();
      fetchCasesSummary();
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.error || 'Error assigning case', 
        type: 'error' 
      });
    }
  };

  const handleReassignCase = async () => {
    if (!selectedParalegal || !selectedCase) {
      setMessage({ text: 'Please select a paralegal', type: 'error' });
      return;
    }

    try {
      await axios.post(`${PARALEGAL_API_URL}/cases/${selectedCase.id}/reassign`, {
        paralegal_id: selectedParalegal,
        admin_email: 'admin@communityvoice.com'
      });

      setMessage({ text: 'Case reassigned successfully', type: 'success' });
      setShowReassignModal(false);
      setSelectedParalegal('');
      setSelectedCase(null);
      fetchCases();
      fetchCasesSummary();
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.error || 'Error reassigning case', 
        type: 'error' 
      });
    }
  };

  const handleAdminStatusUpdate = async (caseId, newStatus) => {
    try {
      await axios.put(`${PARALEGAL_API_URL}/cases/${caseId}`, {
        status: newStatus
      });
      fetchCases();
      fetchCasesSummary();
    } catch (error) {
      setMessage({ text: 'Error updating status', type: 'error' });
    }
  };

  const handleInlineReassign = async (caseId, newParalegalId) => {
    if (!newParalegalId) return;
    try {
      await axios.post(`${PARALEGAL_API_URL}/cases/${caseId}/reassign`, {
        paralegal_id: newParalegalId,
        admin_email: 'admin'
      });
      fetchCases();
      fetchCasesSummary();
      setMessage({ text: 'Case reassigned successfully', type: 'success' });
    } catch (error) {
      setMessage({ text: 'Error reassigning case', type: 'error' });
    }
  };

  return (
    <div className="paralegal-tab">
      <div className="tab-header">
        <h2>Paralegal Management</h2>
        <div className="tab-buttons">
          <button 
            className={activeView === 'applications' ? 'active' : ''}
            onClick={() => setActiveView('applications')}
          >
            Applications ({applications.length})
          </button>
          <button 
            className={activeView === 'paralegals' ? 'active' : ''}
            onClick={() => setActiveView('paralegals')}
          >
            Approved Paralegals ({paralegals.length})
          </button>
          <button 
            className={activeView === 'cases' ? 'active' : ''}
            onClick={() => setActiveView('cases')}
          >
            Case Management
          </button>
          <button 
            className={activeView === 'assign' ? 'active' : ''}
            onClick={() => setActiveView('assign')}
          >
            Assign Cases
          </button>
        </div>
      </div>

      {message.text && (
        <div className={`message ${message.type}`}>
          {message.text}
        </div>
      )}

      {/* Applications View */}
      {activeView === 'applications' && (
        <div className="applications-view">
          <h3>Pending Applications</h3>
          {loading ? (
            <div className="loading">Loading...</div>
          ) : applications.length === 0 ? (
            <div className="no-data">No pending applications</div>
          ) : (
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Qualification</th>
                    <th>Phone</th>
                    <th>Applied On</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {applications.map((app) => (
                    <tr key={app.id}>
                      <td>{app.name}</td>
                      <td>{app.email}</td>
                      <td>{app.qualification}</td>
                      <td>{app.phone_number || 'N/A'}</td>
                      <td>{new Date(app.created_at).toLocaleDateString()}</td>
                      <td>
                        <button onClick={() => handleApprove(app)} className="btn btn-approve">Approve</button>
                        <button onClick={() => handleReject(app.id)} className="btn btn-reject">Reject</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* Approved Paralegals View */}
      {activeView === 'paralegals' && (
        <div className="paralegals-view">
          <h3>Approved Paralegals</h3>
          {paralegals.length === 0 ? (
            <div className="no-data">No approved paralegals yet</div>
          ) : (
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Qualification</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Joined On</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {paralegals.map((paralegal) => (
                    <tr key={paralegal.id}>
                      <td>{paralegal.name}</td>
                      <td>{paralegal.email}</td>
                      <td>{paralegal.qualification}</td>
                      <td>{paralegal.phone_number || 'N/A'}</td>
                      <td>
                        <span className={`status-badge ${paralegal.is_active ? 'active' : 'inactive'}`}>
                          {paralegal.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td>{new Date(paralegal.created_at).toLocaleDateString()}</td>
                      <td>
                        <button
                          onClick={() => handleToggleStatus(paralegal.id, paralegal.is_active)}
                          className="btn btn-toggle"
                        >
                          {paralegal.is_active ? 'Deactivate' : 'Activate'}
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

      {/* Assign Cases View */}
      {activeView === 'assign' && (
        <div className="assign-view">
          <h3>Assign Cases to Paralegals</h3>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>User Name</th>
                  <th>Phone Number</th>
                  <th>Age</th>
                  <th>Gender</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => {
                  const activeCase = cases.find(c => c.user_phone_number === user.phone_number && c.status !== 'completed');
                  return (
                    <tr key={user.phone_number}>
                      <td>{user.name || 'N/A'}</td>
                      <td>{user.phone_number}</td>
                      <td>{user.age || 'N/A'}</td>
                      <td>{user.gender || 'N/A'}</td>
                      <td>
                        {activeCase ? (
                          <button disabled className="btn" style={{backgroundColor: '#ccc', color: '#666', opacity: 0.8, border: '1px solid #999'}}>Assigned</button>
                        ) : (
                          <button
                            onClick={() => {
                              setSelectedUser(user);
                              setShowAssignModal(true);
                            }}
                            className="btn btn-primary"
                          >
                            Assign to Paralegal
                          </button>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Case Management View */}
      {activeView === 'cases' && (
        <div className="cases-view">
          <h3>User Scheme Requests</h3>
          
          {/* Case Statistics */}
          <div className="stats-container">
            <div className="stat-card">
              <h4>Total Cases</h4>
              <p className="stat-number">{casesSummary.total_cases || 0}</p>
            </div>
            <div className="stat-card">
              <h4>Open</h4>
              <p className="stat-number stat-open">{casesSummary.by_status?.open || 0}</p>
            </div>
            <div className="stat-card">
              <h4>In Progress</h4>
              <p className="stat-number stat-progress">{casesSummary.by_status?.in_progress || 0}</p>
            </div>
            <div className="stat-card">
              <h4>Completed</h4>
              <p className="stat-number stat-completed">{casesSummary.by_status?.completed || 0}</p>
            </div>
          </div>

          {/* Case Status Filter */}
          <div className="filter-container">
            <label>Filter by Status:</label>
            <select value={caseStatusFilter} onChange={(e) => setCaseStatusFilter(e.target.value)}>
              <option value="all">All Cases</option>
              <option value="open">Open</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
            </select>
          </div>

          {/* Cases Table */}
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>User Name</th>
                  <th>Phone</th>
                  <th>Address</th>
                  <th>Scheme</th>
                  <th>Assigned Paralegal</th>
                  <th>Status</th>
                  <th>Reassign</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {cases
                  .filter(c => caseStatusFilter === 'all' || c.status === caseStatusFilter)
                  .map((caseItem) => {
                    const paralegal = paralegals.find(p => p.id === caseItem.paralegal_id);
                    const address = caseItem.profile?.address || caseItem.profile?.state_district || 'N/A';
                    return (
                      <tr key={caseItem.id}>
                        <td>
                          {caseItem.profile?.name || 'Unknown'}
                        </td>
                        <td>{caseItem.user_phone_number}</td>
                        <td style={{maxWidth: '150px', whiteSpace: 'normal', fontSize: '0.9em'}}>{address}</td>
                        <td>General Assistance</td>
                        <td>{paralegal?.name || 'Unassigned'}</td>
                        <td>
                          <span className={`status-badge status-${caseItem.status}`}>
                            {caseItem.status === 'in_progress' ? 'In Progress' : caseItem.status.charAt(0).toUpperCase() + caseItem.status.slice(1)}
                          </span>
                        </td>
                        <td>
                          <select 
                            value="" 
                            onChange={(e) => handleInlineReassign(caseItem.id, e.target.value)}
                            style={{padding: '4px', borderRadius: '4px', border: '1px solid #ddd'}}
                          >
                            <option value="" disabled>Select Paralegal</option>
                            {paralegals.filter(p => p.is_active && p.id !== caseItem.paralegal_id).map(p => (
                              <option key={p.id} value={p.id}>{p.name}</option>
                            ))}
                          </select>
                        </td>
                        <td style={{display: 'flex', flexDirection: 'column', gap: '5px'}}>
                          <button
                            onClick={() => handleAdminStatusUpdate(caseItem.id, 'in_progress')}
                            className="btn"
                            style={{backgroundColor: '#8B0000', color: 'white', padding: '4px 8px', fontSize: '0.8em', border: 'none', borderRadius: '4px', cursor: 'pointer'}}
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => handleAdminStatusUpdate(caseItem.id, 'completed')}
                            className="btn"
                            style={{backgroundColor: '#28a745', color: 'white', padding: '4px 8px', fontSize: '0.8em', border: 'none', borderRadius: '4px', cursor: 'pointer'}}
                          >
                            Complete
                          </button>
                        </td>
                      </tr>
                    );
                  })}
              </tbody>
            </table>
          </div>

          {/* Paralegal Workload Summary */}
          <div className="workload-section">
            <h4>Paralegal Workload</h4>
            <div className="workload-cards">
              {Object.entries(casesSummary.by_paralegal || {}).map(([paralegalId, stats]) => (
                <div key={paralegalId} className="workload-card">
                  <h5>{stats.name}</h5>
                  <p className="email">{stats.email}</p>
                  <div className="workload-stats">
                    <div>Total: <strong>{stats.total}</strong></div>
                    <div>Open: <strong className="text-open">{stats.open}</strong></div>
                    <div>In Progress: <strong className="text-progress">{stats.in_progress}</strong></div>
                    <div>Completed: <strong className="text-completed">{stats.completed}</strong></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Approval Modal */}
      {showApprovalModal && (
        <div className="modal-overlay" onClick={() => setShowApprovalModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3>Paralegal Approved!</h3>
            <p><strong>Email:</strong> {selectedRequest?.email}</p>
            <p><strong>Temporary Password:</strong></p>
            <div className="password-box">{tempPassword}</div>
            <p className="note">Please share this password with the paralegal. They should change it upon first login.</p>
            <button onClick={() => setShowApprovalModal(false)} className="btn btn-primary">Close</button>
          </div>
        </div>
      )}

      {/* Assign Case Modal */}
      {showAssignModal && (
        <div className="modal-overlay" onClick={() => setShowAssignModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3>Assign Case</h3>
            <p><strong>User:</strong> {selectedUser?.name} ({selectedUser?.phone_number})</p>
            <div className="form-group">
              <label>Select Paralegal:</label>
              <select value={selectedParalegal} onChange={(e) => setSelectedParalegal(e.target.value)}>
                <option value="">-- Select a Paralegal --</option>
                {paralegals.filter(p => p.is_active).map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name} - {p.email}
                  </option>
                ))}
              </select>
            </div>
            <div className="modal-actions">
              <button onClick={handleAssignCase} className="btn btn-primary">Assign</button>
              <button onClick={() => setShowAssignModal(false)} className="btn btn-secondary">Cancel</button>
            </div>
          </div>
        </div>
      )}

      {/* Reassign Case Modal */}
      {showReassignModal && (
        <div className="modal-overlay" onClick={() => setShowReassignModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3>Reassign Case</h3>
            <p><strong>User:</strong> {selectedCase?.profile?.name} ({selectedCase?.user_phone_number})</p>
            <p><strong>Current Paralegal:</strong> {paralegals.find(p => p.id === selectedCase?.paralegal_id)?.name || 'Unassigned'}</p>
            <div className="form-group">
              <label>Select New Paralegal:</label>
              <select value={selectedParalegal} onChange={(e) => setSelectedParalegal(e.target.value)}>
                <option value="">-- Select a Paralegal --</option>
                {paralegals.filter(p => p.is_active && p.id !== selectedCase?.paralegal_id).map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name} - {p.email}
                  </option>
                ))}
              </select>
            </div>
            <div className="modal-actions">
              <button onClick={handleReassignCase} className="btn btn-primary">Reassign</button>
              <button onClick={() => setShowReassignModal(false)} className="btn btn-secondary">Cancel</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default ParalegalTab;
