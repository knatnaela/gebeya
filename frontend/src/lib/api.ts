import axios from 'axios';
import { getAuthToken } from './auth';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - handle errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Unauthorized - clear token and redirect to login
      if (typeof window !== 'undefined') {
        localStorage.removeItem('auth_token');
        window.location.href = '/login';
      }
    }
    // Handle subscription expired (403 with specific error message)
    if (
      error.response?.status === 403 &&
      error.response?.data?.error === 'Trial subscription has expired'
    ) {
      // Store subscription expired state in localStorage for global access
      if (typeof window !== 'undefined') {
        localStorage.setItem('subscription_expired', 'true');
        // Dispatch a custom event to notify components
        window.dispatchEvent(new CustomEvent('subscription-expired', {
          detail: error.response.data.details,
        }));
      }
    }
    return Promise.reject(error);
  }
);

export default apiClient;


