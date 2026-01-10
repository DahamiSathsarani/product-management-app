<?php

namespace App\Http\Controllers;

use App\Models\ProductCategory;
use App\Repositories\ProductCategoryRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductCategoryController extends Controller
{
    protected $productCategoryRepo;

    public function __construct(ProductCategoryRepository $productCategoryRepo)
    {
        $this->productCategoryRepo = $productCategoryRepo;
    }

    public function store(Request $request)
    {
        $validated = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:product_categories,name',
            'is_active' => 'required|boolean',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        try {
            $category = $this->productCategoryRepo->create([
                'name' => $request->name,
                'is_active' => $request->is_active,
            ]);

            return response()->json([
                'success' => true,
                'category' => $category,
                'message' => 'Category created successfully!',
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getAll()
    {
        try {
            $categories = $this->productCategoryRepo->all();

            return response()->json([
                'success' => true,
                'categories' => $categories,
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getOne($id)
    {
        try {
            $category = $this->productCategoryRepo->findById($id);

            if (!$category) {
                return response()->json(['error' => 'Category not found'], 404);
            }

            return response()->json([
                'success' => true,
                'category' => $category
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function update(Request $request, $id)
    {
        $validated = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:product_categories,name,' . $id,
            'is_active' => 'required|boolean',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        $category = $this->productCategoryRepo->findById($id);

        if (!$category) {
            return response()->json(['error' => 'Category not found'], 404);
        }

        try {
            $updatedCategory = $this->productCategoryRepo->update($id, [
                'name' => $request->name,
                'is_active' => $request->is_active,
            ]);

            return response()->json([
                'success' => true,
                'category' => $updatedCategory,
                'message' => 'Category updated successfully!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function statusUpdate(Request $request, $id)
    {
        $validated = Validator::make($request->all(), [
            'is_active' => 'required|boolean',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        $validated = $validated->validated();

        $category = $this->productCategoryRepo->findById($id);

        if (!$category) {
            return response()->json(['error' => 'Category not found'], 404);
        }

        try {
            $category = $this->productCategoryRepo->update($id, $validated);

            return response()->json([
                'success' => true,
                'category' => $category,
                'message' => 'Category status updated successfully!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }   
    }

    public function delete($id)
    {
        $category = $this->productCategoryRepo->findById($id);

        if (!$category) {
            return response()->json(['error' => 'Category not found'], 404);
        }

        try {
            $this->productCategoryRepo->delete($id);
            return response()->json(['message' => 'Category deleted successfully!'], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}