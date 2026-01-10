<?php

namespace App\Repositories;

use App\Models\ProductCategory;

class ProductCategoryRepository
{
    public function create(array $data): ProductCategory
    {
        return ProductCategory::create($data);
    }

    public function findById($id): ?ProductCategory
    {
        return ProductCategory::with('product')->find($id);
    }

    public function all()
    {
        return ProductCategory::with('product')->where('is_active', 1)->get();
    }

    public function update($id, array $data)
    {
        $category = ProductCategory::findOrFail($id);
        $category->update($data);
        return $category;
    }

    public function delete($id)
    {
        $category = ProductCategory::findOrFail($id);
        $category->delete();
        return true;
    }
}