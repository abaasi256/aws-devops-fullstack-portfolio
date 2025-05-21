import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const PrivateRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  
  // If auth is still loading, don't render anything yet
  if (loading) return <div>Loading...</div>;
  
  // If not authenticated, redirect to login
  if (!isAuthenticated) return <Navigate to="/login" />;
  
  // If authenticated, render the component
  return children;
};

export default PrivateRoute;
