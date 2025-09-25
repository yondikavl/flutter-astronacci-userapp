<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Password;
use App\Http\Resources\UserResource;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6|confirmed',
        ]);
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);
        $token = JWTAuth::fromUser($user);
        return response()->json(['user' => new UserResource($user), 'token' => $token]);
    }

    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');
        if (!($token = auth('api')->attempt($credentials))) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }
        $user = auth('api')->user();
        return response()->json(['user' => new UserResource($user), 'token' => $token]);
    }

    public function forgot(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        $status = Password::sendResetLink($request->only('email'));
        if ($status == Password::RESET_LINK_SENT) {
            return response()->json(['message' => 'Reset link sent']);
        }
        return response()->json(['message' => 'Unable to send reset link'], 400);
    }

    public function logout(Request $request)
    {
        auth('api')->logout();
        return response()->json(['message' => 'Logged out']);
    }
}
