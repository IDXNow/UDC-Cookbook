# XML to Pipe-Delimited - Product Inventory

*Got a deeply nested XML export from your ERP? This recipe flattens it into a simple pipe-delimited file you can actually work with.*

> Converts an XML product inventory file to pipe-delimited format, extracting key fields from a nested hierarchy.

## What This Solves

Product inventory data gets exported from ERP systems as deeply nested XML - great for machines, not great for people who need a flat file. This recipe pulls the essential fields out of the hierarchy and gives you a clean pipe-delimited format for downstream processing.

## Input

XML file with `<Product>` elements containing nested details for pricing, inventory, supplier info, and more.

```xml
<Product SKU="ELEC-5512" DepartmentCode="ELECTRONICS">
  <ProductName>Ultra HD Smart Television</ProductName>
  <Brand>TechVision</Brand>
  <InventoryDetails>
    <QuantityOnHand>45</QuantityOnHand>
    ...
  </InventoryDetails>
  <PricingInfo>
    <RetailPrice currency="USD">1499.99</RetailPrice>
    ...
  </PricingInfo>
</Product>
```

## Output

Pipe-delimited text with flattened columns:

```
SKU|ProductName|Brand|QuantityOnHand|Status|RetailPrice
ELEC-5512|Ultra HD Smart Television|TechVision|45|Active|1499.99
```

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/xml-to-pipe/product_inventory_conv.yaml" \
                --file "conversion/xml-to-pipe/product_inventory.xml"

# Folder + search pattern
python udc01.py --conversion "conversion/xml-to-pipe/product_inventory_conv.yaml" \
                --folder "conversion/xml-to-pipe" \
                --pattern "*.xml"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `product_inventory_conv.yaml` | UDC01 conversion configuration |
| `product_inventory.xml` | Example XML with 5 product records |
| `expected_output.txt` | Expected pipe-delimited result |

## Model Requirements

- Works with any supported LLM provider
- Model must handle nested XML parsing and hierarchy navigation

## Adapt This Recipe

This example uses a product inventory XML, but the pattern applies to any nested XML-to-flat-file conversion. In the YAML:

- **Change the element names** - Update the element and attribute references to match your XML schema (e.g., `<Order>` instead of `<Product>`, `OrderID` instead of `SKU`)
- **Choose which fields to flatten** - Select the nested elements that matter to your downstream system and leave out the rest
- **Handle deeper nesting** - Adjust the prompt instructions to navigate additional levels of hierarchy (e.g., grandchild elements, sibling groupings)
- **Change the output format** - Switch from pipe-delimited to CSV, JSON, or any other format your target system expects
- **Add computed fields** - Instruct the prompt to derive values across elements (e.g., total inventory value = quantity × price)
