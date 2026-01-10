<?php

use App\Http\Controllers\ProductCategoryController;

Route::prefix('product-category')->group(function () {
    Route::post('/create', [ProductCategoryController::class, 'store']);
    Route::get('/get-all', [ProductCategoryController::class, 'getAll']);
    Route::get('/get-one/{id}', [ProductCategoryController::class, 'getOne']);
    Route::put('/update/{id}', [ProductCategoryController::class, 'update']);
    Route::patch('/soft-delete/{id}', [ProductCategoryController::class, 'statusUpdate']);
    Route::delete('/delete/{id}', [ProductCategoryController::class, 'delete']);
});