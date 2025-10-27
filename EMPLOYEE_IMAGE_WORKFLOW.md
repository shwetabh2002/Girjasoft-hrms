# Employee Image Upload, Saving, and Viewing Workflow

## 📸 How Employee Images Work in Girjasoft HRMS

### **1. Model Definition (Storing the Image)**

**Location:** `employee/models.py` (line 81)

```python
employee_profile = models.ImageField(upload_to=upload_path, null=True, blank=True)
```

- **Field Type:** `ImageField` (Django's image storage field)
- **Upload Path:** Uses `upload_path()` function for custom path generation
- **Nullable:** Can be null or blank

---

### **2. Upload Path Generation**

**Location:** `horilla/models.py` (lines 59-83)

```python
def upload_path(instance, filename):
    """
    Generates a unique file path for uploads in the format:
    app_label/model_name/field_name/originalfilename-uuid.ext
    """
    ext = filename.split(".")[-1]
    base_name = ".".join(filename.split(".")[:-1]) or "file"
    unique_name = f"{slugify(base_name)}-{uuid4().hex[:8]}.{ext}"
    
    app_label = instance._meta.app_label      # "employee"
    model_name = instance._meta.model_name   # "employee"
    
    if field_name:
        return f"{app_label}/{model_name}/{field_name}/{unique_name}"
```

**Example Path Generated:**
```
employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg
         ↑         ↑            ↑              ↑
         app   model_name   field_name    unique filename
```

---

### **3. Storage Configuration**

**Location:** `horilla/settings.py` (lines 170-171)

```python
MEDIA_URL = "/media/"
MEDIA_ROOT = os.path.join(BASE_DIR, "media/")
```

**Storage Structure:**
```
/media/
  └── employee/
      └── employee/
          └── employee_profile/
              └── bajri-mafia-en-d617738c.jpg
```

**Physical Location:**
```
/Users/shwetabh/Desktop/madlib/horilla/media/employee/employee/employee_profile/
```

---

### **4. Upload Process**

#### **A. Frontend (Upload Form)**

**Location:** `employee/templates/employee/profile/personal_info.html` (lines 172-205)

**JavaScript Handler:**
```javascript
$("#id_employee_profile").change(function (e) {
    const file = this.files[0];
    const reader = new FileReader();
    
    reader.addEventListener("load", function () {
        const imageUrl = reader.result;
        $(".preview").attr("src", imageUrl);  // Show preview
    });
    
    reader.readAsDataURL(file);
});

$("#file-form").submit(function (e) {
    e.preventDefault();
    var formData = new FormData($(this)[0]);
    
    $.ajax({
        url: '{% url "update-own-profile-image" %}',
        type: "POST",
        data: formData,
        contentType: false,      // Important: no content type
        processData: false,       // Important: don't process data
        success: function (response) {
            $("#personalMessage").html(response);
        },
    });
});
```

**Key Points:**
- Uses AJAX for async upload
- Shows preview before upload
- Uses FormData for multipart/form-data upload

#### **B. Backend (Processing Upload)**

**Location:** `employee/views.py` (lines 1541-1562)

**View Function:**
```python
@login_required
@require_http_methods(["POST"])
@permission_required("employee.change_employee")
def update_profile_image(request, obj_id):
    """
    This method is used to upload a profile image
    """
    try:
        employee = Employee.objects.get(id=obj_id)
        img = request.FILES["employee_profile"]  # Get the uploaded file
        employee.employee_profile = img         # Assign to field
        employee.save()                          # Save to database
        messages.success(request, _("Profile image updated."))
    except Exception:
        messages.error(request, _("No image chosen."))
    
    response = render(request, "employee/profile/profile_modal.html")
    return HttpResponse(
        response.content.decode("utf-8") + "<script>location.reload();</script>"
    )
```

**Process:**
1. Get employee by ID
2. Extract file from `request.FILES`
3. Assign to `employee.employee_profile`
4. Call `save()` - Django automatically:
   - Generates upload path using `upload_path()`
   - Saves file to `MEDIA_ROOT`
   - Saves relative path to database

---

### **5. Viewing the Image**

#### **A. Model Method to Get Image URL**

**Location:** `employee/models.py` (lines 138-144)

```python
def get_profile_image_url(self):
    """
    This method is used to return the profile image path of the employee
    """
    url = False
    if self.employee_profile:
        url = self.employee_profile.url  # Returns: /media/employee/employee/employee_profile/filename.jpg
    return url
```

#### **B. Avatar Display with Fallback**

**Location:** `employee/models.py` (lines 244-247)

```python
def get_avatar(self):
    if self.employee_profile and default_storage.exists(self.employee_profile.name):
        return self.employee_profile.url
    return static("images/ui/default_avatar.jpg")  # Fallback if no image
```

---

### **6. URL Serving**

#### **Media Files URL Pattern**

**Location:** `horilla/urls.py`

```python
from django.conf import settings
from django.conf.urls.static import static

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**URL Pattern:**
- Media URL: `/media/`
- Full URL: `http://localhost:8000/media/employee/employee/employee_profile/filename.jpg`

**Example from your terminal:**
```
[27/Oct/2025 18:35:24] "GET /media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg HTTP/1.1" 200 712598
```

---

### **7. Image Deletion**

**Location:** `employee/views.py` (lines 1588-1615)

```python
@login_required
@require_http_methods(["DELETE"])
@permission_required("employee.change_employee")
def remove_profile_image(request, obj_id):
    """
    This method is used to remove uploaded image
    """
    employee = Employee.objects.get(id=obj_id)
    if employee.employee_profile.name == "":
        messages.info(request, _("No profile image to remove."))
        return HttpResponse(...)
    
    file_path = employee.employee_profile.path  # Get absolute file path
    absolute_path = os.path.join(settings.MEDIA_ROOT, file_path)
    os.remove(absolute_path)                    # Delete physical file
    employee.employee_profile = None           # Clear database field
    employee.save()                             # Save changes
    
    messages.success(request, _("Profile image removed."))
    return HttpResponse(...)
```

---

## 🔄 Complete Flow Summary

### **Upload Flow:**
```
1. User selects image in form
   ↓
2. JavaScript shows preview
   ↓
3. Form submitted via AJAX
   ↓
4. Backend receives file in request.FILES
   ↓
5. Django generates path: employee/employee/employee_profile/filename.jpg
   ↓
6. File saved to: /media/employee/employee/employee_profile/filename.jpg
   ↓
7. Path saved to database in employee.employee_profile field
   ↓
8. Page reloads showing new image
```

### **Viewing Flow:**
```
1. Template renders employee object
   ↓
2. Calls employee.get_avatar() or employee.get_profile_image_url()
   ↓
3. Checks if employee.employee_profile exists
   ↓
4. Returns URL: /media/employee/employee/employee_profile/filename.jpg
   ↓
5. Browser requests: http://localhost:8000/media/...
   ↓
6. Django serves file from MEDIA_ROOT
   ↓
7. Image displayed
```

---

## 📁 File Locations

### **Physical Storage:**
```
/media/employee/employee/employee_profile/[unique-filename].jpg
```

### **Database Storage:**
```sql
-- In PostgreSQL
SELECT employee_profile FROM employee_employee WHERE id = 12;

Result: "employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg"
```

### **Full Path:**
```
/Users/shwetabh/Desktop/madlib/horilla/media/employee/employee/employee_profile/bajri-mafia-en-d617738c.jpg
```

---

## 🔑 Key Components

1. **Model Field:** `ImageField(upload_to=upload_path)`
2. **Upload Function:** `upload_path()` generates unique paths
3. **Storage:** Files saved to `MEDIA_ROOT/media/...`
4. **URL:** Served via `/media/` URL pattern
5. **Database:** Stores relative path string

---

## 🎯 How It Works Together

1. **Upload:** `views.py` handles POST request → saves file to disk and path to DB
2. **Storage:** Django stores file physically in `media/` directory
3. **Database:** Path stored as string in database
4. **URL:** Django generates `/media/...` URL automatically
5. **Serving:** In development, Django serves files. In production, web server handles it.

