from flask import Flask, request, jsonify, send_from_directory, render_template
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from dotenv import load_dotenv
import os
import time
import shutil
import traceback
import re
import pdfplumber

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

USERNAME = os.getenv("ERP_USERNAME")
PASSWORD = os.getenv("ERP_PASSWORD")

if not USERNAME or not PASSWORD:
    print("[ERROR] Missing ERP credentials!")
    print(f"[DEBUG] USERNAME: {USERNAME}")
    print(f"[DEBUG] PASSWORD: {'*' * len(PASSWORD) if PASSWORD else 'None'}")
    raise ValueError("Missing ERP credentials. Check your .env file for ERP_USERNAME and ERP_PASSWORD.")

print(f"[INFO] Credentials loaded - Username: {USERNAME}")

DOWNLOAD_DIR = os.path.join(os.getcwd(), "downloads")
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

def download_pdf_for_sic(sic_number):
    print(f"\n{'='*60}")
    print(f"[INFO] Starting download for: {sic_number}")
    print(f"[INFO] Download directory: {DOWNLOAD_DIR}")
    print(f"{'='*60}\n")
    
    # Clean download directory
    shutil.rmtree(DOWNLOAD_DIR, ignore_errors=True)
    os.makedirs(DOWNLOAD_DIR)

    # Chrome options
    options = webdriver.ChromeOptions()
    
    # For debugging, comment out headless to see what's happening
    options.add_argument("--headless")  # Comment this line to see browser
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-software-rasterizer")
    
    # Download preferences
    prefs = {
        "download.default_directory": DOWNLOAD_DIR,
        "download.prompt_for_download": False,
        "plugins.always_open_pdf_externally": True,
        "download.directory_upgrade": True,
        "safebrowsing.enabled": True
    }
    options.add_experimental_option("prefs", prefs)
    
    driver = None
    
    try:
        # Use webdriver-manager to automatically handle ChromeDriver
        print("[INFO] Initializing ChromeDriver...")
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=options)
        print("[INFO] Chrome started successfully")

        # Login to ERP
        print("[INFO] Navigating to ERP login page...")
        driver.get("https://erp.silicon.ac.in/estcampus/index.php")
        
        print("[INFO] Waiting for login form...")
        username_field = WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.NAME, "username"))
        )
        
        print(f"[INFO] Entering username: {USERNAME}")
        username_field.send_keys(USERNAME)
        
        password_field = driver.find_element(By.NAME, "password")
        password_field.send_keys(PASSWORD)
        
        print("[INFO] Clicking sign in button...")
        driver.find_element(By.XPATH, "//button[text()='Sign in']").click()
        
        # Wait for login to complete
        print("[INFO] Waiting for login to complete...")
        time.sleep(2)  # Reduced from 3 to 2 seconds
        
        # Check if login was successful
        current_url = driver.current_url
        print(f"[INFO] Current URL after login: {current_url}")
        
        if "index.php" in current_url and "estcampus" in current_url:
            print("[WARNING] Still on login page - login may have failed!")
            print("[INFO] Page title:", driver.title)
            # Take screenshot for debugging
            screenshot_path = os.path.join(DOWNLOAD_DIR, "login_error.png")
            driver.save_screenshot(screenshot_path)
            print(f"[INFO] Screenshot saved: {screenshot_path}")

        # Navigate to results page
        print("[INFO] Navigating to results page...")
        results_url = "https://erp.silicon.ac.in/estcampus/autonomous_exam/exam_result.php?role_code=M1Z5SEVJM2dub0NWWE5GZy82dHh2QT09"
        driver.get(results_url)
        
        print("[INFO] Waiting for results page to load...")
        WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        time.sleep(1)  # Reduced from 2 to 1 second

        
        print(f"[INFO] Current URL: {driver.current_url}")
        print(f"[INFO] Page title: {driver.title}")

        # Check if the download function exists
        print("[INFO] Checking if download function exists...")
        function_exists = driver.execute_script(
            "return typeof Final_Semester_Result_pdf_Download === 'function';"
        )
        print(f"[INFO] Function exists: {function_exists}")
        
        if not function_exists:
            print("[ERROR] Download function not found on page!")
            # Save page source for debugging
            with open(os.path.join(DOWNLOAD_DIR, "page_source.html"), "w", encoding="utf-8") as f:
                f.write(driver.page_source)
            print("[INFO] Page source saved for debugging")
            return None

        # Execute download script
        print(f"[INFO] Executing download for SIC: {sic_number}")
        driver.execute_script(f"Final_Semester_Result_pdf_Download('{sic_number}')")
        
        print("[INFO] Download triggered, waiting for PDF...")

        # Wait for PDF download with optimized checking
        timeout = 30  # Reduced from 45
        start = time.time()
        last_check = 0
        pdf_found = False
        
        while time.time() - start < timeout:
            elapsed = int(time.time() - start)
            if elapsed > last_check and elapsed % 3 == 0:  # Check every 3s instead of 5s
                print(f"[INFO] Waiting... {elapsed}s elapsed")
                last_check = elapsed
            
            try:
                files = os.listdir(DOWNLOAD_DIR)
                for file in files:
                    if file.endswith(".pdf") and not file.endswith(".crdownload"):
                        file_path = os.path.join(DOWNLOAD_DIR, file)
                        
                        # Check if file is still being written
                        initial_size = os.path.getsize(file_path)
                        time.sleep(0.5)  # Short wait
                        current_size = os.path.getsize(file_path)
                        
                        # If size hasn't changed, download is complete
                        if initial_size == current_size and current_size > 0:
                            new_path = os.path.join(DOWNLOAD_DIR, f"{sic_number}.pdf")
                            os.rename(file_path, new_path)
                            print(f"\n[SUCCESS] PDF downloaded: {new_path}")
                            print(f"[INFO] File size: {os.path.getsize(new_path)} bytes")
                            return new_path
            except Exception as e:
                # File might be locked, continue waiting
                pass
            
            time.sleep(0.5)  # Check more frequently (0.5s instead of 1s)

        print("\n[ERROR] PDF not found after waiting 30 seconds")
        print(f"[INFO] Files in download directory: {os.listdir(DOWNLOAD_DIR)}")
        return None

    except Exception as e:
        print(f"\n[ERROR] Exception occurred: {e}")
        print(f"[ERROR] Error type: {type(e).__name__}")
        print(f"[ERROR] Full traceback:")
        print(traceback.format_exc())
        
        # Save screenshot on error
        if driver:
            try:
                screenshot_path = os.path.join(DOWNLOAD_DIR, "error_screenshot.png")
                driver.save_screenshot(screenshot_path)
                print(f"[INFO] Error screenshot saved: {screenshot_path}")
            except:
                pass
        
        return None

    finally:
        if driver:
            try:
                driver.quit()
                print("[INFO] Chrome session closed")
            except:
                pass
        print(f"{'='*60}\n")

def extract_cgpa_from_pdf(pdf_path):
    """
    Extract CGPA from the last page of the PDF.
    Returns the CGPA value as a string, or None if not found.
    """
    print(f"[INFO] Extracting CGPA from PDF...")
    
    try:
        with pdfplumber.open(pdf_path) as pdf:
            # Only read the last page for speed
            last_page = pdf.pages[-1]
            text = last_page.extract_text()
            
            if not text:
                print("[WARNING] No text found on last page")
                return None
            
            # Quick patterns - most common first for speed
            patterns = [
                r'CGPA\s*:?\s*(\d+\.?\d*)',  # CGPA: 8.5 or CGPA 8.5
                r'C\.G\.P\.A\.?\s*:?\s*(\d+\.?\d*)',  # C.G.P.A: 8.5
                r'CGPA\s*=\s*(\d+\.?\d*)',  # CGPA = 8.5
                r'Overall\s+CGPA\s*:?\s*(\d+\.?\d*)',  # Overall CGPA
                r'Final\s+CGPA\s*:?\s*(\d+\.?\d*)',  # Final CGPA
            ]
            
            # Try each pattern - return immediately when found
            for pattern in patterns:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    cgpa = match.group(1)
                    print(f"[SUCCESS] CGPA found: {cgpa}")
                    return cgpa
            
            # Fast fallback: find CGPA in lines
            lines = text.split('\n')
            for line in lines:
                if 'cgpa' in line.lower():
                    numbers = re.findall(r'\d+\.\d+', line)
                    for num in numbers:
                        num_float = float(num)
                        if 0 <= num_float <= 10:
                            print(f"[SUCCESS] CGPA found: {num}")
                            return num
            
            print("[WARNING] CGPA not found in PDF")
            return None
            
    except Exception as e:
        print(f"[ERROR] Failed to extract CGPA: {e}")
        return None


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/download', methods=["POST"])
def download_handler():
    try:
        data = request.get_json()
        sic = data.get("sic", "").strip().upper()
        if len(sic) != 8:
            return jsonify({"error": "SIC must be 8 characters"}), 400
        
        full_sic = f"SITBBS{sic}"
        
        # Download the PDF
        pdf_path = download_pdf_for_sic(full_sic)
        
        if pdf_path:
            # Extract CGPA from the PDF
            cgpa = extract_cgpa_from_pdf(pdf_path)
            
            response_data = {
                "message": "PDF downloaded successfully",
                "pdf": os.path.basename(pdf_path),
                "sic": sic,
                "cgpa": cgpa if cgpa else "Not found"
            }
            
            print(f"\n[RESULT] SIC: {sic}, CGPA: {cgpa if cgpa else 'Not found'}\n")
            
            return jsonify(response_data), 200
        else:
            return jsonify({"error": "Failed to download PDF"}), 500
            
    except Exception as e:
        print(f"[EXCEPTION] {e}")
        print(traceback.format_exc())
        return jsonify({"error": "Unexpected error"}), 500

@app.route('/downloads/<filename>')
def serve_pdf(filename):
    return send_from_directory(DOWNLOAD_DIR, filename)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
