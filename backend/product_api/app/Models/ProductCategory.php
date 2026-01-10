<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductCategory extends Model
{
    protected $table      = 'product_categories'; 
    protected $primaryKey = 'id';
    public $incrementing  = true; 

    protected $fillable = [
        'name', 
        'is_active',
    ];

    public function product()
    {
        return $this->hasMany(Product::class, 'category_id');
    }
}