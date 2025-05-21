import React from 'react';
import LoginForm from '../components/LoginForm';
import { useLoginForm } from '../utils/formHooks';
import styled from 'styled-components';

const LoginPageContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
`;

const LoginPage = () => {
  const {
    formData,
    errors,
    authError,
    isSubmitting,
    handleChange,
    handleSubmit,
  } = useLoginForm();
  
  return (
    <LoginPageContainer>
      <LoginForm
        formData={formData}
        errors={errors}
        authError={authError}
        isSubmitting={isSubmitting}
        handleChange={handleChange}
        handleSubmit={handleSubmit}
      />
    </LoginPageContainer>
  );
};

export default LoginPage;
