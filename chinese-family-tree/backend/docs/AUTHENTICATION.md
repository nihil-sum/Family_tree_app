# Authentication System

This document describes the authentication and authorization system for the Chinese Family Tree API.

## Overview

The system uses JWT (JSON Web Tokens) for authentication with role-based access control (RBAC).

## User Roles

| Role | Permissions | Description |
|------|-------------|-------------|
| `admin` | Full access (read, create, update, delete) | System administrators |
| `editor` | Create, read, update | Family members who can add/edit data |
| `viewer` | Read only | Family members with read access |
| `guest` | Limited read access | Visitors with restricted access |

## API Endpoints

### Authentication

| Method | Endpoint | Description | Public |
|--------|----------|-------------|---------|
| `POST` | `/api/auth/register` | Register a new user | ✅ Yes |
| `POST` | `/api/auth/login` | Login and get JWT token | ✅ Yes |
| `GET` | `/api/auth/profile` | Get current user profile | ❌ Authenticated |
| `PUT` | `/api/auth/profile` | Update current user profile | ❌ Authenticated |
| `PUT` | `/api/auth/change-password` | Change current user password | ❌ Authenticated |

### User Management (Admin Only)

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/users` | Get all users | `admin` |
| `GET` | `/api/users/:id` | Get specific user | `admin` |
| `PUT` | `/api/users/:id` | Update specific user | `admin` |
| `DELETE` | `/api/users/:id` | Delete specific user | `admin` |

## Usage Examples

### Register a New User

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "secure_password_123",
    "displayName": "John Doe",
    "role": "editor"
  }'
```

### Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "secure_password_123"
  }'
```

Response:
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "role": "editor",
      "displayName": "John Doe",
      "isActive": true
    }
  }
}
```

### Use Token for Authenticated Requests

```bash
curl -X GET http://localhost:8080/api/auth/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Access Protected Endpoints

```bash
curl -X GET http://localhost:8080/api/persons \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Environment Variables

Set these environment variables:

```bash
JWT_SECRET="your-super-secret-jwt-key-here-change-this-in-production"
```

## Security Best Practices

1. **Use HTTPS in production** - Never transmit JWT tokens over unencrypted connections
2. **Strong JWT secret** - Use a long, random string for JWT_SECRET
3. **Token expiration** - JWT tokens expire after 24 hours
4. **Password hashing** - All passwords are hashed using bcrypt
5. **Rate limiting** - Implement rate limiting for authentication endpoints
6. **Input validation** - All inputs are validated and sanitized

## Password Requirements

- Minimum 8 characters
- Should contain uppercase, lowercase, numbers, and special characters
- Stored as bcrypt hashes in the database

## Error Responses

Common error responses:

- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: Insufficient permissions for the requested action
- `409 Conflict`: Username or email already exists during registration
- `422 Unprocessable Entity`: Validation error in request data

## Development Notes

- During development, you can create an initial admin user directly in the database
- JWT_SECRET should be set as an environment variable
- Tokens are stored client-side (localStorage, cookies, etc.)
- Refresh tokens are not currently implemented but planned for future versions