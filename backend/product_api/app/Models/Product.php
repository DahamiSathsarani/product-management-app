<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $table      = 'products'; 
    protected $primaryKey = 'id';
    public $incrementing  = true; 

    protected $fillable = [
        'name',
        'category_id',
        'price',
        'is_active',
        'image',
    ];

    public function category()
    {
        return $this->belongsTo(ProductCategory::class, 'category_id');
    }
}
