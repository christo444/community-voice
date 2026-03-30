import React, { useState, useEffect } from 'react';
import axios from 'axios';
import ParalegalTab from './components/ParalegalTab';
import Login from './components/Login';

const API_URL = 'http://localhost:5000/api/schemes';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [admin, setAdmin] = useState(null);
  const [activeTab, setActiveTab] = useState('schemes');
  const [schemes, setSchemes] = useState([]);
  const [selectedFile, setSelectedFile] = useState(null);
  const [schemeUrl, setSchemeUrl] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [isExtracting, setIsExtracting] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });
  const [isLoading, setIsLoading] = useState(true);

  // Check for existing admin session on mount
  useEffect(() => {
    const storedAdmin = localStorage.getItem('admin');
    if (storedAdmin) {
      try {
        const adminData = JSON.parse(storedAdmin);
        setAdmin(adminData);
        setIsAuthenticated(true);
      } catch (err) {
        console.error('Error parsing stored admin data:', err);
        localStorage.removeItem('admin');
      }
    }
  }, []);

  // Fetch schemes on component mount (only when authenticated)
  useEffect(() => {
    if (isAuthenticated) {
      fetchSchemes();
    }
  }, [isAuthenticated]);

  // Fetch all schemes from API
  const fetchSchemes = async () => {
    try {
      setIsLoading(true);
      const response = await axios.get(API_URL);
      setSchemes(response.data.data);
      setIsLoading(false);
    } catch (error) {
      console.error('Error fetching schemes:', error);
      setMessage({ text: 'Error loading schemes', type: 'error' });
      setIsLoading(false);
    }
  };

  // Handle file selection
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file && file.type === 'application/pdf') {
      setSelectedFile(file);
      setMessage({ text: '', type: '' });
    } else {
      setSelectedFile(null);
      setMessage({ text: 'Please select a PDF file', type: 'error' });
    }
  };

  // Handle file upload
  const handleUpload = async () => {
    if (!selectedFile) {
      setMessage({ text: 'Please select a PDF file first', type: 'error' });
      return;
    }

    const formData = new FormData();
    formData.append('file', selectedFile);

    try {
      setIsUploading(true);
      setMessage({ text: '', type: '' });

      const response = await axios.post(`${API_URL}/upload`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setMessage({ text: 'Scheme uploaded successfully!', type: 'success' });
      setSelectedFile(null);
      
      // Reset file input
      document.getElementById('file-input').value = '';
      
      // Refresh schemes list
      fetchSchemes();
      
      setIsUploading(false);
    } catch (error) {
      console.error('Error uploading file:', error);
      setMessage({ 
        text: error.response?.data?.error || 'Error uploading file', 
        type: 'error' 
      });
      setIsUploading(false);
    }
  };

  // Handle URL extraction
  const handleExtractUrl = async () => {
    if (!schemeUrl.trim()) {
      setMessage({ text: 'Please enter a website URL', type: 'error' });
      return;
    }

    if (!schemeUrl.startsWith('http')) {
      setMessage({ text: 'URL must start with http:// or https://', type: 'error' });
      return;
    }

    try {
      setIsExtracting(true);
      setMessage({ text: '', type: '' });

      const response = await axios.post(`${API_URL}/extract-url`, {
        url: schemeUrl
      });

      setMessage({ text: 'Scheme extracted from URL successfully!', type: 'success' });
      setSchemeUrl('');
      
      // Refresh schemes list
      fetchSchemes();
      
      setIsExtracting(false);
    } catch (error) {
      console.error('Error extracting from URL:', error);
      setMessage({ 
        text: error.response?.data?.error || 'Error extracting from URL', 
        type: 'error' 
      });
      setIsExtracting(false);
    }
  };

  // Handle delete scheme
  const handleDelete = async (schemeId) => {
    if (!window.confirm('Are you sure you want to delete this scheme?')) {
      return;
    }

    try {
      await axios.delete(`${API_URL}/${schemeId}`);
      setMessage({ text: 'Scheme deleted successfully', type: 'success' });
      fetchSchemes();
    } catch (error) {
      console.error('Error deleting scheme:', error);
      setMessage({ text: 'Error deleting scheme', type: 'error' });
    }
  };

  // Handle login success
  const handleLoginSuccess = (adminData) => {
    setAdmin(adminData);
    setIsAuthenticated(true);
  };

  // Handle logout
  const handleLogout = () => {
    localStorage.removeItem('admin');
    setAdmin(null);
    setIsAuthenticated(false);
    setActiveTab('schemes');
  };

  // Show login page if not authenticated
  if (!isAuthenticated) {
    return <Login onLoginSuccess={handleLoginSuccess} />;
  }

  return (
    <div className="container">
      <div className="dashboard-header">
        <div>
          <h1>Admin Dashboard</h1>
          <p className="subtitle">Community Voice Management Portal</p>
        </div>
        <div className="admin-info">
          <span className="admin-name">👤 {admin?.full_name || 'Admin'}</span>
          <button onClick={handleLogout} className="btn btn-logout">
            Logout
          </button>
        </div>
      </div>

      {/* Tab Navigation */}
      <div className="main-tabs">
        <button 
          className={activeTab === 'schemes' ? 'tab-btn active' : 'tab-btn'}
          onClick={() => setActiveTab('schemes')}
        >
          📄 Schemes
        </button>
        <button 
          className={activeTab === 'paralegals' ? 'tab-btn active' : 'tab-btn'}
          onClick={() => setActiveTab('paralegals')}
        >
          🏛️ Paralegals
        </button>
      </div>

      {/* Schemes Tab Content */}
      {activeTab === 'schemes' && (
        <div className="tab-content">
          {/* Upload Section */}
          <div className="upload-section">
        <div className="upload-header">
          <h3>Add New Scheme</h3>
        </div>
        <div className="upload-form">
          <input
            id="file-input"
            type="file"
            accept=".pdf"
            onChange={handleFileChange}
            className="file-input"
            disabled={isUploading || isExtracting}
          />
          <button
            onClick={handleUpload}
            disabled={!selectedFile || isUploading || isExtracting}
            className="btn btn-primary"
          >
            {isUploading ? 'Uploading...' : 'Upload PDF'}
          </button>
        </div>

        <div style={{ textAlign: 'center', margin: '15px 0', color: '#888', fontWeight: 'bold' }}>— OR —</div>

        <div className="upload-form">
          <input
            type="text"
            placeholder="Paste government scheme URL here..."
            value={schemeUrl}
            onChange={(e) => setSchemeUrl(e.target.value)}
            className="file-input"
            disabled={isUploading || isExtracting}
          />
          <button
            onClick={handleExtractUrl}
            disabled={!schemeUrl || isUploading || isExtracting}
            className="btn btn-secondary"
          >
            {isExtracting ? 'Extracting...' : 'Extract URL'}
          </button>
        </div>

        {message.text && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}
      </div>

      {/* Schemes List */}
      <div className="schemes-list">
        <h2>Saved Schemes</h2>
        
        {isLoading ? (
          <div className="loading">Loading schemes...</div>
        ) : schemes.length === 0 ? (
          <div className="no-schemes">
            <p>No schemes uploaded yet. Upload a PDF to get started!</p>
          </div>
        ) : (
          <>
            <div className="schemes-count">
              Total Schemes: {schemes.length}
            </div>
            {schemes.map((scheme) => (
              <div key={scheme.id} className="scheme-card">
                <div className="scheme-header">
                  <div>
                    <div className="scheme-title">{scheme.schemeName || 'Untitled Scheme'}</div>
                    <div className="scheme-meta">
                      Uploaded: {new Date(scheme.uploadedAt).toLocaleDateString()} | 
                      File: {scheme.pdfFileName}
                    </div>
                  </div>
                  <button
                    onClick={() => handleDelete(scheme.id)}
                    className="btn btn-danger"
                  >
                    Delete
                  </button>
                </div>

                {scheme.benefits && (
                  <div className="scheme-section">
                    <div className="section-label">Benefits:</div>
                    <div className="section-content">{scheme.benefits}</div>
                  </div>
                )}

                {scheme.eligibility && scheme.eligibility.length > 0 && (
                  <div className="scheme-section">
                    <div className="section-label">Eligibility Criteria:</div>
                    <ul className="section-list">
                      {scheme.eligibility.map((item, idx) => (
                        <li key={idx}>{item}</li>
                      ))}
                    </ul>
                  </div>
                )}

                {scheme.documentsRequired && scheme.documentsRequired.length > 0 && (
                  <div className="scheme-section">
                    <div className="section-label">Documents Required:</div>
                    <ul className="section-list">
                      {scheme.documentsRequired.map((item, idx) => (
                        <li key={idx}>{item}</li>
                      ))}
                    </ul>
                  </div>
                )}

                {scheme.applicationProcess && scheme.applicationProcess.length > 0 && (
                  <div className="scheme-section">
                    <div className="section-label">Application Process:</div>
                    <ul className="section-list">
                      {scheme.applicationProcess.map((item, idx) => (
                        <li key={idx}>{item}</li>
                      ))}
                    </ul>
                  </div>
                )}

                {scheme.exclusions && scheme.exclusions.length > 0 && (
                  <div className="scheme-section">
                    <div className="section-label">Exclusions:</div>
                    <ul className="section-list">
                      {scheme.exclusions.map((item, idx) => (
                        <li key={idx}>{item}</li>
                      ))}
                    </ul>
                  </div>
                )}

                {scheme.sourceUrl && (
                  <div className="scheme-section">
                    <div className="section-label">Source URL:</div>
                    <div className="section-content">
                      <a href={scheme.sourceUrl} target="_blank" rel="noopener noreferrer">
                        {scheme.sourceUrl}
                      </a>
                    </div>
                  </div>
                )}

                {scheme.rawText && (
                  <div className="scheme-section">
                    <div className="section-label">Raw Text Preview:</div>
                    <div className="raw-text">{scheme.rawText}</div>
                  </div>
                )}
              </div>
            ))}
          </>
        )}
      </div>
        </div>
      )}

      {/* Paralegals Tab Content */}
      {activeTab === 'paralegals' && (
        <div className="tab-content">
          <ParalegalTab />
        </div>
      )}
    </div>
  );
}

export default App;
