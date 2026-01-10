<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Repositories\ProductRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    protected $productRepo;

    public function __construct(ProductRepository $productRepo)
    {
        $this->productRepo = $productRepo;
    }

    public function store(Request $request)
    {
        $validated = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:products,name',
            'category_id' => 'required|exists:product_categories,id',
            'price' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        try {
            $product = $this->productRepo->create([
                'name' => $request->name,
                'category_id' => $request->category_id,
                'price' => $request->price,
                'is_active' => $request->is_active,
            ]);

            return response()->json([
                'success' => true,
                'product' => $product,
                'message' => 'Product created successfully!',
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getAll(Request $request)
    {
        $validated = Validator::make($request->all(), [
            'page' => 'integer|min:1',
            'limit' => 'integer|min:1|max:100',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        $page = $request->input('page', 1);
        $limit = $request->input('limit', 10);

        try {
            $products = $this->productRepo->paginate($limit);

            return response()->json([
                'success' => true,
                'meta' => [
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                ],
                'products' => $products->items(),
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getOne($id)
    {
        try {
            $product = $this->productRepo->findById($id);

            if (!$product) {
                return response()->json(['error' => 'Product not found'], 404);
            }

            return response()->json([
                'success' => true,
                'product' => $product
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function update(Request $request, $id)
    {
        $validated = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:products,name,' . $id,
            'category_id' => 'required|exists:product_categories,id',
            'price' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        $product = $this->productRepo->findById($id);

        if (!$product) {
            return response()->json(['error' => 'Product not found'], 404);
        }

        try {
            $updatedProduct = $this->productRepo->update($id, [
                'name' => $request->name,
                'category_id' => $request->category_id,
                'price' => $request->price,
                'is_active' => $request->is_active,
            ]);

            return response()->json([
                'success' => true,
                'product' => $updatedProduct,
                'message' => 'Product updated successfully!',
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

        $product = $this->productRepo->findById($id);

        if (!$product) {
            return response()->json(['error' => 'Product not found'], 404);
        }

        try {
            $product = $this->productRepo->update($id, $validated);

            return response()->json([
                'success' => true,
                'product' => $product,
                'message' => 'Product status updated successfully!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }   
    }

    public function delete($id)
    {
        $product = $this->productRepo->findById($id);

        if (!$product) {
            return response()->json(['error' => 'Product not found'], 404);
        }

        try {
            $this->productRepo->delete($id);
            return response()->json(['message' => 'Product deleted successfully!'], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}