import os
import datetime
import zipfile
import glob
import requests
import json
import time

# --- Configuration ---
DASHBOARD_PATH = "docs/non-technical/dashboard.md"
SWIFTPM_PATH = "remi-ssc.swiftpm"
DEADLINE_DATE = datetime.datetime(2026, 2, 6, 0, 0, 0)
START_DATE_30_DAYS = DEADLINE_DATE - datetime.timedelta(days=30)
MAX_SIZE_MB = 25
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

def get_countdown():
    """Calculates time remaining until the deadline."""
    now = datetime.datetime.now()
    remaining = DEADLINE_DATE - now
    
    if remaining.total_seconds() < 0:
        return "Submission Closed! 🏁"
        
    days = remaining.days
    hours, remainder = divmod(remaining.seconds, 3600)
    minutes, _ = divmod(remainder, 60)
    
    return f"{days} days, {hours} hours, {minutes} minutes"

def get_30_day_progress():
    """Calculates the progress into the final 30-day countdown."""
    now = datetime.datetime.now()
    
    # If we are before the 30 day window
    if now < START_DATE_30_DAYS:
        return "Countdown hasn't started yet!", "0%" # Or handle differently
        
    total_seconds = (DEADLINE_DATE - START_DATE_30_DAYS).total_seconds()
    elapsed_seconds = (now - START_DATE_30_DAYS).total_seconds()
    
    percentage = (elapsed_seconds / total_seconds) * 100
    percentage = max(0, min(100, percentage)) # Clamp between 0 and 100
    
    bar_length = 20
    filled_length = int(bar_length * percentage // 100)
    bar = '█' * filled_length + '░' * (bar_length - filled_length)
    
    return f"Day {int(elapsed_seconds // 86400)} of 30", f"[{bar}] {percentage:.1f}%"

def get_file_size_stats():
    """Zips the project and calculates text-based progress bar."""
    zip_name = "temp_project.zip"
    
    # Create a zip of the swiftpm package
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk through the swiftpm directory
        if os.path.exists(SWIFTPM_PATH):
           for root, dirs, files in os.walk(SWIFTPM_PATH):
               for file in files:
                   # Skip hidden files
                   if file.startswith('.'): continue
                   file_path = os.path.join(root, file)
                   arcname = os.path.relpath(file_path, start=os.path.dirname(SWIFTPM_PATH))
                   zipf.write(file_path, arcname)
        else:
            return "Project file not found!", "0%"

    # Get size
    size_bytes = os.path.getsize(zip_name)
    size_mb = size_bytes / (1024 * 1024)
    percentage = (size_mb / MAX_SIZE_MB) * 100
    percentage = min(100, percentage)
    
    # Cleanup
    os.remove(zip_name)
    
    # Progress bar
    bar_length = 20
    filled_length = int(bar_length * percentage // 100)
    bar = '█' * filled_length + '░' * (bar_length - filled_length)
    
    return f"{size_mb:.2f} MB / {MAX_SIZE_MB} MB", f"[{bar}] {percentage:.1f}%"

def get_ai_insights():
    """Reads docs and asks Gemini for steps and quotes using Structured Outputs."""
    if not GEMINI_API_KEY:
        print("No GEMINI_API_KEY found.")
        return [], "Keep pushing forward! (No API Key)"
        
    # Read documentation files
    docs_content = ""
    doc_files = glob.glob("docs/**/*.md", recursive=True)
    for file_path in doc_files:
        if file_path == DASHBOARD_PATH: continue # Skip dashboard itself
        try:
             with open(file_path, 'r') as f:
                docs_content += f"\n--- {file_path} ---\n{f.read()}\n"
        except Exception as e:
            print(f"Error reading {file_path}: {e}")

    prompt = f"""
    You are an AI Mentor for a student developer building 'Remi' for the Apple Swift Student Challenge 2026.
    'Remi' is an app to help memory/dementia patients by scanning photos to recall memories.
    
    Your goal is to guide the student to build a prize-winning app.
    
    Context:
    {docs_content}
    
    Generate 5 actionable technical/design steps and 1 inspiring quote.
    """
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}"
    headers = {'Content-Type': 'application/json'}
    data = {
      "contents": [{
        "parts": [{ "text": prompt }]
      }],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseJsonSchema": {
          "type": "object",
          "properties": {
            "steps": {
              "type": "array",
              "items": { "type": "string" }
            },
            "quote": { "type": "string" }
          },
          "required": ["steps", "quote"]
        }
      }
    }
    
    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        result = response.json()
        
        # Parse the JSON from the text part
        # With structured outputs, the 'text' field contains the raw JSON string
        text_content = result['candidates'][0]['content']['parts'][0]['text']
        
        parsed = json.loads(text_content)
        return parsed.get("steps", []), parsed.get("quote", "Keep coding!")
    except Exception as e:
        print(f"Error calling Gemini: {e}")
        if 'response' in locals():
            print(response.text)
        return [], "Error fetching insights."

def update_dashboard():
    countdown = get_countdown()
    progress_30_str, progress_30_bar = get_30_day_progress()
    size_str, size_bar = get_file_size_stats()
    steps, quote = get_ai_insights()
    
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Reconstruct the entire dashboard content
    dashboard_content = f"""# 🚀 Remi Dashboard

### Last Updated: {current_time}

## 🚀 Time to Lift Off
> **{countdown}** until Feb 6, 2026.

**30-Day Sprint Progress**:
{progress_30_str}
`{progress_30_bar}`

## 💾 Project Diet
**Total Size**: {size_str}
`{size_bar}`

## 🧠 AI Captain's Orders
"""
    for step in steps:
        dashboard_content += f"- [ ] {step}\n"
        
    dashboard_content += f"""
## ✨ Daily Fuel
> "{quote}"
"""

    with open(DASHBOARD_PATH, 'w') as f:
        f.write(dashboard_content)
    print("Dashboard updated successfully!")

if __name__ == "__main__":
    update_dashboard()
