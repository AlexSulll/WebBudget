import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {

    Component.onCompleted: initialize()

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000);
    }

    function initialize() {
        var db = getDatabase();

        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS goals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                categoryId INTEGER,
                isCompleted BOOLEAN DEFAULT 0,
                title TEXT,
                targetAmount REAL,
                currentAmount REAL,
                startDate TEXT,
                endDate TEXT,
                FOREIGN KEY(categoryId) REFERENCES categories(categoryId)
            )");
        });
    }

    function addGoal(goal) {
        var db = getDatabase();
        var categoryId = -1;

        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES (?, ?, ?)", [goal.title, 0, "../icons/Expense/GoalsIcon.svg"]);
            var res = tx.executeSql("SELECT last_insert_rowid() as id");
            categoryId = res.rows.item(0).id;
        });

        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO goals (categoryId, isCompleted, title, targetAmount, currentAmount, startDate, endDate)
                VALUES (?, ?, ?, ?, ?, ?, ?)", [categoryId, 0, goal.title, goal.targetAmount, goal.currentAmount, goal.startDate, goal.endDate]);
        });
    }

    function updateGoal(goal) {
        var db = getDatabase();

        db.transaction(function (tx) {
            // Получаем старую цель для сравнения targetAmount
            var oldGoal = null;
            var rs = tx.executeSql("SELECT * FROM goals WHERE id = ?", [goal.id]);
            if (rs.rows.length > 0) {
                oldGoal = rs.rows.item(0);
            }

            // Если цель найдена и новая целевая сумма больше старой — делаем цель и категорию активными
            if (oldGoal && goal.targetAmount > oldGoal.targetAmount) {
                tx.executeSql("UPDATE goals SET isCompleted = 0 WHERE id = ?", [goal.id]);
                tx.executeSql("UPDATE categories SET isActive = 1 WHERE categoryId = ?", [oldGoal.categoryId]);
            }

            // Обновляем остальные поля цели
            tx.executeSql("UPDATE goals SET \
                    title = ?, \
                    targetAmount = ?, \
                    endDate = ?, \
                    isCompleted = CASE \
                        WHEN currentAmount < ? THEN 0 \
                        ELSE isCompleted \
                    END \
                 WHERE id = ?", [goal.title, goal.targetAmount, goal.endDate, goal.targetAmount, goal.id]);
        });
    }

    function deleteGoal(goal) {
        var db = getDatabase();

        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT categoryId FROM goals WHERE id = ?", [goal]);

            if (rs.rows.length > 0) {
                var categoryId = rs.rows.item(0).categoryId;

                tx.executeSql("UPDATE categories SET isActive = 0 WHERE categoryId = ?", [categoryId]);
            }
        });

        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM goals WHERE id = ?", [goal]);
        });
    }

    function getGoals() {
        var goals = [];
        var db = getDatabase();

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM goals ORDER BY isCompleted, endDate ASC");

            for (var i = 0; i < rs.rows.length; i++) {
                goals.push(rs.rows.item(i));
            }
        });

        return goals;
    }

    function getCountisCompleted() {
        var goals = [];
        var db = getDatabase();

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM goals WHERE isCompleted = 1");

            for (var i = 0; i < rs.rows.length; i++) {
                goals.push(rs.rows.item(i));
            }
        });

        return goals;
    }
}
