import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services

ListModel {
    id: categoryModel
    objectName: "CategoryModel"

    property var categories: []

    property var service: Services.CategoryService {
        id: categoryService
        Component.onCompleted: initialize()
    }

    function loadCategoriesByType(type) {
        categories = service.loadCategories(type);
        updateModel();
    }

    function loadCategoriesByTypeWithGoals(type) {
        categories = service.loadCategoriesWithGoals(type);
        updateModel();
    }

    function loadAllCategories() {
        var expenses = service.loadCategoriesWithGoals(0);
        var revenues = service.loadCategoriesWithGoals(1);
        categories = expenses.concat(revenues);
        updateModel();
    }

    function updateModel() {
        clear();
        for (var i = 0; i < categories.length; i++) {
            append({
                categoryId: categories[i].categoryId,
                nameCategory: categories[i].nameCategory,
                pathToIcon: categories[i].pathToIcon,
                typeCategory: categories[i].typeCategory
            });
        }
    }

    function addCategory(category) {
        service.addCategory(category);
    }

    function getCategoryById(categoryId) {
        for (var i = 0; i < categories.length; i++) {
            if (categories[i].categoryId === categoryId) {
                return {
                    categoryId: categories[i].categoryId,
                    nameCategory: categories[i].nameCategory,
                    pathToIcon: categories[i].pathToIcon,
                    typeCategory: categories[i].typeCategory
                };
            }
        }
        return null;
    }

    function filteredCategories(action) {
        loadAllCategoriesForFilter();
        categories = categories.filter(function (cat) {
            return cat.categoryId !== 8 && cat.categoryId !== 13 && cat.typeCategory === action && cat.isActive === 1;
        });
        updateModel();
    }

    function filteredCategories2(action) {
        loadAllCategoriesForFilter();
        return categories.filter(function (cat) {
            return cat.categoryId !== 8 && cat.categoryId !== 13 && cat.typeCategory === action;
        });
    }

    function getIndexById(categoryId) {
        for (var i = 0; i < count; i++) {
            if (get(i).categoryId === categoryId)
                return i;
        }
        return -1;
    }

    function getCategoryName(categoryId) {
        var category = getCategoryById(categoryId);
        return category ? category.nameCategory : "Не выбрана";
    }

    function getCategoryIcon(categoryId) {
        var category = getCategoryById(categoryId);
        return category ? category.pathToIcon : "Не выбрана";
    }

    function loadCategoriesByCategoryId(selectedCategoryId) {
        return service.loadCategoriesByCategoryId(selectedCategoryId);
    }

    function updateCategory(updatedCategory) {
        service.updateCategory(updatedCategory);
    }

    function removeCategory(categoryId) {
        service.removeCategory(categoryId);
    }

    function getCategoryIdByName(name) {
        for (var i = 0; i < categories.length; i++) {
            if (categories[i].nameCategory === name)
                return categories[i].categoryId;
        }
        return -1;
    }

    function loadAllCategoriesForFilter() {
        var expenses = service.loadCategoriesWithGoals(0);
        var revenues = service.loadCategoriesWithGoals(1);
        categories = expenses.concat(revenues);
    }
}
