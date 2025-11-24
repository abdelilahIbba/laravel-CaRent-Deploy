<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;

class Car extends Model
{
    use HasFactory;

    protected $fillable = [
        'model',
        'make', 
        'year',
        'fuel_type',
        'daily_price',
        'availability',
        'image',
        'quantity',
    ];

    protected $casts = [
        'daily_price' => 'decimal:2',
        'year' => 'integer',
        'quantity' => 'integer',
    ];

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function remainingUnits(Carbon $startDate, Carbon $endDate): int
    {
        $activeBookings = $this->bookings()
            ->whereIn('status', ['pending', 'confirmed'])
            ->where(function ($query) use ($startDate, $endDate) {
                $query->whereBetween('start_date', [$startDate->toDateString(), $endDate->toDateString()])
                    ->orWhereBetween('end_date', [$startDate->toDateString(), $endDate->toDateString()])
                    ->orWhere(function ($subQuery) use ($startDate, $endDate) {
                        $subQuery->where('start_date', '<=', $startDate->toDateString())
                            ->where('end_date', '>=', $endDate->toDateString());
                    });
            })
            ->count();

        return max(0, $this->quantity - $activeBookings);
    }

    public function scopeAvailable($query)
    {
        return $query->where('availability', 'available');
    }

    public function scopeUnavailable($query)
    {
        return $query->where('availability', 'unavailable');
    }

    public function getFormattedPriceAttribute()
    {
        return '$' . number_format($this->daily_price, 2);
    }

    public function getFullNameAttribute()
    {
        return "{$this->year} {$this->make} {$this->model}";
    }

    public static function updateCarAvailability($id, $availability)
    {
        return self::where('id', $id)->update(['availability' => $availability]);
    }
}