# Douaa Mobile App – Technical Specification

## 1. Tech Stack

- Framework: Flutter (latest stable)
- Local Database: SQLite using `sqflite`
- State Management: Riverpod (recommended) or Provider
- Persistent Settings: SharedPreferences
- Screen Awake: wakelock_plus
- App Version Info: package_info_plus

---

## 2. Database Schema

### Table: category
- id (INTEGER PRIMARY KEY)
- name (TEXT)

### Table: sub_category
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- category_id (INTEGER)

### Table: douaa
- id (INTEGER PRIMARY KEY)
- category_id (INTEGER)
- sub_category_id (INTEGER)
- douaa_ar (TEXT)
- douaa_fr (TEXT)
- reference (TEXT)
- tags (TEXT)
- is_favorite (INTEGER DEFAULT 0)

---

## 3. App Structure

BottomNavigationBar with 3 tabs:

1. Home
2. Favorites
3. Settings

Use IndexedStack to preserve tab state.

---

## 4. Home Screen

### Features

- Display list of categories
- Toggle button in AppBar to switch between:
    - Grid view (2 columns)
    - List view
- FloatingActionButton to add a new category

### Add Category

- Dialog with text input
- Validate non-empty
- Insert into SQLite
- Refresh UI

---

## 5. Category Detail Screen

When a category is selected:

- Display list of Douaa belonging to that category
- Query with LEFT JOIN to fetch subcategory name
- Ordered by newest first

### Douaa Card UI

Each card must display:

- Arabic text (RTL)
- French translation
- Reference (smaller text)
- Favorite toggle button

Respect settings:
- Hide reference if disabled
- Hide translation if disabled

---

## 6. Create / Edit Douaa

Form Fields:

- Sub-category dropdown (filtered by category_id)
- Button to create new sub-category inline
- Arabic text (required, multiline, RTL)
- French translation
- Reference
- Tags

Validation:
- Arabic text is mandatory

---

## 7. Favorites Tab

- Display only categories containing at least one favorite Douaa
- Same UI behavior as Home (grid/list toggle)

Query example:

```sql
SELECT DISTINCT c.*
FROM category c
INNER JOIN douaa d ON d.category_id = c.id
WHERE d.is_favorite = 1;
