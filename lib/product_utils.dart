class Product {
  static const simple = '''
  mutation SimpleProduct(\$id: String!, \$qty: Float!, \$sku: String!) {
    addSimpleProductsToCart(
      input: {
        cart_id: \$id
        cart_items: [
          {
            data: {
              quantity: \$qty
              sku: \$sku
            }
          }
        ]
      }
    ) {
      cart {
        items {
          product {
            name
            sku
          }
        }
      }
    }
  }
  ''';

  static const virtual = '''
  mutation VirtualProduct(\$id: String!, \$qty: Float!, \$sku: String!) {
    addVirtualProductsToCart(
      input: {
        cart_id: \$id,
        cart_items: [
          {
            data: {
              quantity: \$qty
              sku: \$sku
            }
          }
        ]
      }
    ) {
      cart {
        items {
          product {
            name
            sku
          }
        }
      }
    }
  }
  ''';

  static const configurable = '''
  mutation ConfigurableProduct(
    \$id: String!, \$qty: Float!, \$parentSku: String!, \$variantSku: String!
  ) {
    addConfigurableProductsToCart(
      input: {
        cart_id: \$id,
        cart_items: [
          {
            parent_sku: \$parentSku
            data: {
              quantity: \$qty
              sku: \$variantSku
            }
          }
        ]
      }
    ) {
      cart {
        items {
          product {
            name
            sku
          }
        }
      }
    }
  }
  ''';
}
