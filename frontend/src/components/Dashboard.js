import React from 'react';
import styled from 'styled-components';
import { FiUser, FiLogOut, FiSettings, FiHome, FiDatabase, FiServer } from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';

const Header = styled.header`
  background-color: #2c3e50;
  color: white;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

const Logo = styled.div`
  font-size: 1.5rem;
  font-weight: bold;
  padding: 15px 0;
`;

const Nav = styled.nav`
  display: flex;
  align-items: center;
`;

const UserInfo = styled.div`
  display: flex;
  align-items: center;
  margin-right: 20px;
`;

const UserName = styled.span`
  margin-left: 8px;
`;

const LogoutButton = styled.button`
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 8px;
  font-size: 1rem;
  
  &:hover {
    text-decoration: underline;
  }
`;

const MainContainer = styled.div`
  display: flex;
  height: calc(100vh - 60px);
`;

const Sidebar = styled.aside`
  width: 250px;
  background-color: #34495e;
  color: white;
  padding: 20px 0;
`;

const MenuList = styled.ul`
  list-style: none;
  padding: 0;
  margin: 0;
`;

const MenuItem = styled.li`
  padding: 0;
  
  a {
    display: flex;
    align-items: center;
    padding: 12px 20px;
    color: white;
    text-decoration: none;
    transition: background-color 0.3s;
    
    &:hover {
      background-color: #2c3e50;
    }
    
    &.active {
      background-color: #2980b9;
    }
  }
`;

const MenuIcon = styled.span`
  margin-right: 10px;
  display: flex;
  align-items: center;
`;

const Content = styled.main`
  flex: 1;
  padding: 20px;
  background-color: #f5f5f5;
  overflow: auto;
`;

const Dashboard = ({ children }) => {
  const { user, logout } = useAuth();
  
  const handleLogout = () => {
    logout();
  };
  
  return (
    <>
      <Header>
        <Logo>DevOps Portfolio</Logo>
        <Nav>
          <UserInfo>
            <FiUser size={18} />
            <UserName>{user?.username || 'User'}</UserName>
          </UserInfo>
          <LogoutButton onClick={handleLogout}>
            <FiLogOut size={18} style={{ marginRight: '5px' }} />
            Logout
          </LogoutButton>
        </Nav>
      </Header>
      <MainContainer>
        <Sidebar>
          <MenuList>
            <MenuItem>
              <a href="#" className="active">
                <MenuIcon><FiHome size={18} /></MenuIcon>
                Dashboard
              </a>
            </MenuItem>
            <MenuItem>
              <a href="#">
                <MenuIcon><FiServer size={18} /></MenuIcon>
                Infrastructure
              </a>
            </MenuItem>
            <MenuItem>
              <a href="#">
                <MenuIcon><FiDatabase size={18} /></MenuIcon>
                Database
              </a>
            </MenuItem>
            <MenuItem>
              <a href="#">
                <MenuIcon><FiSettings size={18} /></MenuIcon>
                Settings
              </a>
            </MenuItem>
          </MenuList>
        </Sidebar>
        <Content>
          {children}
        </Content>
      </MainContainer>
    </>
  );
};

export default Dashboard;
