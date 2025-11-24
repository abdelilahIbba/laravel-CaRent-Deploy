<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed a default admin account for quick access
        User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@carrent.local',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        // Seed three regular client users
        User::factory()
            ->count(3)
            ->create();
    }
}
