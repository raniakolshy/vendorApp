class GraphQLQueries {
  // Login mutation
  static const String login = r'''
    mutation Login($email: String!, $password: String!) {
      generateCustomerToken(email: $email, password: $password) {
        token
      }
    }
  ''';

  // Get vendor profile
  static const String getVendorProfile = r'''
    query {
      customer {
        id
        firstname
        lastname
        email
        telephone
        created_at
      }
    }
  ''';

  // Get vendor products (drafts)
  static const String getVendorProducts = r'''
    query GetVendorProducts($vendorId: Int!, $pageSize: Int, $currentPage: Int, $status: String) {
      products(
        filter: {
          vendor_id: {eq: $vendorId}
          status: {eq: $status}
        }
        pageSize: $pageSize
        currentPage: $currentPage
      ) {
        items {
          id
          name
          sku
          price
          status
          created_at
          stock_status
          ... on PhysicalProductInterface {
            weight
          }
          media_gallery_entries {
            file
            label
            position
            disabled
            types
          }
          extension_attributes {
            stock_item {
              qty
              is_in_stock
            }
          }
        }
        total_count
        page_info {
          current_page
          page_size
          total_pages
        }
      }
    }
  ''';

  // Get vendor orders
  static const String getVendorOrders = r'''
    query GetVendorOrders($vendorId: Int!, $pageSize: Int, $currentPage: Int) {
      orders(
        filter: {vendor_id: {eq: $vendorId}}
        pageSize: $pageSize
        currentPage: $currentPage
      ) {
        items {
          increment_id
          created_at
          status
          grand_total
          subtotal
          customer_firstname
          customer_lastname
          customer_email
          items {
            sku
            name
            price
            qty_ordered
          }
        }
        total_count
      }
    }
  ''';

  // Dashboard stats
  static const String getDashboardStats = r'''
    query GetDashboardStats($vendorId: Int!) {
      orders(filter: {vendor_id: {eq: $vendorId}}) {
        total_count
        items {
          grand_total
          status
          created_at
        }
      }
      products(filter: {vendor_id: {eq: $vendorId}}) {
        total_count
      }
    }
  ''';
}