<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    public function me(Request $request)
    {
        return new UserResource(auth('api')->user());
    }

    public function update(Request $request)
    {
        $user = auth('api')->user();
        $request->validate(['name' => 'sometimes|string|max:255', 'avatar' => 'sometimes|image|max:2048']);
        if ($request->hasFile('avatar')) {
            // delete old avatar if exists
            if ($user->avatar) {
                Storage::disk('public')->delete('avatars/' . $user->avatar);
            }
            $file = $request->file('avatar');
            $filename = time() . '.' . $file->getClientOriginalExtension();
            $file->storeAs('avatars', $filename, 'public');
            $user->avatar = $filename;
        }
        if ($request->has('name')) {
            $user->name = $request->name;
        }
        $user->save();
        return new UserResource($user);
    }

    public function index(Request $request)
    {
        $q = $request->query('q');
        $limit = (int) $request->query('limit', 10);
        $users = User::query();
        if ($q) {
            $users->where(function ($qry) use ($q) {
                $qry->where('name', 'like', '%' . $q . '%')->orWhere('email', 'like', '%' . $q . '%');
            });
        }
        $paginated = $users->orderBy('id', 'desc')->paginate($limit);
        return response()->json($paginated);
    }

    public function show($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'Not found'], 404);
        }
        return new UserResource($user);
    }
}
