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
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', 
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        try {
            $data = [
                'name' => $request->name,
                'category_id' => $request->category_id,
                'price' => $request->price,
                'is_active' => $request->is_active,
            ];

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $imageName = time() . '_' . $image->getClientOriginalName();
                $image->move(public_path('uploads/products'), $imageName);
                $fullUrl = url('uploads/products/' . $imageName);
                $data['image'] = $fullUrl;
            }

            $product = $this->productRepo->create($data);

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
            'search' => 'nullable|string|max:255',
            'category_id' => 'nullable|integer|exists:product_categories,id',
            'min_price' => 'nullable|numeric|min:0',
            'max_price' => 'nullable|numeric|min:0',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        try {
            $products = $this->productRepo->all();

            if ($request->filled('search')) {
                $products = $products->filter(function ($p) use ($request) {
                    return str_contains(strtolower($p->name), strtolower($request->search));
                });
            }

            if ($request->filled('category_id')) {
                $products = $products->where('category_id', $request->category_id);
            }

            if ($request->filled('min_price')) {
                $products = $products->where('price', '>=', $request->min_price);
            }
            if ($request->filled('max_price')) {
                $products = $products->where('price', '<=', $request->max_price);
            }

            $products = $products->values(); 

            return response()->json([
                'success' => true,
                'products' => $products,
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
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validated->fails()) {
            return response()->json(['errors' => $validated->errors()], 422);
        }

        $product = $this->productRepo->findById($id);

        if (!$product) {
            return response()->json(['error' => 'Product not found'], 404);
        }

        try {
            $data = [
                'name' => $request->name,
                'category_id' => $request->category_id,
                'price' => $request->price,
                'is_active' => $request->is_active,
            ];

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $imageName = time() . '_' . $image->getClientOriginalName();
                $image->move(public_path('uploads/products'), $imageName);

                $data['image'] = url('uploads/products/' . $imageName);
            }

            $updatedProduct = $this->productRepo->update($id, $data);

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