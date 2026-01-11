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

def get_file_size_stats():
    """Zips the project and calculates text-based progress bar."""
    zip_name = "temp_project.zip"
    
    # Create a zip of the swiftpm package
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk through the swiftpm directory
        if os.path.exists(SWIFTPM_PATH):
           for root, dirs, files in os.walk(SWIFTPM_PATH):
               for file in files:
                   file_path = os.path.join(root, file)
                   arcname = os.path.relpath(file_path, start=os.path.dirname(SWIFTPM_PATH))
                   zipf.write(file_path, arcname)
        else:
            return "Project file not found!", "0%"

    # Get size
    size_bytes = os.path.getsize(zip_name)
    size_mb = size_bytes / (1024 * 1024)
    percentage = (size_mb / MAX_SIZE_MB) * 100
    
    # Cleanup
    os.remove(zip_name)
    
    # Progress bar
    bar_length = 20
    filled_length = int(bar_length * percentage // 100)
    bar = '█' * filled_length + '░' * (bar_length - filled_length)
    
    return f"{size_mb:.2f} MB / {MAX_SIZE_MB} MB", f"[{bar}] {percentage:.1f}%"

def get_ai_insights():
    """Reads docs and asks Gemini for steps and quotes."""
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
    You are an AI assistant for a Swift Student Challenge developer.
    Here is the current project documentation:
    {docs_content}
    
    Based on this, generate:
    1. A list of 5 concise, actionable next steps for the developer.
    2. A motivational quote tailored to the project context (building a memory/dementia aid app).
    
    Format the output exactly as JSON:
    {{
        "steps": ["step 1", "step 2", "step 3", "step 4", "step 5"],
        "quote": "your quote here"
    }}
    """
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={GEMINI_API_KEY}"
    headers = {'Content-Type': 'application/json'}
    data = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }
    
    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status() # Raise error for bad status calls
        result = response.json()
        
        # Parse the JSON from the text part
        text_content = result['candidates'][0]['content']['parts'][0]['text']
        
        # Clean up code blocks if Gemini returns them
        text_content = text_content.replace("```json", "").replace("```", "").strip()
        
        parsed = json.loads(text_content)
        return parsed.get("steps", []), parsed.get("quote", "Stay inspired!")
    except Exception as e:
        print(f"Error calling Gemini: {e}")
        if 'response' in locals():
            print(response.text)
        return [], "Error fetching insights."

def update_dashboard():
    countdown = get_countdown()
    size_str, progress_bar = get_file_size_stats()
    steps, quote = get_ai_insights()
    
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    new_content = f"""
### Last Updated: {current_time}

## 🚀 Time to Lift Off
> **{countdown}** until Feb 6, 2026.

## 💾 Project Diet
**Total Size**: {size_str}
`{progress_bar}`

## 🧠 AI Captain's Orders
"""
    for step in steps:
        new_content += f"- [ ] {step}\n"
        
    new_content += f"""
## ✨ Daily Fuel
> "{quote}"

"""

    # Read existing file
    with open(DASHBOARD_PATH, 'r') as f:
        content = f.read()
    
    # Replace content between markers
    start_marker = "<!-- STATUS_START -->"
    end_marker = "<!-- STATUS_END -->"
    
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    if start_idx != -1 and end_idx != -1:
        final_content = content[:start_idx + len(start_marker)] + "\n" + new_content + "\n" + content[end_idx:]
        
        with open(DASHBOARD_PATH, 'w') as f:
            f.write(final_content)
        print("Dashboard updated successfully!")
    else:
        print("Status markers not found in dashboard.md")

if __name__ == "__main__":
    update_dashboard()
