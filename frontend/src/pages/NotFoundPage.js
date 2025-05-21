import React from 'react';
import styled from 'styled-components';

const NotFoundContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;
  padding: 0 20px;
`;

const ErrorCode = styled.h1`
  font-size: 6rem;
  margin: 0;
  color: #4285f4;
`;

const ErrorMessage = styled.h2`
  font-size: 2rem;
  margin: 10px 0 20px;
  color: #333;
`;

const ErrorDescription = styled.p`
  font-size: 1rem;
  color: #666;
  max-width: 500px;
  margin-bottom: 30px;
`;

const BackButton = styled.a`
  padding: 10px 20px;
  background-color: #4285f4;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-weight: 600;
  transition: background-color 0.3s;
  
  &:hover {
    background-color: #3367d6;
  }
`;

const NotFoundPage = () => {
  return (
    <NotFoundContainer>
      <ErrorCode>404</ErrorCode>
      <ErrorMessage>Page Not Found</ErrorMessage>
      <ErrorDescription>
        The page you are looking for might have been removed, had its name changed,
        or is temporarily unavailable.
      </ErrorDescription>
      <BackButton href="/">Go to Homepage</BackButton>
    </NotFoundContainer>
  );
};

export default NotFoundPage;
