import React from 'react';
import styled from 'styled-components';
import { FiServer, FiDatabase, FiCpu, FiActivity } from 'react-icons/fi';

const DashboardContainer = styled.div`
  padding: 20px;
`;

const Title = styled.h1`
  margin-bottom: 20px;
  color: #333;
`;

const StatsGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
`;

const StatCard = styled.div`
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
`;

const StatHeader = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: 15px;
`;

const StatIcon = styled.div`
  width: 40px;
  height: 40px;
  background-color: ${props => props.color};
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 8px;
  color: white;
  margin-right: 10px;
`;

const StatTitle = styled.h3`
  margin: 0;
  font-size: 1rem;
  color: #555;
`;

const StatValue = styled.div`
  font-size: 2rem;
  font-weight: bold;
  color: #333;
`;

const ChartContainer = styled.div`
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
`;

const ChartTitle = styled.h2`
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.2rem;
  color: #333;
`;

const MockChart = styled.div`
  height: 300px;
  background-color: #f9f9f9;
  border-radius: 4px;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #888;
  font-style: italic;
`;

const DashboardContent = () => {
  return (
    <DashboardContainer>
      <Title>System Overview</Title>
      
      <StatsGrid>
        <StatCard>
          <StatHeader>
            <StatIcon color="#4285f4">
              <FiServer />
            </StatIcon>
            <StatTitle>Server Status</StatTitle>
          </StatHeader>
          <StatValue>Online</StatValue>
        </StatCard>
        
        <StatCard>
          <StatHeader>
            <StatIcon color="#34a853">
              <FiCpu />
            </StatIcon>
            <StatTitle>CPU Usage</StatTitle>
          </StatHeader>
          <StatValue>23%</StatValue>
        </StatCard>
        
        <StatCard>
          <StatHeader>
            <StatIcon color="#fbbc05">
              <FiDatabase />
            </StatIcon>
            <StatTitle>Database Connections</StatTitle>
          </StatHeader>
          <StatValue>42</StatValue>
        </StatCard>
        
        <StatCard>
          <StatHeader>
            <StatIcon color="#ea4335">
              <FiActivity />
            </StatIcon>
            <StatTitle>Requests per Minute</StatTitle>
          </StatHeader>
          <StatValue>256</StatValue>
        </StatCard>
      </StatsGrid>
      
      <ChartContainer>
        <ChartTitle>System Load (Last 24 Hours)</ChartTitle>
        <MockChart>Chart visualization would appear here</MockChart>
      </ChartContainer>
      
      <ChartContainer>
        <ChartTitle>Database Performance</ChartTitle>
        <MockChart>Chart visualization would appear here</MockChart>
      </ChartContainer>
    </DashboardContainer>
  );
};

export default DashboardContent;
