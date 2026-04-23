class ApiEndpoints {
  static const String baseUrl = "https://secret-project-n0hs.onrender.com/api";

  // Auth
  static const String login = "/auth/login";
  static const String registerTenant = "/auth/register-tenant";
  static const String refresh = "/auth/refresh";
  static const String profile = "/auth/profile";

  // Tenants & Leases
  static const String tenantDashboard = "/tenants/me/dashboard";
  static const String leases = "/tenants/leases";
  static const String verifyTrust = "/tenants/verify-trust";

  // Finance
  static const String invoices = "/rent/invoices";
  static const String stkPush = "/rent/mpesa/stkpush";
  static const String trxStatus = "/rent/status"; // + /:checkoutId

  // Marketing
  static const String publicListings = "/marketing/public/listings";
}