from fastapi import FastAPI
from pydantic import BaseModel
import uuid

app = FastAPI()

class Product(BaseModel):
    id:uuid.UUID
    name: str
    price: float

class Order(BaseModel):
    id: uuid.UUID
    items: dict[uuid.UUID, int]


orders = []

products = { 
    "Ethiopian Single Origin": Product(
        id=uuid.UUID('0f57b843-2989-42f2-92f8-f561197e8bec'),
        name="Ethiopian Single Origin",
        price=15.99,
    ), 
    "Colombian Medium Roast": Product(
        id=uuid.UUID("c8c06af7-0aa3-45bd-b271-78e269082e99"),
        name="Colombian Medium Roast",
        price=12.99,
    ),
    "French Press": Product(
        id=uuid.UUID("fa7bfc15-5ae9-4358-b120-59bc184bc9d5"),
        name="French Press",
        price=29.99,
    ),
    "Coffee Shop Mug": Product(
        id=uuid.UUID("9645c29e-47c9-40ed-8daa-db2ad9475e4f"),
        name="Coffee Shop Mug",
        price=9.99,
    ),
}


@app.get("/")
async def root():
    return {
  "categories": [
    {
      "id": "b18d49c5-7b99-4db4-9314-bb9e856d73f3",
      "name": "Coffee",
      "products": [products["Ethiopian Single Origin"], products["Colombian Medium Roast"]] 
    },
    {
      "id": "ad21f66d-37d5-4416-a8b8-2b7853a5a702",
      "name": "Accessories",
      "products": [products["French Press"]]
    },
    {
      "id": "29f8ec2e-c2a5-4e1f-93a8-88328427fc6f",
      "name": "Merchandise",
      "products": [products["Coffee Shop Mug"]]
    }
  ]
}


class OrderResponse(BaseModel):
    id: str
    items: dict[str, int]

@app.post("/orders", response_model=OrderResponse)
async def place_order(order: Order):
    orders.append(order)
    response_items = {str(key): value for key, value in order.items.items()}
    return {
        "id": str(order.id),
        "items": response_items,
    }

@app.get("/orders")
async def ger_orders():
    return {"orders": orders}


