from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import engine, Base, get_db
import models

Base.metadata.create_all(bind=engine)

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class BookingCreate(BaseModel):
    customer_name: str
    service_id: int

class BookingUpdate(BaseModel):
    status: str

@app.get("/")
def read_root():
    return {"message": "Home Services API is running"}

@app.get("/services")
def get_services(db: Session = Depends(get_db)):
    services = db.query(models.Service).all()
    return services

@app.post("/bookings")
def create_booking(booking: BookingCreate, db: Session = Depends(get_db)):
    new_booking = models.Booking(
        customer_name=booking.customer_name,
        service_id=booking.service_id
    )
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    return new_booking

@app.get("/bookings")
def get_bookings(db: Session = Depends(get_db)):
    bookings = db.query(models.Booking).order_by(models.Booking.id).all()
    return bookings

@app.patch("/bookings/{booking_id}")
def update_booking(booking_id: int, update: BookingUpdate, db: Session = Depends(get_db)):
    booking = db.query(models.Booking).filter(models.Booking.id == booking_id).first()
    if not booking:
        return {"error": "Booking not found"}
    booking.status = update.status
    db.commit()
    db.refresh(booking)
    return booking