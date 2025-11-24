<?php

// namespace Tests\Feature;

// use App\Models\User;
// use Illuminate\Foundation\Testing\RefreshDatabase;
// use Illuminate\Support\Facades\Hash;
// use Tests\TestCase;

// class RegisteredUserControllerTest extends TestCase
// {
//     use RefreshDatabase; // This will reset the database after each test

//     /** @test */
//     public function it_displays_the_registration_form()
//     {
//         $response = $this->get('/register'); // Adjust the route if necessary

//         $response->assertStatus(200);
//         $response->assertViewIs('auth.register'); // Ensure the correct view is returned
//     }

//     /** @test */
//     public function it_registers_a_new_user()
//     {
//         $response = $this->post('/register', [ // Adjust the route if necessary
//             'name' => 'John Doe',
//             'email' => 'john@example.com',
//             'phone' => '1234567890',
//             'national_id' => 'ABC123456',
//             'driver_license_number' => 'DL123456',
//             'driver_license_expiry_date' => '2025-12-31',
//             'password' => 'password',
//             'password_confirmation' => 'password',
//         ]);

//         $this->assertDatabaseHas('users', [
//             'email' => 'john@example.com',
//             'name' => 'John Doe',
//             'phone' => '1234567890',
//             'national_id' => 'ABC123456',
//             'driver_license_number' => 'DL123456',
//             'role' => 'client', // Ensure the role is set correctly
//         ]);

//         $response->assertRedirect(route('admin.clients.index')); // Adjust the route if necessary
//         $this->assertAuthenticated(); // Ensure the user is authenticated
//     }

//     /** @test */
//     public function it_validates_registration_input()
//     {
//         $response = $this->post('/register', [ // Adjust the route if necessary
//             'name' => '',
//             'email' => 'not-an-email',
//             'password' => 'short',
//             'password_confirmation' => 'different',
//         ]);

//         $response->assertSessionHasErrors(['name', 'email', 'password']);
//         $this->assertGuest(); // Ensure the user is not authenticated
//     }
// }
