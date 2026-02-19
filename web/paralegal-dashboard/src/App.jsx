import React, { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import ApplyPage from './pages/ApplyPage'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import CaseDetailsPage from './pages/CaseDetailsPage'
import PasswordResetPage from './pages/PasswordResetPage'

function App() {
  const [paralegal, setParalegal] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Check if paralegal is logged in
    const storedParalegal = localStorage.getItem('paralegal')
    if (storedParalegal) {
      setParalegal(JSON.parse(storedParalegal))
    }
    setLoading(false)
  }, [])

  const handleLogin = (paralegalData) => {
    localStorage.setItem('paralegal', JSON.stringify(paralegalData))
    setParalegal(paralegalData)
  }

  const handlePasswordReset = (updatedParalegal) => {
    localStorage.setItem('paralegal', JSON.stringify(updatedParalegal))
    setParalegal(updatedParalegal)
  }

  const handleLogout = () => {
    localStorage.removeItem('paralegal')
    setParalegal(null)
  }

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh' 
      }}>
        Loading...
      </div>
    )
  }

  return (
    <Router>
      <Routes>
        {/* Public routes */}
        <Route path="/apply" element={<ApplyPage />} />
        <Route path="/login" element={paralegal ? <Navigate to="/dashboard" /> : <LoginPage onLogin={handleLogin} />} />
        
        {/* Password Reset Route (protected) */}
        <Route 
          path="/reset-password" 
          element={
            paralegal ? (
              <PasswordResetPage paralegal={paralegal} onPasswordReset={handlePasswordReset} />
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        
        {/* Protected routes */}
        <Route 
          path="/dashboard" 
          element={
            paralegal ? (
              paralegal.must_reset_password ? (
                <Navigate to="/reset-password" />
              ) : (
                <DashboardPage paralegal={paralegal} onLogout={handleLogout} />
              )
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        <Route 
          path="/case/:caseId" 
          element={
            paralegal ? (
              paralegal.must_reset_password ? (
                <Navigate to="/reset-password" />
              ) : (
                <CaseDetailsPage paralegal={paralegal} onLogout={handleLogout} />
              )
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        
        {/* Default route */}
        <Route path="/" element={<Navigate to={paralegal ? "/dashboard" : "/apply"} />} />
      </Routes>
    </Router>
  )
}

export default App
