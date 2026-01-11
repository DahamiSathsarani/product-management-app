<?php

namespace App\Repositories;

use App\Models\Product;

class ProductRepository
{
    public function create(array $data): Product
    {
        return Product::create($data);
    }

    public function findById($id): ?Product
    {
        return Product::with('category')->find($id);
    }

    public function all()
    {
        return Product::with('category')->where('is_active', 1)->get();
    }

    public function paginate($limit = 10)
    {
        return Product::with('category')->where('is_active', 1)->paginate($limit);
    }

    public function update($id, array $data)
    {
        $product = Product::findOrFail($id);
        $product->update($data);
        return $product;
    }

    public function inactivateByCategory($categoryId)
    {
        return Product::where('category_id', $categoryId)
                    ->update(['is_active' => 0]);
    }

    public function delete($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        return true;
    }
}