from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {
  "categories": [
    {
      "id": "b18d49c5-7b99-4db4-9314-bb9e856d73f3",
      "name": "Coffee",
      "products": [
        {
          "id": "f34c2a90-d5b2-4ef9-90f0-3b7c8c8b2a9e",
          "name": "Ethiopian Single Origin",
          "price": 15.99,
          "description": "A bright and floral coffee with notes of citrus and jasmine.",
          "image_url": "https://example.com/images/ethiopian-single-origin.jpg",
        },
        {
          "id": "9ad724a4-239d-4a9b-bf28-d6d77d29df8e",
          "name": "Colombian Medium Roast",
          "price": 12.99,
          "description": "A smooth and balanced coffee with hints of caramel and chocolate.",
          "image_url": "https://example.com/images/colombian-medium-roast.jpg",
        },
        {
          "id": "768db6f1-8d43-4c39-b650-071c28b4fc73",
          "name": "Espresso Blend",
          "price": 14.49,
          "description": "A bold and rich blend, perfect for making espresso.",
          "image_url": "https://example.com/images/espresso-blend.jpg",
        },
        {
          "id": "c87fd2d5-23e9-4e45-8e8f-795fb4cc9aef",
          "name": "Decaf House Blend",
          "price": 13.99,
          "description": "A decaffeinated blend with full-bodied flavor.",
          "image_url": "https://example.com/images/decaf-house-blend.jpg",
        }
      ]
    },
    {
      "id": "ad21f66d-37d5-4416-a8b8-2b7853a5a702",
      "name": "Accessories",
      "products": [
        {
          "id": "34537a2d-b8a6-488e-a520-4e3a993112df",
          "name": "French Press",
          "price": 29.99,
          "description": "A classic French press coffee maker, 34 oz capacity.",
          "image_url": "https://example.com/images/french-press.jpg",
        },
        {
          "id": "f4b8a349-e0b8-4973-aebd-71af6dbd5438",
          "name": "Pour Over Kit",
          "price": 39.99,
          "description": "Complete pour-over coffee setup, includes dripper and filters.",
          "image_url": "https://example.com/images/pour-over-kit.jpg",
        },
        {
          "id": "7c3b1e98-8e22-4a1b-9cf9-bb245582fbd5",
          "name": "Coffee Grinder",
          "price": 49.99,
          "description": "Electric coffee grinder with adjustable grind settings.",
          "image_url": "https://example.com/images/coffee-grinder.jpg",
        },
        {
          "id": "00c21af8-3025-4f27-95b0-2fefc70f9c51",
          "name": "Reusable Coffee Cup",
          "price": 14.99,
          "description": "Eco-friendly reusable coffee cup, 12 oz.",
          "image_url": "https://example.com/images/reusable-coffee-cup.jpg",
        }
      ]
    },
    {
      "id": "29f8ec2e-c2a5-4e1f-93a8-88328427fc6f",
      "name": "Merchandise",
      "products": [
        {
          "id": "463b3aaf-29ea-47e3-b9c3-3a17a74beff8",
          "name": "Coffee Shop T-Shirt",
          "price": 19.99,
          "description": "Comfortable cotton t-shirt with our coffee shop logo.",
          "image_url": "https://example.com/images/coffee-shop-tshirt.jpg",
        },
        {
          "id": "18b16c3b-9187-4a44-a1f7-d89f45eb0046",
          "name": "Coffee Shop Mug",
          "price": 9.99,
          "description": "Ceramic mug with our coffee shop logo.",
          "image_url": "https://example.com/images/coffee-shop-mug.jpg",
        },
        {
          "id": "3d243d9b-2162-49c7-b29d-66c1e6e4b9b4",
          "name": "Canvas Tote Bag",
          "price": 14.99,
          "description": "Durable canvas tote bag with coffee-themed print.",
          "image_url": "https://example.com/images/canvas-tote-bag.jpg",
        },
        {
          "id": "d5727c8e-83b3-473d-b9bc-dfc74263765d",
          "name": "Gift Card",
          "price": 25.00,
          "description": "Gift card for use at our online coffee shop.",
          "image_url": "https://example.com/images/gift-card.jpg",
        }
      ]
    }
  ]
}
