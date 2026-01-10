<?php

use App\Http\Controllers\ProductCategoryController;
use App\Http\Controllers\ProductController;

Route::prefix('product-category')->group(function () {
    Route::post('/create', [ProductCategoryController::class, 'store']);
    Route::get('/get-all', [ProductCategoryController::class, 'getAll']);
    Route::get('/get-one/{id}', [ProductCategoryController::class, 'getOne']);
    Route::put('/update/{id}', [ProductCategoryController::class, 'update']);
    Route::patch('/soft-delete/{id}', [ProductCategoryController::class, 'statusUpdate']);
    Route::delete('/delete/{id}', [ProductCategoryController::class, 'delete']);
});

Route::prefix('product')->group(function () {
    Route::post('/create', [ProductController::class, 'store']);
    Route::get('/get-all', [ProductController::class, 'getAll']);
    Route::get('/get-one/{id}', [ProductController::class, 'getOne']);
    Route::put('/update/{id}', [ProductController::class, 'update']);
    Route::patch('/soft-delete/{id}', [ProductController::class, 'statusUpdate']);
    Route::delete('/delete/{id}', [ProductController::class, 'delete']);
});