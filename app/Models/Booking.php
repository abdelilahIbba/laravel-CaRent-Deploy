<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'car_id', 'start_date', 'end_date', 'status', 'amount'];

    public function car()
    {
        return $this->belongsTo(Car::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Add client relationship for admin views
    public function client()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
