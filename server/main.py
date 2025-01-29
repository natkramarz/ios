from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, RootModel
import uuid
from enum import Enum
import datetime 

app = FastAPI()

class DateTime(RootModel):
    root: datetime.datetime

    def __hash__(self):
        return hash(self.root)

    def __eq__(self, other):
        if isinstance(other, DateTime):
            return self.root == other.root
        return False
    
    def __str__(self):
        return self.root.strftime("%Y-%m-%dT%H:%M:%SZ")

class ID(RootModel):
    root: uuid.UUID

    def __hash__(self):
        return hash(self.root)

    def __eq__(self, other):
        if isinstance(other, ID):
            return self.root == other.root
        return False
    
    def __str__(self):
        return str(self.root)

class Product(BaseModel):
    id: ID
    name: str
    price: float

class Status(str, Enum):
    pending = "Pending"
    completed = "Completed"
    failed = "Failed"


class Method(str, Enum):
    cash = "Cash"
    blik = "BLIK"


class Payment(BaseModel):
    id: ID
    status: Status
    method: Method

    class Config:
        use_enum_values = True


class Order(BaseModel):
    id: ID
    customer_id: ID
    items: dict[ID, int]
    payment: Payment
    created_at: DateTime
    updated_at: DateTime


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


class PaymentResponse(BaseModel):
    id: str
    status: str
    method: str


class OrderResponse(BaseModel):
    id: str
    customer_id: ID
    items: dict[str, int]
    payment: PaymentResponse
    created_at: DateTime
    updated_at: DateTime

@app.post("/orders", response_model=OrderResponse)
async def place_order(order: Order):
    orders.append(order)
    return {
                "id": str(order.id),
                "customer_id": str(order.id), 
                "items": {str(key): value for key, value in order.items.items()},
                "payment": {
                    "id": str(order.payment.id),
                    "status": order.payment.status,
                    "method": order.payment.method,
                },
                "created_at": order.created_at.root.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "updated_at": order.created_at.root.strftime("%Y-%m-%dT%H:%M:%SZ"),
            }

@app.get("/orders", response_model=dict[str, list[OrderResponse]])
async def get_orders():
    return {
        "orders": [
            {
                "id": str(order.id),
                "customer_id": str(order.id), 
                "items": {str(key): value for key, value in order.items.items()},
                "payment": {
                    "id": str(order.payment.id),
                    "status": order.payment.status,
                    "method": order.payment.method,
                },
                "created_at": order.created_at,
                "updated_at": order.created_at,
            }
            for order in orders
        ]
    }

users = {

}


class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    password: str

@app.post("/login")
async def login(request: LoginRequest):
    if request.username in users and users[request.username] == request.password:
        return {
            "message": "Login successful",
            "token": "mock_token_123456" 
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    

@app.post("/register")
async def register(request: RegisterRequest):
    users[request.username] = request.password
    return {
            "message": "Register successful",
            "token": "mock_token_123456" 
    }
