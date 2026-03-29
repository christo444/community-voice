import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './ParalegalTab.css';

const PARALEGAL_API_URL = 'http://localhost:5001/api';

function ParalegalTab() {
  const [activeView, setActiveView] = useState('applications');
  const [applications, setApplications] = useState([]);
  const [paralegals, setParalegals] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });
  const [showApprovalModal, setShowApprovalModal] = useState(false);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [tempPassword, setTempPassword] = useState('');

  useEffect(() => {
    fetchApplications();
    fetchParalegals();
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
    </div>
  );
}

export default ParalegalTab;