// test/smoke-test.js

const API_URL = "http://localhost:8081/user";

async function registerUser(userData) {
  const res = await fetch(`${API_URL}/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(userData),
  });

  const data = await res.json();
  console.log("Register Response:", data);

  if (!res.ok) {
    throw new Error(`Register failed: ${data.message || JSON.stringify(data)}`);
  }

  return data;
}

async function loginUser(credentials) {
  const res = await fetch(`${API_URL}/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(credentials),
  });

  const data = await res.json();
  console.log("Login Response:", data);

  if (!res.ok) {
    throw new Error(`Login failed: ${data.message || JSON.stringify(data)}`);
  }

  return data.token;
}

async function getMe(token) {
  const res = await fetch(`${API_URL}/me`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });

  const data = await res.json();

  console.log("Response Body:", data);

  if (!res.ok) {
    throw new Error(`Get Me failed: ${data.message || JSON.stringify(data)}`);
  }

  return data.user;
}

async function updateMe(token, updateData) {
  const res = await fetch(`${API_URL}/me`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(updateData),
  });

  const data = await res.json();
  console.log("Update Me Response:", data);

  if (!res.ok) {
    throw new Error(
      `Update Me failed: ${data.message || JSON.stringify(data)}`
    );
  }

  return data.user;
}

async function adminCreateUser(token, userData) {
  const res = await fetch(`${API_URL}/admin`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(userData),
  });

  const data = await res.json();
  console.log("Admin Create User Response:", data);

  if (!res.ok) {
    throw new Error(
      `Admin create failed: ${data.message || JSON.stringify(data)}`
    );
  }

  return data.user;
}

async function runTests() {
  try {
    // Optional: Admin tests
    const adminToken = await loginUser({
      email: "admin@example.com", // make sure this exists
      password: "adminpass123",
    });

    const createdPartner = await adminCreateUser(adminToken, {
      fullName: "Partner User",
      email: "partner@example.com",
      password: "password123",
      phoneNumber: "+0987654321",
      role: "PARTNER",
    });

    console.log("Created Partner:", createdPartner);

    console.log("✅ All tests passed!");
  } catch (error) {
    console.error("❌ Test failed:", error.message);
  }
}

runTests();
