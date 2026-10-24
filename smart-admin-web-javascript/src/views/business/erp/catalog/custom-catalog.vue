<template>
  <div>
    <CategoryTreeTable :category-type="CATEGORY_TYPE_ENUM.DEMO.value" :privilegePrefix="'custom:'"/>
  </div>
</template>
<script setup>
  import CategoryTreeTable from './components/category-tree-table.vue';
  import { CATEGORY_TYPE_ENUM } from '/@/constants/business/erp/category-const';
</script>
