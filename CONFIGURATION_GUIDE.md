# Girjasoft Configuration Guide

## Database Configuration Setup

This guide explains how database configuration works in Girjasoft HRMS.

## 📁 Configuration Files

### 1. `.env.dist` (Template File)
This is the **distribution template** that shows all available configuration options. It's **not used directly** - it's a reference for what you can configure.

**Location:** `/Users/shwetabh/Desktop/madlib/horilla/.env.dist`

### 2. `.env` (Your Actual Configuration)
This is **your actual configuration file** that the application reads. This file contains your real database credentials and settings.

**Location:** `/Users/shwetabh/Desktop/madlib/horilla/.env`

---

## 🔧 How Database Configuration Works

### Configuration Flow:
```
.env file → settings.py reads variables → Database connection established
```

### Your Current Setup:
```env
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla_main
DB_USER=horilla
DB_PASSWORD=horilla
DB_HOST=localhost
DB_PORT=5432
```

This connects to a PostgreSQL database named `horilla_main` running on your local machine.

---

## 🔑 Key Configuration Variables

### Database Settings:
- **`DB_ENGINE`**: Database engine (postgresql, sqlite3, mysql, etc.)
- **`DB_NAME`**: Database name
- **`DB_USER`**: Database username
- **`DB_PASSWORD`**: Database password
- **`DB_HOST`**: Database host (usually `localhost`)
- **`DB_PORT`**: Database port (PostgreSQL default: `5432`)

### Application Settings:
- **`DEBUG`**: Set to `True` for development, `False` for production
- **`SECRET_KEY`**: Django secret key (generate a secure one for production)
- **`ALLOWED_HOSTS`**: Allowed domains/hosts
- **`TIME_ZONE`**: Application timezone

### Special Password:
- **`DB_INIT_PASSWORD`**: A special 48-character password used for database initialization and loading demo data
  - This is a **one-time setup password** for initializing the database
  - It's different from your database password (`DB_PASSWORD`)
  - Used in the "Initialize Database" and "Load Demo Data" features

---

## 🛠️ How to Change Configuration

### To Change Database Configuration:

1. **Edit your `.env` file** (NOT `.env.dist`):
   ```bash
   nano .env
   # or
   vim .env
   ```

2. **Update the values** you want to change:
   ```env
   DB_NAME=my_new_database
   DB_USER=my_username
   DB_PASSWORD=my_secure_password
   ```

3. **Restart your Django server**:
   ```bash
   # Stop the server (Ctrl+C)
   source horillavenv/bin/activate
   python3 manage.py runserver
   ```

### To Change the Database URL (Alternative Method):

If you prefer using a connection string format:
```env
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

The app will automatically parse this and connect to the database.

---

## 📊 How It's Used in Code

### In `horilla/settings.py` (lines 117-137):

```python
if env("DATABASE_URL", default=None):
    # Option 1: Use DATABASE_URL connection string
    DATABASES = {
        "default": env.db(),
    }
else:
    # Option 2: Use individual DB_* variables
    DATABASES = {
        "default": {
            "ENGINE": env("DB_ENGINE", default="django.db.backends.sqlite3"),
            "NAME": env("DB_NAME", default="TestDB_Horilla.sqlite3"),
            "USER": env("DB_USER", default=""),
            "PASSWORD": env("DB_PASSWORD", default=""),
            "HOST": env("DB_HOST", default=""),
            "PORT": env("DB_PORT", default=""),
        }
    }
```

### In `horilla/horilla_settings.py` (lines 7-14):

```python
DB_INIT_PASSWORD = env(
    "DB_INIT_PASSWORD", 
    default="d3f6a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d"
)
```

This password is used for:
- Database initialization
- Loading demo data
- First-time setup authentication

---

## 🔐 How DB_INIT_PASSWORD Works

### Usage:
1. User visits the login page
2. Sees "Initialize Database" or "Load Demo Data" options
3. Must enter the `DB_INIT_PASSWORD` to authenticate
4. System then initializes the database or loads demo data

### Code Reference:
In `base/views.py` (line 241):
```python
if request.POST.get("load_data_password") == DB_INIT_PASSWORD:
    # Load demo data...
```

In `base/views.py` (line 294):
```python
if DB_INIT_PASSWORD == password:
    # Initialize database...
```

---

## 🌐 Local Development Setup

### Your Current Setup:
```env
# Application
DEBUG=True
TIME_ZONE=Asia/Kolkata
SECRET_KEY=django-insecure-your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1,*

# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla_main
DB_USER=horilla
DB_PASSWORD=horilla
DB_HOST=localhost
DB_PORT=5432
```

### Database Connection:
- **Type:** PostgreSQL
- **Database Name:** horilla_main
- **Username:** horilla
- **Password:** horilla
- **Host:** localhost (127.0.0.1)
- **Port:** 5432

---

## 📝 Supported Database Types

Based on `.env.dist`, you can use:

1. **PostgreSQL**: `django.db.backends.postgresql`
2. **SQLite**: `django.db.backends.sqlite3` (default fallback)
3. **MySQL**: `django.db.backends.mysql`
4. **PostGIS**: `django.contrib.gis.db.backends.postgis` (for geospatial data)
5. **Oracle**: `django.db.backends.oracle`
6. **SQL Server**: `django.db.backends.mssql`

---

## 🚀 Production Requirements

### Before Deploying:

1. **Generate a secure SECRET_KEY**:
   - Visit: https://djecrety.ir
   - Copy the generated key
   - Add to `.env`: `SECRET_KEY=your-secure-key-here`

2. **Set DEBUG to False**:
   ```env
   DEBUG=False
   ```

3. **Update ALLOWED_HOSTS**:
   ```env
   ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
   ```

4. **Use strong database passwords**
5. **Use connection string or environment variables** (not hardcoded passwords)

---

## 🔄 Switching Databases

### To Switch from PostgreSQL to SQLite:
```env
DB_ENGINE=django.db.backends.sqlite3
DB_NAME=db.sqlite3
# Remove DB_USER, DB_PASSWORD, DB_HOST, DB_PORT (not needed for SQLite)
```

### To Switch to MySQL:
```env
DB_ENGINE=django.db.backends.mysql
DB_NAME=horilla_main
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_HOST=localhost
DB_PORT=3306
```

Then install the MySQL client:
```bash
pip install mysqlclient
```

---

## ✅ Summary

1. **`.env.dist`** = Template showing all options
2. **`.env`** = Your actual configuration
3. **Always edit `.env`**, never `.env.dist`
4. **Restart server** after making changes
5. **`DB_INIT_PASSWORD`** = Special password for initial setup
6. **Database config** = Individual variables OR `DATABASE_URL` string

The configuration is read from your `.env` file and used to connect to your database!

