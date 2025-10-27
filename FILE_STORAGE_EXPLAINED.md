# File Storage in Girjasoft HRMS

## 📁 Current Storage: **Local Filesystem (Default)**

### **Where Files Are Currently Saved:**

By default, files are saved to your **local filesystem**:

```
Storage Type: Local Filesystem
Location: /Users/shwetabh/Desktop/madlib/horilla/media/
```

**Example:** Employee profile image
```
Physical Path: /Users/shwetabh/Desktop/madlib/horilla/media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg
Web URL:       http://localhost:8000/media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg
Database:      Stores path: "employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg"
```

---

## 🌐 Cloud Storage Options Available

The system supports **3 types of storage**:

### **1. Local Filesystem (Current - Default)**
**Configuration:** `horilla/settings.py` (lines 170-171)
```python
MEDIA_URL = "/media/"
MEDIA_ROOT = os.path.join(BASE_DIR, "media/")
```

**Storage:** Files saved to local disk
- **Path:** `project/media/`
- **URL:** `http://localhost:8000/media/`
- **Pros:** Simple, fast, no additional cost
- **Cons:** Not scalable, lost if server dies

---

### **2. AWS S3 (Amazon Simple Storage Service)**

**Configuration:** In `.env` file
```env
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_STORAGE_BUCKET_NAME=your-bucket-name
AWS_S3_REGION_NAME=us-east-1
DEFAULT_FILE_STORAGE="horilla.horilla_backends.PrivateMediaStorage"
NAMESPACE=private
```

**Backend:** `horilla/horilla_backends.py` (lines 11-24)
```python
class PrivateMediaStorage(S3Boto3Storage):
    location = settings.env("NAMESPACE", default="private")
    default_acl = "private"
    file_overwrite = False
    custom_domain = False
```

**Storage:** Files saved to AWS S3 bucket
- **Path:** `s3://your-bucket-name/private/...`
- **URL:** `https://your-bucket-name.s3.amazonaws.com/private/...`
- **Pros:** Scalable, backup, CDN support
- **Cons:** Requires AWS account, costs money

---

### **3. Google Cloud Platform (GCP) Storage**

**Configuration:** In `.env` file
```env
GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
GS_BUCKET_NAME="your-gcp-bucket"
DEFAULT_FILE_STORAGE="horilla.horilla_backends_gcp.PrivateMediaStorage"
MEDIA_URL="https://storage.cloud.google.com/yourGCPBucketName/media"
NAMESPACE=private
```

**Backend:** `horilla/horilla_backends_gcp.py` (lines 11-23)
```python
class PrivateMediaStorage(GoogleCloudStorage):
    location = settings.env("NAMESPACE", default="private")
    default_acl = "private"
    file_overwrite = False
```

**Storage:** Files saved to Google Cloud Storage
- **Path:** `gs://your-bucket-name/private/...`
- **URL:** `https://storage.cloud.google.com/your-bucket/private/...`
- **Pros:** Scalable, Google integration
- **Cons:** Requires GCP account, costs money

---

## 🔧 How It Works

### **Configuration Detection:**

**Location:** `horilla/horilla_settings.py` (lines 111-132)

```python
# AWS S3 Configuration
if settings.env("AWS_ACCESS_KEY_ID", default=None):
    # Configure S3 storage
    DEFAULT_FILE_STORAGE = settings.env("DEFAULT_FILE_STORAGE")
    # Set up S3 settings...

# GCP Configuration (from .env.dist comments)
if settings.env("GOOGLE_APPLICATION_CREDENTIALS", default=None):
    # Configure GCP storage
    DEFAULT_FILE_STORAGE = "horilla.horilla_backends_gcp.PrivateMediaStorage"
    # Set up GCP settings...
```

**Priority:**
1. **Check `.env` for cloud storage credentials**
2. **If found:** Use cloud storage (S3 or GCP)
3. **If not:** Use local filesystem (default)

---

## 📊 Your Current Setup

### **Storage Type: Local Filesystem**

```env
# In your .env file (no cloud storage configured)
MEDIA_URL=/media/
MEDIA_ROOT=/path/to/project/media/
```

### **Where Files Are Saved:**

```
📂 /Users/shwetabh/Desktop/madlib/horilla/media/
   └── employee/
       └── employee/
           └── employee_profile/
               └── bajri-mafia-en-d617738c.jpg  ← Employee photos
```

### **How to Access:**

```bash
# Physical file location
/media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg

# Web URL
http://localhost:8000/media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg
```

---

## ☁️ How to Switch to Cloud Storage

### **Switch to AWS S3:**

1. **Create S3 bucket** in AWS Console
2. **Get credentials:** Access Key ID and Secret Key
3. **Update `.env` file:**
```env
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_STORAGE_BUCKET_NAME=my-girjasoft-bucket
AWS_S3_REGION_NAME=us-east-1
DEFAULT_FILE_STORAGE="horilla.horilla_backends.PrivateMediaStorage"
MEDIA_URL="https://my-girjasoft-bucket.s3.amazonaws.com/"
MEDIA_ROOT="https://my-girjasoft-bucket.s3.amazonaws.com/"
NAMESPACE=private
```

4. **Restart server**

### **Switch to Google Cloud Storage:**

1. **Create GCP bucket** in Google Cloud Console
2. **Create service account** and download JSON credentials
3. **Update `.env` file:**
```env
GOOGLE_APPLICATION_CREDENTIALS="./path/to/service-account.json"
GS_BUCKET_NAME="my-girjasoft-bucket"
DEFAULT_FILE_STORAGE="horilla.horilla_backends_gcp.PrivateMediaStorage"
MEDIA_URL="https://storage.cloud.google.com/my-girjasoft-bucket/media"
MEDIA_ROOT="https://storage.cloud.google.com/my-girjasoft-bucket/media"
NAMESPACE=private
```

4. **Restart server**

---

## 🔄 File Upload Flow Comparison

### **Local Filesystem (Current):**
```
Upload → Save to: /media/employee/.../filename.jpg
        ↓
     Django ORM stores path in database
        ↓
    Serve via: /media/...
```

### **AWS S3:**
```
Upload → Upload to: s3://bucket/private/employee/.../filename.jpg
        ↓
     Django ORM stores path in database
        ↓
    Serve via: https://bucket.s3.amazonaws.com/private/...
```

### **Google Cloud Storage:**
```
Upload → Upload to: gs://bucket/private/employee/.../filename.jpg
        ↓
     Django ORM stores path in database
        ↓
    Serve via: https://storage.cloud.google.com/bucket/private/...
```

---

## 📝 Database Storage (Always the Same)

Regardless of where files are physically stored, the **database always stores** the relative path:

```sql
-- In employee_employee table
SELECT employee_profile FROM employee_employee WHERE id = 12;

Result: "employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg"
```

**Key Point:** The database doesn't store the full URL, just the relative path. Django then converts it to the correct URL based on your storage backend.

---

## 🎯 Summary

### **Currently:**
- ✅ **Storage:** Local filesystem (`/media/` folder)
- ✅ **Where:** On your machine: `/Users/shwetabh/Desktop/madlib/horilla/media/`
- ✅ **Access:** Via `http://localhost:8000/media/...`

### **Can Switch To:**
- ☁️ **AWS S3:** For production/scalability
- ☁️ **Google Cloud:** For GCP integration
- 💾 **Local:** Simple development setup

### **Configuration:**
- **Detects automatically** based on `.env` file
- **No code changes** needed to switch
- **Database path stays the same**

The system is **ready for cloud storage** but currently uses **local filesystem** for simplicity!

